--==============================================================================
--
--  Summary:  SQLSaturday Montréal #758 - 2018
--  Date:     06/2018
--
--  ----------------------------------------------------------------------------
--  Written by Christophe LAPORTE, SQL Server MVP / MCM
--	Blog    : http://conseilit.wordpress.com
--	Twitter : @ConseilIT
--  
--  You may alter this code for your own *non-commercial* purposes. You may
--  republish altered code as long as you give due credit.
--  
--  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
--  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
--  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
--  PARTICULAR PURPOSE.
--==============================================================================


DROP DATABASE IF EXISTS [DemoDB]
GO

-- Create database DemoDB
CREATE DATABASE [DemoDB];
GO
ALTER DATABASE [DemoDB] 
MODIFY FILE ( NAME = N'DemoDB', SIZE = 524288KB )
ALTER DATABASE [DemoDB] 
MODIFY FILE ( NAME = N'DemoDB_log', SIZE = 524288KB )
GO


DROP TABLE IF EXISTS [dbo].[Person];
GO

CREATE TABLE [dbo].[Person](
	[BusinessEntityID] [int] NOT NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[LastName] [nvarchar](50) NOT NULL,
	[Filler]  [char](100)
CONSTRAINT [PK_Person] PRIMARY KEY CLUSTERED 
	(
		[BusinessEntityID] ASC
	)
);
GO




INSERT INTO Person  (BusinessEntityID,FirstName,LastName)
SELECT BusinessEntityID,FirstName,LastName
FROM AdventureWorks2008.Person.Person
GO


SELECT DB_NAME(database_id) AS Database_Name,
       OBJECT_NAME(ios.object_id,database_id) AS TableName,
	   i.name AS IndexName,
  	   ios.[row_lock_count] ,
	   ios.[row_lock_wait_count] ,
	   ios.[row_lock_wait_in_ms] 
FROM sys.dm_db_index_operational_stats(DB_ID(),object_id('person'),null,null) ios
INNER JOIN sys.indexes i on i.index_id = ios.index_id and i.object_id=ios.object_id;
GO
/*
Database_Name	TableName	IndexName	row_lock_count	row_lock_wait_count	row_lock_wait_in_ms
DemoDB   		Person		PK_Person	114				0					0
*/



CHECKPOINT
GO
SELECT * FROM fn_dblog(null,null);
GO


-- Session 1
BEGIN TRAN BlockingTransaction
	UPDATE Person
	SET Filler = 'Update -- Session 1'
	WHERE BusinessEntityID = 1

	SELECT * FROM sys.dm_exec_session_wait_stats WHERE session_id = @@spid
	ORDER BY wait_time_ms DESC;	

-- Session 2
UPDATE Person
SET Filler = 'Update -- Session 2'
WHERE BusinessEntityID = 1;

-- cancel query and run
SELECT * FROM sys.dm_exec_session_wait_stats WHERE session_id in (53,59)
ORDER BY wait_time_ms DESC;	


-- Session 3 : show locks ...
/*	
	
	SELECT * FROM sys.dm_exec_requests
	SELECT * FROM sys.dm_exec_sessions
	SELECT * FROM sys.dm_os_waiting_tasks
	SELECT * FROM sys.dm_tran_locks
	SELECT * FROM .dm_exec_sql_text()
	SELECT * FROM sys.dm_exec_query_plan()

*/


-- End Session 3


SELECT resource_type,resource_description,request_mode
FROM sys.dm_tran_locks
WHERE request_session_id = @@SPID;

-- Now rollbak the initial (blocking) transaction
ROLLBACK TRAN BlockingTransaction


SELECT DB_NAME(database_id) AS Database_Name,
       OBJECT_NAME(ios.object_id,database_id) AS TableName,
	   i.name AS IndexName,i.index_id,
  	   ios.[row_lock_count] ,
	   ios.[row_lock_wait_count] ,
	   ios.[row_lock_wait_in_ms] 
FROM sys.dm_db_index_operational_stats(DB_ID(),object_id('person'),null,null) ios
INNER JOIN sys.indexes i on i.index_id = ios.index_id and i.object_id=ios.object_id
/*
Database_Name	TableName	IndexName	row_lock_count	row_lock_wait_count	row_lock_wait_in_ms
DemoDB  		Person		PK_Person	116				1					2115938
*/




