/*============================================================================
  File    :  Lock   
  Summary :  
  Date    :  11/2015
  SQL Server Versions: 13 (SS2016CTP3)
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




USE JSS2015Demo
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
       OBJECT_NAME(ius.object_id,database_id) AS TableName,
	   i.name AS IndexName,i.index_id,
	   ius.user_scans,ius.user_seeks,ius.user_lookups,
	   ius.user_updates,ius.last_user_update
FROM sys.dm_db_index_usage_stats ius
INNER JOIN sys.indexes i on i.index_id = ius.index_id and i.object_id=ius.object_id
WHERE database_id = DB_ID();
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
Database_Name	TableName	IndexName	index_id	user_scans	user_seeks	user_lookups	user_updates	last_user_update
JSS2015Demo		Person		PK_Person	1			0			0			0				1				2015-11-20 13:59:30.840

Database_Name	TableName	IndexName	row_lock_count	row_lock_wait_count	row_lock_wait_in_ms
JSS2015Demo		Person		PK_Person	114				0					0
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
	

-- Session 2
UPDATE Person
SET Filler = 'Update -- Session 2'
WHERE BusinessEntityID = 1;
	

-- Session 3 : show locks ...
/*	
	
	SELECT * FROM sys.dm_exec_requests
	SELECT * FROM sys.dm_exec_sessions
	SELECT * FROM sys.dm_os_waiting_tasks
	SELECT * FROM sys.dm_tran_locks
	SELECT * FROM .dm_exec_sql_text()
	SELECT * FROM sys.dm_exec_query_plan()

*/

/*********************************************************************************************
Who Is Active? v11.11 (2012-03-22)
(C) 2007-2012, Adam Machanic

Feedback: mailto:amachanic@gmail.com
Updates: http://sqlblog.com/blogs/adam_machanic/archive/tags/who+is+active/default.aspx
"Beta" Builds: http://sqlblog.com/files/folders/beta/tags/who+is+active/default.aspx

Donate! Support this project: http://tinyurl.com/WhoIsActiveDonate

License: 
	Who is Active? is free to download and use for personal, educational, and internal 
	corporate purposes, provided that this header is preserved. Redistribution or sale 
	of Who is Active?, in whole or in part, is prohibited without the author's express 
	written consent.
*********************************************************************************************/
EXEC  sp_whoisactive @show_sleeping_spids =1,
				@get_task_info=2,
				@get_additional_info =1,
				@get_full_inner_text = 1,	
				@get_outer_command = 1,
				@get_locks = 1,
				@find_block_leaders = 1,
				@get_plans = 1;

-- End Session 3


SELECT resource_type,resource_description,request_mode
FROM sys.dm_tran_locks
WHERE request_session_id = @@SPID;
/*
resource_type	resource_description	request_mode
DATABASE	                            S
PAGE			4:8376               	IX
OBJECT	                                IX
KEY				(8194443284a0)			X
OBJECT	     							IX  
*/



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
JSS2015Demo		Person		PK_Person	116				1					2115938
*/


DECLARE @TransactionID CHAR (20) 
SELECT @TransactionID = [Transaction ID] 
FROM fn_dblog (null, null) WHERE [Transaction Name]='BlockingTransaction' 

SELECT [Current LSN],[Operation],[Context],[Transaction ID],
		[Page ID],[Slot ID],[Transaction Name],[Begin Time],[End Time],
		[Number of Locks],Description,[Lock Information]
FROM fn_dblog (null, null) WHERE [Transaction ID] = @TransactionID; 
GO
/*
HoBt 72057594045530112:
ACQUIRE_LOCK_IX OBJECT: 8:258099960:0 ;
ACQUIRE_LOCK_IX PAGE:   8:4:8376 ;
ACQUIRE_LOCK_X  KEY:    8:72057594045530112 (8194443284a0)
*/

SELECT OBJECT_NAME(object_id) as TableName, * 
FROM sys.partitions
WHERE partition_id = 72057594045530112;



DBCC TRACEON(3604)
DBCC PAGE(JSS2015Demo,4,8376,3)
/*
KeyHashValue = (8194443284a0)  
*/




