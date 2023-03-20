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

-- Find NonClustered Index Seek data pages
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE /* REPEATABLE READ */;
SET STATISTICS IO ON;

-- Output redirection
DBCC TRACEON(3604)

-- Include Actual Execution plan

USE [AdventureWorks2017]
GO


GO
BEGIN TRAN

	SELECT SalesOrderID, CustomerID  
	FROM [Sales].[SalesOrderHeader] 
	WHERE CustomerID  = 11002;

	SELECT 
		CASE resource_type
            WHEN 'PAGE' THEN CONCAT ('DBCC PAGE (''AdventureWorks2017'',',SUBSTRING(resource_description,1,1),',',SUBSTRING(resource_description,3,LEN(resource_description)),',3)')
            ELSE ''
        END as CommandText

		,* 
	FROM sys.dm_tran_locks
	WHERE /*resource_type = 'PAGE'
	  AND */request_session_id = @@SPID
ROLLBACK

-- Here are the 3 records in the leaf pages of the nonclustered index
DBCC PAGE ('AdventureWorks2017',1,7256  ,3)
/*
1	7256	6	0	11002	43736	(dfd038d85b9f)	12
1	7256	7	0	11002	51238	(888ee458692b)	12
1	7256	8	0	11002	53237	(5b740c7fbbfb)	12
*/


-- Get information about the datapage
SELECT
	 allocated_page_file_id AS PageFID
	,allocated_page_page_id AS PagePID
	,allocated_page_iam_file_id AS IAMFID
	,allocated_page_iam_page_id AS IAMPID
	,object_id AS ObjectID
	,index_id AS IndexID
	,partition_id AS PartitionNumber
	,rowset_id AS PartitionID
	,allocation_unit_type_desc AS iam_chain_type
	,page_type AS PageType
	,page_level AS IndexLevel
	,next_page_file_id AS NextPageFID
	,next_page_page_id AS NextPagePID
	,previous_page_file_id AS PrevPageFID
	,previous_page_page_id AS PrevPagePID
FROM sys.dm_db_database_page_allocations(DB_ID(), OBJECT_ID('Sales.SalesOrderHeader'), NULL, NULL, 'DETAILED')
WHERE is_allocated = 1
  AND allocated_page_page_id = 7256;


-- We are using the index ID 4
SELECT object_name(1922105888) as TableName,name as IndexName
from sys.indexes
WHERE object_id = 1922105888
  AND index_id = 4

-- Find the nonclustered index root page
SELECT
	 allocated_page_file_id AS PageFID
	,allocated_page_page_id AS PagePID
	,object_id AS ObjectID
	,index_id AS IndexID
	,partition_id AS PartitionNumber
	,page_type AS PageType
	,page_level AS IndexLevel
	,next_page_file_id AS NextPageFID
	,next_page_page_id AS NextPagePID
	,previous_page_file_id AS PrevPageFID
	,previous_page_page_id AS PrevPagePID
FROM sys.dm_db_database_page_allocations(DB_ID(), OBJECT_ID('Sales.SalesOrderHeader'), 4, NULL, 'DETAILED')
WHERE is_allocated = 1
ORDER BY page_level DESC

-- Show NCI root page
DBCC PAGE ('AdventureWorks2017',1,7496  ,3)

-- Looking for CustomerID 11002
-- Child Page 7256
-- as seen previously


-- let's add the OrderDate column
BEGIN TRAN

	SELECT SalesOrderID, CustomerID, OrderDate  
	FROM [Sales].[SalesOrderHeader] 
	WHERE CustomerID  = 11002;

	SELECT 
		CASE resource_type
            WHEN 'PAGE' THEN CONCAT ('DBCC PAGE (''AdventureWorks2017'',',SUBSTRING(resource_description,1,1),',',SUBSTRING(resource_description,3,LEN(resource_description)),',3)')
            ELSE ''
        END as CommandText
		,* 
	FROM sys.dm_tran_locks tl
	WHERE request_session_id = @@SPID
	  AND resource_associated_entity_id = (select partition_id from sys.partitions 
										   where object_id = object_id('Sales.SalesOrderHeader')
										     and index_id = 1
										  )

ROLLBACK

-- We are using different data pages than the nonclustered index seek

/*
PAGE	6	1:16601                                                                                                                                                                                                                                                         
KEY		6	(a4265c09389f)                                                                                                                                                                                                                                                  
PAGE	6	1:2853                                                                                                                                                                                                                                                          
PAGE	6	1:3240                                                                                                                                                                                                                                                          
KEY		6	(208268aed8fb)                                                                                                                                                                                                                                                  
KEY		6	(77dcb42eea4f)                                                                                                                                                                                                                                                  
*/

-- The page 16601 contains the record for SalesOrderID = 43736
DBCC PAGE ('AdventureWorks2017',1,16601  ,3)


-- Find the clustered index root page
SELECT
	 allocated_page_file_id AS PageFID
	,allocated_page_page_id AS PagePID
	,object_id AS ObjectID
	,index_id AS IndexID
	,partition_id AS PartitionNumber
	,page_type AS PageType
	,page_level AS IndexLevel
	,next_page_file_id AS NextPageFID
	,next_page_page_id AS NextPagePID
	,previous_page_file_id AS PrevPageFID
	,previous_page_page_id AS PrevPagePID
FROM sys.dm_db_database_page_allocations(DB_ID(), OBJECT_ID('Sales.SalesOrderHeader'), 1, NULL, 'DETAILED')
WHERE is_allocated = 1
ORDER BY page_level DESC

/*
1	16416	1922105888	1	1	2	2	NULL	NULL	NULL	NULL
1	2976	1922105888	1	1	2	1	NULL	NULL	1	3000
1	3000	1922105888	1	1	2	1	1	2976	NULL	NULL
*/

-- Find enreg 43736 in the root page
DBCC PAGE ('AdventureWorks2017',1,16416  ,3)
/*
1	16416	0	2	1	3000	NULL	NULL	11
1	16416	1	2	1	2976	71190	NULL	11
*/

-- Find enreg 43736 in the intermediate level page
DBCC PAGE ('AdventureWorks2017',1,3000  ,3)
/*
1	3000	0	1	1	16600	NULL	NULL	11
1	3000	1	1	1	16601	43700	NULL	11
1	3000	2	1	1	16602	43747	NULL	11
*/

-- Same result : Data Page 16601 contains the record dor SalesOrderId = 43736

-- So 3 reads to lookup ONE record
-- Root          : 16416
--  Intermediate : 3000
--    Leaf Level : 16601
