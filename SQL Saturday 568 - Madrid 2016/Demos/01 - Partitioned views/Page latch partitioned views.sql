/*============================================================================
  File:     
  Summary:  SQL Saturday 510 - Paris
  Date:     06/2016
  SQL Server Versions: 
------------------------------------------------------------------------------
  Written by Christophe LAPORTE, SQL Server MVP / MCM
	Blog    : http://conseilit.wordpress.com
	Twitter : @ConseilIT
  
  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you give due credit.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

Use Master
GO


CREATE DATABASE DemoDistributedPartitionedViews
GO

USE DemoDistributedPartitionedViews
GO


CREATE SEQUENCE dbo.SequenceSimple
AS int
START     WITH 10000000
INCREMENT BY   1;
GO

CREATE SEQUENCE dbo.Sequence_1_5 
AS tinyint 
	START     WITH 1 
	INCREMENT BY   1 
	MINVALUE       1 
	MAXVALUE       5 
	CYCLE ; 
GO


CREATE TABLE [dbo].[SingleTable](
	[orderid] [int] NOT NULL,
	[custid] [char](11) NOT NULL,
	[empid] [int] NOT NULL,
	[shipperid] [varchar](5) NOT NULL,
	[orderdate] [datetime] NOT NULL,
	CONSTRAINT [PK_SingleTable] PRIMARY KEY NONCLUSTERED 
	(
		[orderid],[shipperid] ASC
	)
);
GO



CREATE PROCEDURE usp_InsertSingleTable
AS
BEGIN

	SET NOCOUNT ON
	DECLARE @NextID int = NEXT VALUE FOR dbo.SequenceSimple;
	DECLARE @parition tinyint = NEXT VALUE FOR dbo.Sequence_1_5;

	INSERT INTO [SingleTable] ([orderid],[custid],[empid],[shipperid],[orderdate])
	VALUES (@NextID,@NextID,@parition,
		CASE @parition
			WHEN 1 THEN 'A'
			WHEN 2 THEN 'C'
			WHEN 3 THEN 'E'
			WHEN 4 THEN 'G'
			WHEN 5 THEN 'I'
		END,
		GETDATE());

END
GO



CREATE TABLE [dbo].[table_A](
	[orderid] [int] NOT NULL,
	[custid] [char](11) NOT NULL,
	[empid] [int] NOT NULL,
	[shipperid] [varchar](5) NOT NULL CHECK ([shipperid] = 'A'),
	[orderdate] [datetime] NOT NULL,
	CONSTRAINT [PK_table_A] PRIMARY KEY NONCLUSTERED 
	(
		[orderid],[shipperid] ASC
	)
);
GO

CREATE TABLE [dbo].[table_C](
	[orderid] [int] NOT NULL,
	[custid] [char](11) NOT NULL,
	[empid] [int] NOT NULL,
	[shipperid] [varchar](5) NOT NULL CHECK ([shipperid] = 'C'),
	[orderdate] [datetime] NOT NULL,
	CONSTRAINT [PK_table_C] PRIMARY KEY NONCLUSTERED 
	(
		[orderid],[shipperid] ASC
	)
);
GO

CREATE TABLE [dbo].[table_E](
	[orderid] [int] NOT NULL,
	[custid] [char](11) NOT NULL,
	[empid] [int] NOT NULL,
	[shipperid] [varchar](5) NOT NULL CHECK ([shipperid] = 'E'),
	[orderdate] [datetime] NOT NULL,
	CONSTRAINT [PK_table_E] PRIMARY KEY NONCLUSTERED 
	(
		[orderid],[shipperid] ASC
	)
);
GO

CREATE TABLE [dbo].[table_G](
	[orderid] [int] NOT NULL,
	[custid] [char](11) NOT NULL,
	[empid] [int] NOT NULL,
	[shipperid] [varchar](5) NOT NULL CHECK ([shipperid] = 'G'),
	[orderdate] [datetime] NOT NULL,
	CONSTRAINT [PK_table_G] PRIMARY KEY NONCLUSTERED 
	(
		[orderid],[shipperid] ASC
	)
);
GO

CREATE TABLE [dbo].[table_I] (
	[orderid] [int] NOT NULL,
	[custid] [char](11) NOT NULL,
	[empid] [int] NOT NULL,
	[shipperid] [varchar](5) NOT NULL CHECK ([shipperid] = 'I'),
	[orderdate] [datetime] NOT NULL,
	CONSTRAINT [PK_table_I] PRIMARY KEY NONCLUSTERED 
	(
		[orderid],[shipperid] ASC
	)
);
GO


CREATE VIEW PartitionedView
AS
	SELECT * FROM [dbo].[table_A]
		UNION ALL
	SELECT * FROM [dbo].[table_C]
		UNION ALL
	SELECT * FROM [dbo].[table_E]
		UNION ALL
	SELECT * FROM [dbo].[table_G]
		UNION ALL
	SELECT * FROM [dbo].[table_I]
GO


CREATE PROCEDURE usp_InsertPartitionedView
AS
BEGIN

	SET NOCOUNT ON
	DECLARE @NextID   INT     = NEXT VALUE FOR dbo.SequenceSimple;
	DECLARE @parition TINYINT = NEXT VALUE FOR dbo.Sequence_1_5;

	INSERT INTO PartitionedView ([orderid],[custid],[empid],[shipperid],[orderdate])
	VALUES (@NextID,@NextID,@parition,
		CASE @parition
			WHEN 1 THEN 'A'
			WHEN 2 THEN 'C'
			WHEN 3 THEN 'E'
			WHEN 4 THEN 'G'
			WHEN 5 THEN 'I'
		END,
		GETDATE());

END
GO


/*

-- RML Utilities Command prompt
-- 

Ostress.exe -dDemoDistributedPartitionedViews -E –Q"EXEC usp_InsertSingleTable"  –n200 –r1000 –oc:\temp\output -SSQLNode01 
Ostress.exe -dDemoDistributedPartitionedViews -E –Q"EXEC usp_InsertPartitionedView"  –n200 –r1000 –oc:\temp\output -SSQLNode01 

*/


-- check for page latches
SELECT 	DB_NAME(database_id) as DatabaseName,
	    OBJECT_NAME(ios.object_id,database_id) as TableName,
	    ios.object_id,count(ios.index_id) AS IndexCount,sum(ios.leaf_insert_count) as leaf_insert_count,
		sum(ios.row_lock_count) as row_lock_count,sum(ios.row_lock_wait_count) as row_lock_wait_count,sum(ios.row_lock_wait_in_ms) as row_lock_wait_in_ms,
		sum(ios.page_lock_count) as page_lock_count,sum(ios.page_lock_wait_count) as page_lock_wait_count,sum(ios.page_lock_wait_in_ms) as page_lock_wait_in_ms,
		sum(ios.page_latch_wait_count) as page_latch_wait_count,sum(ios.page_latch_wait_in_ms)  as page_latch_wait_in_ms
FROM sys.dm_db_index_operational_stats(db_id(),null,null,null) ios
INNER JOIN sys.tables t ON ios.object_id=t.object_id
GROUP BY database_id,ios.object_id


/*

	-- cleanup

	USE Master
	GO
	DROP DATABASE DemoDistributedPartitionedViews
	GO

*/
