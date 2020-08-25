/*============================================================================
  File    :  Update   
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

-- /!\ Non Cluster PK !!!!!!
CREATE TABLE [dbo].[Person](
	[BusinessEntityID] [int] NOT NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[LastName] [nvarchar](50) NOT NULL,
	Filler [nvarchar] (500)  NULL,
CONSTRAINT [PK_Person] PRIMARY KEY NONCLUSTERED 
	(
		[BusinessEntityID] ASC
	)
) 
GO


INSERT INTO Person (BusinessEntityID,FirstName,LastName)
SELECT BusinessEntityID,FirstName,LastName
FROM AdventureWorks2008.Person.Person
GO


SELECT DB_NAME(database_id) AS Database_Name,
       OBJECT_NAME(ips.object_id,database_id) AS TableName,
	   i.name AS IndexName,i.index_id,
	   ips.index_type_desc,ips.index_depth,ips.index_level,
	   ips.page_count,ips.avg_page_space_used_in_percent,ips.record_count,
	   ips.avg_record_size_in_bytes,ips.forwarded_record_count
FROM sys.dm_db_index_physical_stats(DB_ID(),object_id('dbo.Person'),null,null,'detailed')  ips
INNER JOIN sys.indexes i on i.index_id = ips.index_id and i.object_id=ips.object_id;
GO

SELECT DB_NAME(database_id) AS Database_Name,
       OBJECT_NAME(ius.object_id,database_id) AS TableName,
	   i.name AS IndexName,i.index_id,
	   ius.user_updates,ius.last_user_update
FROM sys.dm_db_index_usage_stats ius
INNER JOIN sys.indexes i on i.index_id = ius.index_id and i.object_id=ius.object_id
WHERE database_id = DB_ID() AND i.object_id = object_id('dbo.Person');
GO
-- Database_Name	TableName	IndexName	index_id	user_updates	last_user_update
-- JSS2015Demo		Person		NULL		0			1				2015-11-14 16:06:33.217
-- JSS2015Demo		Person		PK_Person	2			1				2015-11-14 16:06:33.217

SELECT DB_NAME(database_id) AS Database_Name,
       OBJECT_NAME(ios.object_id,database_id) AS TableName,
	   i.name AS IndexName,i.index_id,
	   ios.leaf_allocation_count,leaf_insert_count,leaf_update_count,nonleaf_allocation_count,nonleaf_update_count,forwarded_fetch_count
FROM sys.dm_db_index_operational_stats(DB_ID(),object_id('person'),null,null) ios
INNER JOIN sys.indexes i on i.index_id = ios.index_id and i.object_id=ios.object_id;
GO
/*
Database_Name	TableName	IndexName	index_id	leaf_allocation_count	leaf_insert_count	leaf_update_count	nonleaf_allocation_count	nonleaf_update_count	forwarded_fetch_count
JSS2015Demo		Person		NULL		0			104						19972				0					0							0						0
JSS2015Demo		Person		PK_Person	2			1						19972				0					1							0						0
*/






/*
######################################################
#
#           Question soirée Explorer
#
#######################################################
*/

-- BusinessEntityID is Primary Key => unique & not null
-- Will this request return an error or not ?
UPDATE Person
SET BusinessEntityID = BusinessEntityID + 1
GO






















SELECT DB_NAME(database_id) AS Database_Name,
       OBJECT_NAME(ips.object_id,database_id) AS TableName,
	   i.name AS IndexName,i.index_id,
	   ips.index_type_desc,ips.index_depth,ips.index_level,
	   ips.page_count,ips.avg_page_space_used_in_percent,ips.record_count,
	   ips.avg_record_size_in_bytes,ips.forwarded_record_count
FROM sys.dm_db_index_physical_stats(DB_ID(),object_id('dbo.Person'),null,null,'detailed')  ips
INNER JOIN sys.indexes i on i.index_id = ips.index_id and i.object_id=ips.object_id



SELECT DB_NAME(database_id) AS Database_Name,
       OBJECT_NAME(ius.object_id,database_id) AS TableName,
	   i.name AS IndexName,i.index_id,
	   ius.user_updates,ius.last_user_update
FROM sys.dm_db_index_usage_stats ius
INNER JOIN sys.indexes i on i.index_id = ius.index_id and i.object_id=ius.object_id
WHERE database_id = DB_ID() AND i.object_id = object_id('dbo.Person');
/*
Database_Name	TableName	IndexName	index_id	user_updates	last_user_update
JSS2015Demo		Person		PK_Person	2			2				2015-11-28 18:36:34.737
JSS2015Demo		Person		NULL		0			2				2015-11-28 18:36:34.737
*/

SELECT DB_NAME(database_id) AS Database_Name,
       OBJECT_NAME(ios.object_id,database_id) AS TableName,
	   i.name AS IndexName,i.index_id,
	   ios.leaf_allocation_count,leaf_update_count,nonleaf_allocation_count,nonleaf_update_count,forwarded_fetch_count
FROM sys.dm_db_index_operational_stats(DB_ID(),object_id('person'),null,null) ios
INNER JOIN sys.indexes i on i.index_id = ios.index_id and i.object_id=ios.object_id
/*
Database_Name	TableName	IndexName	index_id	leaf_allocation_count	leaf_update_count	nonleaf_allocation_count	nonleaf_update_count	forwarded_fetch_count
JSS2015Demo		Person		NULL		0			104						19972				0							0						0
JSS2015Demo		Person		PK_Person	2			1						19166				1							0						0
*/

-- One more usage_stats.user_update & 19972 operational_stats.leaf_update_count


DBCC IND(JSS2015Demo,Person,-1)

DBCC TRACEON(3604)
DBCC PAGE (JSS2015Demo,4,26160,3)
/*
Slot 1 Offset 0x83 Length 43
Record Type = PRIMARY_RECORD        Record Attributes =  NULL_BITMAP VARIABLE_COLUMNS
Record Size = 43                    
Memory Dump @0x000000EA11F7A083
0000000000000000:   30000800 26010000 04000802 0023002b 00430061  0...&........#.+.C.a
0000000000000014:   00740068 00650072 0069006e 00650041 00620065  .t.h.e.r.i.n.e.A.b.e
0000000000000028:   006c00                                        .l.    
Slot 1 Column 1 Offset 0x4 Length 4 Length (physical) 4
BusinessEntityID = 294              
Slot 1 Column 2 Offset 0x11 Length 18 Length (physical) 18
FirstName = Catherine               
Slot 1 Column 3 Offset 0x23 Length 8 Length (physical) 8
LastName = Abel                     
Slot 1 Column 4 Offset 0x0 Length 0 Length (physical) 0
Filler = [NULL]                     
*/

-- Now, increase the size of the record
UPDATE Person
SET Filler = 'Journées SQL Server 2015'
GO


SELECT DB_NAME(database_id) AS Database_Name,
       OBJECT_NAME(ips.object_id,database_id) AS TableName,
	   i.name AS IndexName,i.index_id,
	   ips.index_type_desc,ips.index_depth,ips.index_level,
	   ips.page_count,ips.avg_page_space_used_in_percent,ips.record_count,
	   ips.avg_record_size_in_bytes,ips.forwarded_record_count
FROM sys.dm_db_index_physical_stats(DB_ID(),object_id('dbo.Person'),null,null,'detailed')  ips
INNER JOIN sys.indexes i on i.index_id = ips.index_id and i.object_id=ips.object_id;
GO
--Database_Name	TableName	IndexName	index_id	index_type_desc	index_depth	index_level	page_count	avg_page_space_used_in_percent	record_count	avg_record_size_in_bytes	forwarded_record_count
--JSS2015Demo	Person		NULL		0			HEAP				1		0			270			97,0852236224364				32337			63,628						12365
--JSS2015Demo	Person		PK_Person	2			NONCLUSTERED INDEX	2		0			45			98,6755621447986				19972			16							NULL
--JSS2015Demo	Person		PK_Person	2			NONCLUSTERED INDEX	2		1			1			7,20286632073141				45				11							NULL


SELECT DB_NAME(database_id) AS Database_Name,
       OBJECT_NAME(ius.object_id,database_id) AS TableName,
	   i.name AS IndexName,i.index_id,
	   ius.user_updates,ius.last_user_update
FROM sys.dm_db_index_usage_stats ius
INNER JOIN sys.indexes i on i.index_id = ius.index_id and i.object_id=ius.object_id
WHERE database_id = DB_ID() AND i.object_id = object_id('dbo.Person');
GO
--Database_Name	TableName	IndexName	index_id	user_updates	
--JSS2015Demo	Person		NULL		0			3				
--JSS2015Demo	Person		PK_Person	2			2				


SELECT DB_NAME(database_id) AS Database_Name,
       OBJECT_NAME(ios.object_id,database_id) AS TableName,
	   i.name AS IndexName,i.index_id,
	   ios.leaf_allocation_count,leaf_update_count,nonleaf_allocation_count,nonleaf_update_count,forwarded_fetch_count
FROM sys.dm_db_index_operational_stats(DB_ID(),object_id('person'),null,null) ios
INNER JOIN sys.indexes i on i.index_id = ios.index_id and i.object_id=ios.object_id;
GO
/*
Database_Name	TableName	IndexName	index_id	leaf_allocation_count	leaf_update_count	nonleaf_allocation_count	nonleaf_update_count	forwarded_fetch_count
JSS2015Demo		Person		NULL		0			270						39944				0							0						12365
JSS2015Demo		Person		PK_Person	2			1						19166				1							0						0
*/

-- 104 pages -> 270 pages (Avg record size -> 63,628)
-- 12365 physical_stats.forwarded_record_count
-- 32337 physical_stats.record count (19972 + 12365)
-- 12365 operational_stats.forwarded_fetch_count


SELECT * 
FROM Person;
GO

SELECT DB_NAME(database_id) AS Database_Name,
       OBJECT_NAME(ios.object_id,database_id) AS TableName,
	   i.name AS IndexName,i.index_id,
	   ios.leaf_allocation_count,leaf_update_count,nonleaf_allocation_count,nonleaf_update_count,forwarded_fetch_count
FROM sys.dm_db_index_operational_stats(DB_ID(),object_id('person'),null,null) ios
INNER JOIN sys.indexes i on i.index_id = ios.index_id and i.object_id=ios.object_id;
GO
/*
Database_Name	TableName	IndexName	index_id	leaf_allocation_count	leaf_update_count	nonleaf_allocation_count	nonleaf_update_count	forwarded_fetch_count
JSS2015Demo		Person		NULL		0			270						39944				0							0						24730
JSS2015Demo		Person		PK_Person	2			1						19166				1							0						0
*/
-- 12365 forwarded records for each select (no where clause)
-- print 12365 + 12365 rows : 24730 forwarded fetch count
-- latches & locks ...

-- Look again at the data page
DBCC PAGE (JSS2015Demo,4,26160,3)

-- Now a Forwarding Stub
/*
Slot 1 Offset 0x60 Length 9
Record Type = FORWARDING_STUB       Record Attributes =                 Record Size = 9
Memory Dump @0x000000FF5254A060
0000000000000000:   041a7f00 00030033 00                          .......3.
Forwarding to  =  file 3 page 32538 slot 51        

Hex 33   -> Dec 51
Hex 7f1a -> Dec 32538
*/

DBCC PAGE (JSS2015Demo,3,32538,3)
/*
Slot 51 Offset 0x14eb Length 105
Record Type = FORWARDED_RECORD      Record Attributes =  NULL_BITMAP VARIABLE_COLUMNS
Record Size = 105                   
Memory Dump @0x000000FF5695B4EB
0000000000000000:   32000800 26010000 04000004 0027002f 005f0069  2...&........'./._.i
0000000000000014:   80430061 00740068 00650072 0069006e 00650041  .C.a.t.h.e.r.i.n.e.A
0000000000000028:   00620065 006c004a 006f0075 0072006e 00e90065  .b.e.l.J.o.u.r.n.é.e
000000000000003C:   00730020 00530051 004c0020 00530065 00720076  .s. .S.Q.L. .S.e.r.v
0000000000000050:   00650072 00200032 00300031 00350000 04e87e00  .e.r. .2.0.1.5...è~.
0000000000000064:   00040001 00                                   .....  
Forwarded from  =  file 4 page 26160 slot 1                              
Slot 51 Column 1 Offset 0x4 Length 4 Length (physical) 4
BusinessEntityID = 294              
Slot 51 Column 2 Offset 0x15 Length 18 Length (physical) 18
FirstName = Catherine               
Slot 51 Column 3 Offset 0x27 Length 8 Length (physical) 8
LastName = Abel                     
Slot 51 Column 4 Offset 0x2f Length 48 Length (physical) 48
Filler = Journées SQL Server 2015 
*/

-- Create a NCI index on LastName column
CREATE NONCLUSTERED INDEX [NCI_Person_LastName] 
ON [Person] 
(
	[LastName] ASC 
)
GO

-- Query plan : Index Seek + RID lookup
SELECT *
FROM Person
WHERE LastName = 'Abel';

TRUNCATE TABLE TablePages;
GO
INSERT INTO TablePages
EXEC ('DBCC IND(JSS2015Demo,Person,-1)');
GO

-- Find the root page of the NCI
SELECT i.name,t.PageFID, PagePID,pagetype,indexlevel
FROM TablePages t
INNER JOIN sys.indexes i on i.object_id = t.objectid and i.index_id=t.indexid
WHERE pagetype=2 AND i.name = 'NCI_Person_LastName'
ORDER BY indexlevel DESC

-- explore the root page
DBCC PAGE (JSS2015Demo,3,32624,3)
-- Find Abel !
/*
FileId	PageId	Row	Level	ChildFileId	ChildPageId	LastName (key)	HEAP RID (key)	KeyHashValue	Row Size
3		32624	0	1		4			32664		NULL			NULL			NULL			29
*/

-- leaf page
DBCC PAGE (JSS2015Demo,4,32664,3)
-- Find Abel
/*
FileId	PageId	Row	Level	LastName (key)	HEAP RID (key)		KeyHashValue	Row Size
4		32664	1	0		Abel			0xE87E000004000100	(199230b3e36a)	24
*/
SELECT dbo.HexToINT ('7EE8')
-- File : 4
-- Page 7EE8 : 32488
-- slot 0001 : 1
DBCC PAGE (JSS2015Demo,4,32488,3) 
/*
Slot 1 Offset 0x60 Length 9
Record Type = FORWARDING_STUB       Record Attributes =                 Record Size = 9
Memory Dump @0x000000FF5695A060
0000000000000000:   041a7f00 00030033 00                          .......3.
Forwarding to  =  file 3 page 32538 slot 51                              
*/

-- NCI point to the "old" page / slot
-- Need to reuild the table to remove he forwarded records.
-- ALTER TABLE Person REBUILD

TRUNCATE TABLE TablePages
GO

