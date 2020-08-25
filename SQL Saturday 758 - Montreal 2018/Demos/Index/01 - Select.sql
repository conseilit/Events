/*============================================================================
  File    :  Select   
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

CHECKPOINT
GO

DROP TABLE IF EXISTS [dbo].[Person]
GO

-- Create a table, add rows and a PK
SELECT [BusinessEntityID]
      ,[PersonType]
      ,[NameStyle]
      ,[Title]
      ,[FirstName]
      ,[MiddleName]
      ,[LastName]
      ,[Suffix]
INTO [Person]
FROM [AdventureWorks2008].[Person].[Person]
GO

ALTER TABLE dbo.Person 
ADD CONSTRAINT PK_Person PRIMARY KEY CLUSTERED 
	(BusinessEntityID)
Go
  
-- Create a NCI index on LastName column
CREATE NONCLUSTERED INDEX [NCI_Person_LastName] 
ON [Person] 
(
	[LastName] ASC 
)
GO

  
-- Include Actual Query Plan

--  Cluster Index Scan
SELECT BusinessEntityID,LastName 
FROM Person
WHERE FirstName = 'Conor'
GO


-- Cluster Index Seek
SELECT BusinessEntityID,LastName 
FROM Person
WHERE BusinessEntityID = 763
GO


-- Non Cluster Index Scan
SELECT BusinessEntityID,LastName 
FROM Person
GO


-- Non Cluster Index Seek
SELECT BusinessEntityID,LastName 
FROM Person
WHERE LastName = 'Cunningham'
GO


-- Check index usage
SELECT DB_NAME(database_id) AS Database_Name,
       OBJECT_NAME(ius.object_id,database_id) AS TableName,
	   i.name AS IndexName,
	   ius.index_id,
	   ius.user_scans,
	   ius.user_seeks,
	   ius.user_lookups,
	   ius.last_user_scan,
	   ius.last_user_seek,
	   ius.last_user_lookup
FROM sys.dm_db_index_usage_stats ius
INNER JOIN sys.indexes i on i.index_id = ius.index_id and i.object_id=ius.object_id
WHERE database_id = DB_ID()
GO
/*
Database_Name	TableName	IndexName			index_id	user_scans	user_seeks	user_lookups	last_user_scan			last_user_seek			last_user_lookup
JSS2015Demo		Person		NCI_Person_LastName	2			1			1			0				2015-11-28 16:42:37.273	2015-11-28 16:42:37.383	NULL
JSS2015Demo		Person		PK_Person			1			1			1			0				2015-11-28 16:42:36.517	2015-11-28 16:42:37.173	NULL
*/




-- Non Cluster Index Seek + Key Lookup
SELECT BusinessEntityID,LastName,FirstName 
FROM Person
WHERE LastName = 'Cunningham' or LastName = 'D''Hers'
GO
-- Key lookup output : Only the FirstName column

SELECT DB_NAME(database_id) AS Database_Name,
       OBJECT_NAME(ius.object_id,database_id) AS TableName,
	   i.name AS IndexName,
	   ius.index_id,
	   ius.user_scans,
	   ius.user_seeks,
	   ius.user_lookups,
	   ius.last_user_scan,
	   ius.last_user_seek,
	   ius.last_user_lookup
FROM sys.dm_db_index_usage_stats ius
INNER JOIN sys.indexes i on i.index_id = ius.index_id and i.object_id=ius.object_id
WHERE database_id = DB_ID()
GO
/*
Database_Name	TableName	IndexName			index_id	user_scans	user_seeks	user_lookups	last_user_scan			last_user_seek			last_user_lookup
JSS2015Demo		Person		NCI_Person_LastName	2			1			2			0				2015-11-28 16:42:37.273	2015-11-28 16:46:32.377	NULL
JSS2015Demo		Person		PK_Person			1			1			1			1				2015-11-28 16:42:36.517	2015-11-28 16:42:37.173	2015-11-28 16:46:32.377
*/
/*
   In case of multiple rows return by index seek, a single lookup operation is tracked in usage_stats
*/


-- Lookup operations may produce performance issues
-- Let's manually replay the query


-- the clustered index colum is always included 
-- in the leaf level of all non clustred index
TRUNCATE TABLE TablePages;
GO
INSERT INTO TablePages
EXEC ('DBCC IND(JSS2015Demo,Person,-1)');
GO

-- find the root page of NCI_Person_LastName
SELECT * 
FROM TablePages
WHERE indexid=3 and pagetype=2 /* index page */
ORDER BY indexlevel DESC /* Index level = 0 : leaf pages */
-- PageFID	PagePID	
--     4	248	

DBCC TRACEON(3604)

-- Root page NCI 
-- Looking for "Cunningham"
DBCC PAGE (JSS2015Demo,4,248,3)
-- FileId	PageId	Row	Level	ChildFileId	ChildPageId	LastName (key)	BusinessEntityID (key)	KeyHashValue	Row Size
--     4	248		11	  1	       3	     235	    Cox	              3636	                   NULL	            21

-- Leaft page of the NCI
DBCC PAGE (JSS2015Demo,3,235,3)
-- FileId	PageId	Row	Level	LastName (key)	BusinessEntityID (key)	KeyHashValue	Row Size
-- 3	      235	94	0	     Cunningham	      763	                (8ff72510dd4e)	32

-- Have to lookup for key 763 in the CI to add the FirstName

-- Root page clustered index
SELECT i.name,t.PageFID, PagePID,pagetype,indexlevel
FROM TablePages t
INNER JOIN sys.indexes i on i.object_id = t.objectid and i.index_id=t.indexid
WHERE pagetype=2 AND t.indexid=1
ORDER BY indexlevel DESC
GO
-- name	        PageFID	PagePID	
-- PK_Person	3	     144	 

DBCC PAGE (JSS2015Demo,3,144,3)
-- FileId	PageId	Row	Level	ChildFileId	ChildPageId	BusinessEntityID (key)	KeyHashValue	Row Size
--   3	     144	  3	  1	       4	       163	         565	                NULL	       11


DBCC PAGE (JSS2015Demo,4,163,3)
-- Find Cunningham


DBCC TRACEOFF(3604)



DROP TABLE IF EXISTS [dbo].[Person]
GO


DROP TABLE IF EXISTS [dbo].[PersonHeap]
GO


-- Check for Heaps
SELECT [BusinessEntityID]
      ,[PersonType]
      ,[NameStyle]
      ,[Title]
      ,[FirstName]
      ,[MiddleName]
      ,[LastName]
      ,[Suffix]
INTO [PersonHeap]
FROM [AdventureWorks2008].[Person].[Person]
GO

ALTER TABLE dbo.PersonHeap 
ADD CONSTRAINT PK_PersonHeap PRIMARY KEY NONCLUSTERED 
	(BusinessEntityID)
Go
 
CREATE NONCLUSTERED INDEX [NCI_PersonHeap_LastName] 
ON [PersonHeap] 
(
	[LastName] ASC 
)
GO


--  Table Scan
SELECT BusinessEntityID,LastName 
FROM PersonHeap
WHERE FirstName = 'Conor'
GO

-- Non Cluster Index Seek + RID lookup
SELECT BusinessEntityID,LastName,FirstName 
FROM PersonHeap
WHERE LastName = 'Cunningham'
GO


SELECT DB_NAME(database_id) AS Database_Name,
       OBJECT_NAME(ius.object_id,database_id) AS TableName,
	   i.name AS IndexName,
	   ius.index_id,
	   ius.user_scans,
	   ius.user_seeks,
	   ius.user_lookups,
	   ius.last_user_scan,
	   ius.last_user_seek,
	   ius.last_user_lookup
FROM sys.dm_db_index_usage_stats ius
INNER JOIN sys.indexes i on i.index_id = ius.index_id and i.object_id=ius.object_id
WHERE database_id = DB_ID()
  AND ius.object_id =  object_id('dbo.PersonHeap')
GO
/*
Database_Name	TableName	IndexName				index_id	user_scans	user_seeks	user_lookups	last_user_scan			last_user_seek			last_user_lookup
JSS2015Demo		PersonHeap	NULL					0			1			0			1				2015-11-28 16:52:14.367	NULL					2015-11-28 16:52:14.453
JSS2015Demo		PersonHeap	NCI_PersonHeap_LastName	3			0			1			0				NULL					2015-11-28 16:52:14.453	NULL
*/




TRUNCATE TABLE TablePages;
GO
INSERT INTO TablePages
EXEC ('DBCC IND(JSS2015Demo,PersonHeap,-1)');
GO

-- manually replay the query

-- find the root page of the NCI
SELECT i.name,t.PageFID, PagePID,pagetype,indexlevel
FROM TablePages t
INNER JOIN sys.indexes i on i.object_id = t.objectid and i.index_id=t.indexid
WHERE pagetype=2 AND i.name = 'NCI_PersonHeap_LastName'
ORDER BY indexlevel DESC
GO

DBCC TRACEON(3604)

-- Explore the root page NCI
DBCC PAGE (JSS2015Demo,4,480,3)
--FileId	PageId	Row	Level	ChildFileId	ChildPageId	LastName (key)	HEAP RID (key)	     KeyHashValue	Row Size
--     4	480		12	   1	    3	     460	    Cook	         0x2001000003002400	  NULL	          27

DBCC PAGE (JSS2015Demo,3,460,3)
-- FileId	PageId	Row	Level	LastName (key)	HEAP RID (key)	    KeyHashValue	Row Size
--     3	460		295	0	    Cunningham	    0x1B01000003006300	(cfc1dec74a28)	36
-- Slot Hex 0063 -> Dec 99
-- File Hex 0003 -> Dec 3
-- Page Hex 011B -> Dec 283

SELECT dbo.HexToINT ('011B')

-- Find slot 99
DBCC PAGE (JSS2015Demo,3,283,2)
/*
99 (0x63) - 6002 (0x1772)
*/

-- Find offset 0x1772
DBCC PAGE (JSS2015Demo,3,283,3)


DBCC TRACEOFF(3604)

-- cleanup
TRUNCATE TABLE TablePages;
GO
DROP TABLE IF EXISTS dbo.PersonHeap;
GO
DROP TABLE IF EXISTS dbo.Person;
GO


/*
sys.dm_db_index_usage_stats : statistiques d'utilisation
 SEEK
 SCAN 
 LOOKUP

Quels sont les index les plus utilisés.
Comment sont utilisés les index
*/