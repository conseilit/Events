--==============================================================================
--
--  Summary:  Wait and Queues
--  Date:     03/2021
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

USE AdventureWorks
GO



SELECT 
	DB_NAME(database_id) as DatabaseName,
	OBJECT_SCHEMA_NAME(ius.object_id,database_id) as SchemaName,
	OBJECT_NAME(ius.object_id,database_id) as TableName,
	i.name as index_name,
	ius.object_id,ius.index_id,
	user_scans,user_seeks,user_lookups,
	user_scans+user_seeks+user_lookups as user_read,
	user_updates,
	i.is_primary_key,i.is_unique,i.filter_definition
FROM sys.dm_db_index_usage_stats ius
INNER JOIN sys.indexes i ON i.index_id = ius.index_id and i.object_id=ius.object_id
WHERE database_id = db_id();



SELECT 
	DB_NAME(database_id) as DatabaseName,
	OBJECT_SCHEMA_NAME(ios.object_id,database_id) as SchemaName,
	OBJECT_NAME(ios.object_id,database_id) as TableName,
	i.name as IndexName,
	ios.object_id,ios.index_id,
	forwarded_fetch_count,
	row_lock_count,row_lock_wait_count,row_lock_wait_in_ms,
	page_lock_count,page_lock_wait_count,page_lock_wait_in_ms
FROM sys.dm_db_index_operational_stats(DB_ID(),null,null,null) ios
INNER JOIN sys.tables t on t.object_id = ios.object_id
INNER JOIN sys.indexes i on i.object_id = ios.object_id and ios.index_id = i.index_id;






DROP INDEX [IX_SalesOrderDetail_ProductID]
ON [Sales].[SalesOrderDetail]
GO


SELECT *
FROM [Sales].[SalesOrderDetail]
WHERE ProductID = 777


-- SQL Server 2019 Diagnostic Information Queries
-- Glenn Berry 
-- https://glennsqlperformance.com/ 
-- Twitter: GlennAlanBerry
SELECT CONVERT(decimal(18,2), migs.user_seeks * migs.avg_total_user_cost * (migs.avg_user_impact * 0.01)) AS [index_advantage], 
FORMAT(migs.last_user_seek, 'yyyy-MM-dd HH:mm:ss') AS [last_user_seek], mid.[statement] AS [Database.Schema.Table], 
COUNT(1) OVER(PARTITION BY mid.[statement]) AS [missing_indexes_for_table], 
COUNT(1) OVER(PARTITION BY mid.[statement], mid.equality_columns) AS [similar_missing_indexes_for_table], 
mid.equality_columns, mid.inequality_columns, mid.included_columns, migs.user_seeks, 
CONVERT(decimal(18,2), migs.avg_total_user_cost) AS [avg_total_user_,cost], migs.avg_user_impact,
REPLACE(REPLACE(LEFT(st.[text], 255), CHAR(10),''), CHAR(13),'') AS [Short Query Text],
OBJECT_NAME(mid.[object_id]) AS [Table Name], p.rows AS [Table Rows]
FROM sys.dm_db_missing_index_groups AS mig WITH (NOLOCK) 
INNER JOIN sys.dm_db_missing_index_group_stats_query AS migs WITH(NOLOCK) 
ON mig.index_group_handle = migs.group_handle 
CROSS APPLY sys.dm_exec_sql_text(migs.last_sql_handle) AS st 
INNER JOIN sys.dm_db_missing_index_details AS mid WITH (NOLOCK) 
ON mig.index_handle = mid.index_handle
INNER JOIN sys.partitions AS p WITH (NOLOCK)
ON p.[object_id] = mid.[object_id]
WHERE mid.database_id = DB_ID()
AND p.index_id < 2 
ORDER BY index_advantage DESC OPTION (RECOMPILE);