/*============================================================================
  File    :  Lock Escalation   
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

DROP TABLE IF EXISTS SalesOrderDetail
GO

SELECT *
INTO SalesOrderDetail
FROM AdventureWorks2008.Sales.SalesOrderDetail;
GO

CREATE CLUSTERED INDEX NCI_SalesOrderDetail_SalesOrderDetailID
ON SalesOrderDetail(SalesOrderDetailID);
GO


CHECKPOINT
GO


SELECT *
FROM SalesOrderDetail
GO

SELECT DB_NAME(database_id) AS Database_Name,
       OBJECT_NAME(ius.object_id,database_id) AS TableName,
	   i.name AS IndexName,i.index_id,
	   ius.user_seeks,user_scans,user_lookups,user_updates
FROM sys.dm_db_index_usage_stats ius
INNER JOIN sys.indexes i on i.index_id = ius.index_id and i.object_id=ius.object_id
WHERE database_id = DB_ID() AND ius.object_id = OBJECT_ID('SalesOrderDetail');
GO
/*
Database_Name	TableName			IndexName									index_id	user_seeks	user_scans	user_lookups	user_updates
JSS2015Demo		SalesOrderDetail	NCI_SalesOrderDetail_SalesOrderDetailID		1			0			1			0				0
*/

SELECT DB_NAME(database_id) AS Database_Name,
       OBJECT_NAME(ios.object_id,database_id) AS TableName,
	   i.name AS IndexName,i.index_id,
	   ios.partition_number,
	   ios.row_lock_count , ios.row_lock_wait_count,
	   ios.page_lock_count,ios.page_lock_wait_count,
  	   ios.index_lock_promotion_attempt_count ,
	   ios.index_lock_promotion_count
FROM sys.dm_db_index_operational_stats(DB_ID(),object_id('SalesOrderDetail'),1,null) ios
INNER JOIN sys.indexes i on i.index_id = ios.index_id and i.object_id=ios.object_id;
GO
/*
Database_Name	TableName			IndexName									index_id	partition_number	row_lock_count	row_lock_wait_count	page_lock_count	page_lock_wait_count	index_lock_promotion_attempt_count	index_lock_promotion_count
JSS2015Demo		SalesOrderDetail	NCI_SalesOrderDetail_SalesOrderDetailID		1			1					0				0					1507			0						0									0
*/

BEGIN TRAN
	UPDATE SalesOrderDetail 
	SET ProductID = ProductID
	WHERE SalesOrderDetailID <= 20000;
	
	SELECT COUNT(*) as NbLocks
	FROM sys.dm_tran_locks
	WHERE request_session_id = @@SPID;
	
	SELECT COUNT(*) as NbLocks,resource_type
	FROM sys.dm_tran_locks
	WHERE request_session_id = @@SPID
	GROUP BY resource_type;
	
	SELECT resource_type,db_name(resource_database_id) as ObectNameName,
		    CASE resource_type
			 WHEN 'KEY' THEN  
				( SELECT object_name(object_id)
					FROM sys.dm_db_partition_stats
					WHERE partition_id= resource_associated_entity_id
				)
			 WHEN 'PAGE' THEN  
				( SELECT object_name(object_id)
					FROM sys.dm_db_partition_stats
					WHERE partition_id= resource_associated_entity_id
				)
			 ELSE object_name(resource_associated_entity_id)
			END	 as TableName,
	       --resource_associated_entity_id,
	       request_mode,request_type,request_session_id 
 	FROM sys.dm_tran_locks
	WHERE request_session_id = @@SPID

ROLLBACK
-- 20 000 Records 

/*
NbLocks	resource_type
1		DATABASE
1		OBJECT

resource_type	ObectNameName	TableName			request_mode	request_type	request_session_id
DATABASE		JSS2015Demo		NULL				S				LOCK			57
OBJECT			JSS2015Demo		SalesOrderDetail	X				LOCK			57

*/

SELECT DB_NAME(database_id) AS Database_Name,
       OBJECT_NAME(ius.object_id,database_id) AS TableName,
	   i.name AS IndexName,i.index_id,
	   ius.user_seeks,user_scans,user_lookups,user_updates
FROM sys.dm_db_index_usage_stats ius
INNER JOIN sys.indexes i on i.index_id = ius.index_id and i.object_id=ius.object_id
WHERE database_id = DB_ID() AND ius.object_id = OBJECT_ID('SalesOrderDetail');
GO

SELECT DB_NAME(database_id) AS Database_Name,
       OBJECT_NAME(ios.object_id,database_id) AS TableName,
	   i.name AS IndexName,i.index_id,
	   ios.partition_number,
	   ios.row_lock_count , ios.row_lock_wait_count,
	   ios.page_lock_count,ios.page_lock_wait_count,
  	   ios.index_lock_promotion_attempt_count ,
	   ios.index_lock_promotion_count
FROM sys.dm_db_index_operational_stats(DB_ID(),object_id('SalesOrderDetail'),1,null) ios
INNER JOIN sys.indexes i on i.index_id = ios.index_id and i.object_id=ios.object_id;
GO
/*
Database_Name	TableName			IndexName									index_id	partition_number	row_lock_count	row_lock_wait_count	page_lock_count	page_lock_wait_count	index_lock_promotion_attempt_count	index_lock_promotion_count
JSS2015Demo		SalesOrderDetail	NCI_SalesOrderDetail_SalesOrderDetailID		1			1					6164			0					1591			0						4									1
*/

-- What happends if lock escalation is disabled ?
ALTER TABLE SalesOrderDetail SET (LOCK_ESCALATION = DISABLE);


BEGIN TRAN
	UPDATE SalesOrderDetail 
	SET ProductID = ProductID
	WHERE SalesOrderDetailID <= 20000;
	
	SELECT COUNT(*) as NbLocks
	FROM sys.dm_tran_locks
	WHERE request_session_id = @@SPID;
	
	SELECT COUNT(*) as NbLocks,resource_type
	FROM sys.dm_tran_locks
	WHERE request_session_id = @@SPID
	GROUP BY resource_type;
	
	SELECT resource_type,db_name(resource_database_id) as ObectNameName,
		    CASE resource_type
			 WHEN 'KEY' THEN  
				( SELECT object_name(object_id)
					FROM sys.dm_db_partition_stats
					WHERE partition_id= resource_associated_entity_id
				)
			 WHEN 'PAGE' THEN  
				( SELECT object_name(object_id)
					FROM sys.dm_db_partition_stats
					WHERE partition_id= resource_associated_entity_id
				)
			 ELSE object_name(resource_associated_entity_id)
			END	 as TableName,
	       --resource_associated_entity_id,
	       request_mode,request_type,request_session_id 
 	FROM sys.dm_tran_locks
	WHERE request_session_id = @@SPID

ROLLBACK
/*
NbLocks		resource_type
1			DATABASE
20000		KEY
1			OBJECT
274			PAGE	
*/


SELECT DB_NAME(database_id) AS Database_Name,
       OBJECT_NAME(ius.object_id,database_id) AS TableName,
	   i.name AS IndexName,i.index_id,
	   ius.user_seeks,user_scans,user_lookups,user_updates
FROM sys.dm_db_index_usage_stats ius
INNER JOIN sys.indexes i on i.index_id = ius.index_id and i.object_id=ius.object_id
WHERE database_id = DB_ID() AND ius.object_id = OBJECT_ID('SalesOrderDetail');
GO

SELECT DB_NAME(database_id) AS Database_Name,
       OBJECT_NAME(ios.object_id,database_id) AS TableName,
	   i.name AS IndexName,i.index_id,
	   ios.partition_number,
	   ios.row_lock_count , ios.row_lock_wait_count,
	   ios.page_lock_count,ios.page_lock_wait_count,
  	   ios.index_lock_promotion_attempt_count ,
	   ios.index_lock_promotion_count
FROM sys.dm_db_index_operational_stats(DB_ID(),object_id('SalesOrderDetail'),1,null) ios
INNER JOIN sys.indexes i on i.index_id = ios.index_id and i.object_id=ios.object_id;
GO
/*
Database_Name	TableName			IndexName								index_id	partition_number	row_lock_count	row_lock_wait_count	page_lock_count	page_lock_wait_count	index_lock_promotion_attempt_count	index_lock_promotion_count
JSS2015Demo		SalesOrderDetail	NCI_SalesOrderDetail_SalesOrderDetailID	1			1					26164			0					1865			0						4									1
*/

-- Back to default behaviour
ALTER TABLE SalesOrderDetail SET (LOCK_ESCALATION = TABLE);





-- What about paritioned tables ?

CREATE PARTITION FUNCTION [fn_Partition](int) 
AS RANGE RIGHT FOR VALUES (N'10000', N'20000', N'30000', N'40000', N'50000');
GO

CREATE PARTITION SCHEME [sch_partition] 
AS PARTITION [fn_Partition] TO ([DATA], [DATA], [DATA], [DATA], [DATA], [DATA]);
GO

DROP INDEX NCI_SalesOrderDetail_SalesOrderDetailID 
	ON [dbo].[SalesOrderDetail];
GO

CREATE CLUSTERED INDEX [CIP_SalesOrderDetail_SalesOrderDetailID] 
ON [dbo].[SalesOrderDetail] 
(
	SalesOrderDetailID
) ON [sch_partition]([SalesOrderDetailID]);
GO


-- Partitions informations
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
ORDER BY p.partition_number

-- mandatory to use HoBT locking granularity
ALTER TABLE SalesOrderDetail SET (LOCK_ESCALATION = AUTO);


CHECKPOINT;
GO


BEGIN TRAN LockEscalationTransaction
	UPDATE SalesOrderDetail 
	SET ProductID = ProductID
	WHERE SalesOrderDetailID <= 8000; -- Tablock => HOBT Lock

	SELECT COUNT(*) as NbLocks
	FROM sys.dm_tran_locks
	WHERE request_session_id = @@SPID;
	
	SELECT COUNT(*) as NbLocks,resource_type
	FROM sys.dm_tran_locks
	WHERE request_session_id = @@SPID
	GROUP BY resource_type;

	SELECT resource_type,db_name(resource_database_id) as ObectNameName,
		    CASE resource_type
			 WHEN 'KEY' THEN  
				( SELECT object_name(object_id)
					FROM sys.dm_db_partition_stats
					WHERE partition_id= resource_associated_entity_id
				)
			 WHEN 'PAGE' THEN  
				( SELECT object_name(object_id)
					FROM sys.dm_db_partition_stats
					WHERE partition_id= resource_associated_entity_id
				)
			 WHEN 'HOBT' THEN  
				( SELECT object_name(object_id)
					FROM sys.dm_db_partition_stats
					WHERE partition_id= resource_associated_entity_id
				)
			 ELSE object_name(resource_associated_entity_id)
			END	 as TableName,
	       request_mode,request_type,request_session_id 
	FROM sys.dm_tran_locks
	WHERE request_session_id = @@SPID;
	GO
	
	-- List of partitions
	SELECT [partition_id], [object_id], [index_id], [partition_number]
	FROM sys.partitions WHERE object_id = OBJECT_ID ('SalesOrderDetail');

	-- IX Lock on Object
	SELECT [resource_type], [resource_associated_entity_id], [request_mode],
           [request_type], [request_status] 
    FROM sys.dm_tran_locks 
    WHERE [resource_type] <> 'DATABASE';


	-- All in One query
	SELECT [resource_type], [resource_associated_entity_id], [request_mode],
           [request_type], [request_status],[partition_id], Object_name([object_id]) As [Table name], [index_id], [partition_number] 
    FROM sys.dm_tran_locks  AS dtl
    INNER JOIN sys.partitions as p on p.partition_id = dtl.resource_associated_entity_id
    WHERE [resource_type] <> 'DATABASE'
    AND object_id = OBJECT_ID ('SalesOrderDetail');
	
ROLLBACK TRAN LockEscalationTransaction
/*
resource_type	resource_associated_entity_id	request_mode	request_type	request_status	partition_id		Table name			index_id	partition_number
HOBT			72057594045071360				X				LOCK			GRANT			72057594045071360	SalesOrderDetail	1			1
*/



SELECT DB_NAME(database_id) AS Database_Name,
       OBJECT_NAME(ius.object_id,database_id) AS TableName,
	   i.name AS IndexName,i.index_id,
	   ius.user_seeks,user_scans,user_lookups,user_updates
FROM sys.dm_db_index_usage_stats ius
INNER JOIN sys.indexes i on i.index_id = ius.index_id and i.object_id=ius.object_id
WHERE database_id = DB_ID() AND ius.object_id = OBJECT_ID('SalesOrderDetail');
GO

SELECT DB_NAME(database_id) AS Database_Name,
       OBJECT_NAME(ios.object_id,database_id) AS TableName,
	   i.name AS IndexName,i.index_id,
	   ios.partition_number,
	   ios.row_lock_count , ios.row_lock_wait_count,
	   ios.page_lock_count,ios.page_lock_wait_count,
  	   ios.index_lock_promotion_attempt_count ,
	   ios.index_lock_promotion_count
FROM sys.dm_db_index_operational_stats(DB_ID(),object_id('SalesOrderDetail'),1,null) ios
INNER JOIN sys.indexes i on i.index_id = ios.index_id and i.object_id=ios.object_id;
GO
/*
Database_Name	TableName			IndexName								index_id	partition_number	row_lock_count	row_lock_wait_count	page_lock_count	page_lock_wait_count	index_lock_promotion_attempt_count	index_lock_promotion_count
JSS2015Demo		SalesOrderDetail	CIP_SalesOrderDetail_SalesOrderDetailID	1			1					12327			0					168				0						4									1
JSS2015Demo		SalesOrderDetail	CIP_SalesOrderDetail_SalesOrderDetailID	1			2					0				0					0				0						0									0
JSS2015Demo		SalesOrderDetail	CIP_SalesOrderDetail_SalesOrderDetailID	1			3					0				0					0				0						0									0
JSS2015Demo		SalesOrderDetail	CIP_SalesOrderDetail_SalesOrderDetailID	1			4					0				0					0				0						0									0
JSS2015Demo		SalesOrderDetail	CIP_SalesOrderDetail_SalesOrderDetailID	1			5					0				0					0				0						0									0
JSS2015Demo		SalesOrderDetail	CIP_SalesOrderDetail_SalesOrderDetailID	1			6					0				0					0				0						0									0
*/




DECLARE @TransactionID CHAR (20) 
SELECT @TransactionID = [Transaction ID] 
FROM fn_dblog (null, null) WHERE [Transaction Name]='LockEscalationTransaction'; 

SELECT [Current LSN],[Operation],[Context],[Transaction ID],
		[Page ID],[Slot ID],[Transaction Name],[Begin Time],[End Time],
		[Number of Locks],Description,[Lock Information]
FROM fn_dblog (null, null) WHERE [Transaction ID] = @TransactionID; 
GO
/*
HoBt 72057594045071360:ESCALATE_LOCKS HOBT: 8:72057594045071360 
*/


