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
Go


CREATE DATABASE DemoPartition
GO

USE DemoPartition
GO



CREATE SEQUENCE dbo.SequenceSimple
AS int
START     WITH 1
INCREMENT BY   1;
GO

CREATE SEQUENCE dbo.Sequence_1_10 
AS tinyint 
	START     WITH 0 
	INCREMENT BY   1 
	MINVALUE       0 
	MAXVALUE       9 
	CYCLE ; 




CREATE TABLE dbo.DemoTableNCI (
	id int PRIMARY KEY NONCLUSTERED,
	col1 tinyint,
    dt datetime2 
	);
GO
CREATE PROCEDURE usp_InsertNCI
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @NextID INT     = NEXT VALUE FOR dbo.SequenceSimple;
	DECLARE @col1   TINYINT = NEXT VALUE FOR dbo.Sequence_1_10;

	INSERT INTO DemoTableNCI (id,col1,dt)
	VALUES (@NextID,@col1,GETDATE())
END
GO




CREATE TABLE dbo.DemoTableCI (
	id int PRIMARY KEY CLUSTERED,
	col1 tinyint,
    dt datetime2 
	);
GO
CREATE PROCEDURE usp_InsertCI
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @NextID INT     = NEXT VALUE FOR dbo.SequenceSimple;
	DECLARE @col1   TINYINT = NEXT VALUE FOR dbo.Sequence_1_10;

	INSERT INTO DemoTableCI (id,col1,dt)
	VALUES (@NextID,@col1,GETDATE())
END
GO




CREATE PARTITION FUNCTION [fn_PartitionFunction] (tinyint) 
AS RANGE LEFT 
FOR VALUES (0,1,2,3,4,5,6,7,8,9);
GO
CREATE PARTITION SCHEME [sch_PartitionScheme] 
AS PARTITION [fn_PartitionFunction] 
TO ([PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY],
    [PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY]);
GO



CREATE TABLE dbo.DemoTablePartitionedCI (
	id int,
	col1 tinyint,
    dt datetime2 ,
	CONSTRAINT PK_DemoTablePartitionedCI PRIMARY KEY (col1,id)
	)
ON [sch_PartitionScheme](col1);
GO
CREATE PROCEDURE usp_InsertPartitionedCI
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @NextID int = NEXT VALUE FOR dbo.SequenceSimple;
	DECLARE @col1 tinyint = NEXT VALUE FOR dbo.Sequence_1_10;

	INSERT INTO DemoTablePartitionedCI (id,col1,dt)
	VALUES (@NextID,@col1,GETDATE())
END
GO




CREATE TABLE dbo.DemoTablePartitionedNCI (
	id int,
	col1 tinyint,
    dt datetime2 ,
	CONSTRAINT PK_DemoTablePartitionedNCI PRIMARY KEY NONCLUSTERED (col1,id)
	)
ON [sch_PartitionScheme](col1);
GO
CREATE PROCEDURE usp_InsertPartitionedNCI
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @NextID int = NEXT VALUE FOR dbo.SequenceSimple;
	DECLARE @col1 tinyint = NEXT VALUE FOR dbo.Sequence_1_10;

	INSERT INTO DemoTablePartitionedNCI (id,col1,dt)
	VALUES (@NextID,@col1,GETDATE())
END
GO



/*

Ostress.exe -dDemoPartition -E –Q"EXEC usp_InsertNCI"  –n200 –r1000 –oc:\temp\output -SSQLNode01 
Ostress.exe -dDemoPartition -E –Q"EXEC usp_InsertCI"  –n200 –r1000 –oc:\temp\output -SSQLNode01 
Ostress.exe -dDemoPartition -E –Q"EXEC usp_InsertPartitionedNCI"  –n200 –r1000 –oc:\temp\output -SSQLNode01 
Ostress.exe -dDemoPartition -E –Q"EXEC usp_InsertPartitionedCI"  –n200 –r1000 –oc:\temp\output -SSQLNode01 

*/


-- Check Page latches for each table
SELECT 	DB_NAME(database_id) as DatabaseName,
	    OBJECT_NAME(ios.object_id,database_id) as TableName,
	    ios.object_id,count(ios.index_id) AS IndexCount,sum(ios.leaf_insert_count) as leaf_insert_count,
		sum(ios.row_lock_count) as row_lock_count,sum(ios.row_lock_wait_count) as row_lock_wait_count,sum(ios.row_lock_wait_in_ms) as row_lock_wait_in_ms,
		sum(ios.page_lock_count) as page_lock_count,sum(ios.page_lock_wait_count) as page_lock_wait_count,sum(ios.page_lock_wait_in_ms) as page_lock_wait_in_ms,
		sum(ios.page_latch_wait_count) as page_latch_wait_count,sum(ios.page_latch_wait_in_ms)  as page_latch_wait_in_ms
FROM sys.dm_db_index_operational_stats(db_id(),null,null,null) ios
INNER JOIN sys.tables t on ios.object_id=t.object_id
GROUP BY database_id,ios.object_id



/*

-- detailed information

SELECT OBJECT_NAME(i.object_id) as Object_Name,
i.index_id,
        p.partition_number, fg.name AS Filegroup_Name, rows, au.total_pages,
        CASE boundary_value_on_right
                   WHEN 1 THEN 'less than'
                   ELSE 'less than or equal to' END as 'comparison', value
FROM sys.partitions p JOIN sys.indexes i
     ON p.object_id = i.object_id and p.index_id = i.index_id
       JOIN sys.partition_schemes ps
                ON ps.data_space_id = i.data_space_id
       JOIN sys.partition_functions f
                   ON f.function_id = ps.function_id
       LEFT JOIN sys.partition_range_values rv
ON f.function_id = rv.function_id
                    AND p.partition_number = rv.boundary_id
     JOIN sys.destination_data_spaces dds
             ON dds.partition_scheme_id = ps.data_space_id
                  AND dds.destination_id = p.partition_number
     JOIN sys.filegroups fg
                ON dds.data_space_id = fg.data_space_id
     JOIN (SELECT container_id, sum(total_pages) as total_pages
                     FROM sys.allocation_units
                     GROUP BY container_id) AS au
                ON au.container_id = p.partition_id
WHERE i.index_id <2
order by p.partition_number

select 	DB_NAME(database_id) as DatabaseName,
	    OBJECT_NAME(ios.object_id,database_id) as TableName,
	    ios.object_id,ios.partition_number,ios.index_id,ios.leaf_insert_count,
		ios.row_lock_count,ios.row_lock_wait_count,ios.row_lock_wait_in_ms,
		ios.page_lock_count,ios.page_lock_wait_count,ios.page_lock_wait_in_ms,
		ios.page_latch_wait_count,ios.page_latch_wait_in_ms  
FROM sys.dm_db_index_operational_stats(db_id(),null,null,null) ios
inner join sys.tables t on ios.object_id=t.object_id


*/

/*
-- cleanup

use master
go
DROP DATABASE DemoPartition

*/
