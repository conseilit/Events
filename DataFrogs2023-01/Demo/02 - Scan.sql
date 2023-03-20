--============================================================================
--  
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
--
--============================================================================

-- Include Actual Execution plan  

USE [AdventureWorks2017]
GO


-- Table Scan
SELECT * 
FROM [dbo].[DatabaseLog];
GO

SELECT 
	DB_NAME(database_id) as DatabaseName,
	OBJECT_SCHEMA_NAME(ius.object_id,database_id) as SchemaName,
	OBJECT_NAME(ius.object_id,database_id) as TableName,
	i.name as index_name,ius.object_id,ius.index_id,
	user_scans,user_seeks,user_lookups,user_updates,
	ius.last_user_scan,ius.last_user_seek,ius.last_user_lookup
FROM sys.dm_db_index_usage_stats ius
INNER JOIN sys.indexes i ON i.index_id = ius.index_id AND i.object_id=ius.object_id
WHERE database_id = db_id()
and ius.object_id = OBJECT_ID('DatabaseLog');


-- Clustered Index Scan
SELECT * 
FROM [Sales].[SalesOrderHeader];
GO

SELECT 
	DB_NAME(database_id) as DatabaseName,
	OBJECT_SCHEMA_NAME(ius.object_id,database_id) as SchemaName,
	OBJECT_NAME(ius.object_id,database_id) as TableName,
	i.name as index_name,ius.object_id,ius.index_id,
	user_scans,user_seeks,user_lookups,user_updates,
	ius.last_user_scan,ius.last_user_seek,ius.last_user_lookup
FROM sys.dm_db_index_usage_stats ius
INNER JOIN sys.indexes i ON i.index_id = ius.index_id AND i.object_id=ius.object_id
WHERE database_id = db_id()
and ius.object_id = OBJECT_ID('sales.SalesOrderHeader');



-- NonClustered Index Scan
SELECT AddressLine1, AddressLine2, PostalCode, City 
FROM [Person].[Address]
GO


SELECT 
	DB_NAME(database_id) as DatabaseName,
	OBJECT_SCHEMA_NAME(ius.object_id,database_id) as SchemaName,
	OBJECT_NAME(ius.object_id,database_id) as TableName,
	i.name as index_name,ius.object_id,ius.index_id,
	user_scans,user_seeks,user_lookups,user_updates,
	ius.last_user_scan,ius.last_user_seek,ius.last_user_lookup
FROM sys.dm_db_index_usage_stats ius
INNER JOIN sys.indexes i ON i.index_id = ius.index_id AND i.object_id=ius.object_id
WHERE database_id = db_id()
and ius.object_id = OBJECT_ID('Person.Address');



