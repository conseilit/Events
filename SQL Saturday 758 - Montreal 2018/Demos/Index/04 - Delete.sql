/*============================================================================
  File    :  Delete   
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


DROP TABLE IF EXISTS [dbo].[Person]
GO



CREATE TABLE [dbo].[Person](
	[BusinessEntityID] [int] Identity(1,1) NOT NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[LastName] [nvarchar](50) NOT NULL,
	[Filler]  [char](100)
CONSTRAINT [PK_Person] PRIMARY KEY CLUSTERED 
	(
		[BusinessEntityID] ASC
	)
) 
GO




INSERT INTO Person  (FirstName,LastName)
SELECT FirstName,LastName
FROM AdventureWorks2008.Person.Person
ORDER BY LastName
GO



SELECT DB_NAME(database_id) AS Database_Name,
       OBJECT_NAME(ips.object_id,database_id) AS TableName,
	   ips.ghost_record_count,ips.record_count,ips.page_count
FROM sys.dm_db_index_physical_stats(DB_ID(),object_id('dbo.Person'),null,null,'detailed')  ips
INNER JOIN sys.indexes i on i.index_id = ips.index_id and i.object_id=ips.object_id;
GO
/*
Database_Name	TableName	ghost_record_count	record_count	page_count
JSS2015Demo		Person		0					19972			354
JSS2015Demo		Person		0					354				1
*/

SELECT DB_NAME(database_id) AS Database_Name,
       OBJECT_NAME(ius.object_id,database_id) AS TableName,
	   i.name AS IndexName,
	   ius.user_updates,ius.last_user_update
FROM sys.dm_db_index_usage_stats ius
INNER JOIN sys.indexes i on i.index_id = ius.index_id and i.object_id=ius.object_id
WHERE database_id = DB_ID() and i.object_id = OBJECT_ID('Person');
GO
/*
Database_Name	TableName		IndexName	user_updates	last_user_update
JSS2015Demo		Person			PK_Person	1				2015-11-26 18:10:15.597
*/

SELECT DB_NAME(database_id) AS Database_Name,
       OBJECT_NAME(ios.object_id,database_id) AS TableName,
	   i.name AS IndexName,
	   leaf_insert_count,leaf_delete_count,leaf_ghost_count,nonleaf_delete_count
FROM sys.dm_db_index_operational_stats(DB_ID(),object_id('person'),null,null) ios
INNER JOIN sys.indexes i on i.index_id = ios.index_id and i.object_id=ios.object_id;
GO
/*
Database_Name	TableName	IndexName	leaf_insert_count	leaf_delete_count	leaf_ghost_count	nonleaf_delete_count
JSS2015Demo		Person		PK_Person	19972				0					0					0
*/



-- show records, FileID, PageID and slots for LastName = 'Adams'
SELECT TOP 100 plc.*, [Person].*
FROM [Person] 
Cross Apply sys.fn_physLocCracker (%%physloc%%) AS plc
WHERE LastName = 'Adams'
-- 86 records

-- replace Files Number / Page number
-- Ctrl+H 4,21648  

DBCC TRACEON(3604)
DBCC PAGE (JSS2015Demo,4,21648,3)
-- m_ghostRecCnt = 0

CHECKPOINT
GO
SELECT * FROM fn_dblog(null,null);
GO

-- Begin execution here

	BEGIN TRAN DeleteTran;
		;WITH MyCTE AS (
			SELECT [BusinessEntityID], [FirstName], [LastName]
			FROM Person
			WHERE LastName = 'Adams'
		)
		--SELECT * FROM MyCTE
		DELETE FROM MyCTE;
	COMMIT TRAN DeleteTran;
	GO

	SELECT DB_NAME(database_id) AS Database_Name,
		   OBJECT_NAME(ips.object_id,database_id) AS TableName,
		   ips.ghost_record_count,ips.record_count,ips.page_count
	FROM sys.dm_db_index_physical_stats(DB_ID(),object_id('dbo.Person'),null,null,'detailed')  ips
	INNER JOIN sys.indexes i on i.index_id = ips.index_id and i.object_id=ips.object_id;
	GO
	/*
	Database_Name	TableName	ghost_record_count	record_count	page_count
	JSS2015Demo		Person		86					19886			354
	JSS2015Demo		Person		0					354				1
	*/

	SELECT DB_NAME(database_id) AS Database_Name,
		   OBJECT_NAME(ius.object_id,database_id) AS TableName,
		   i.name AS IndexName,
		   ius.user_updates,ius.last_user_update
	FROM sys.dm_db_index_usage_stats ius
	INNER JOIN sys.indexes i on i.index_id = ius.index_id and i.object_id=ius.object_id
	WHERE database_id = DB_ID();
	GO
	/*
	Database_Name	TableName	IndexName	user_updates	
	JSS2015Demo		Person		PK_Person	2				
	*/

	SELECT DB_NAME(database_id) AS Database_Name,
		   OBJECT_NAME(ios.object_id,database_id) AS TableName,
		   i.name AS IndexName,
		   leaf_insert_count,leaf_delete_count,leaf_ghost_count,nonleaf_delete_count
	FROM sys.dm_db_index_operational_stats(DB_ID(),object_id('person'),null,null) ios
	INNER JOIN sys.indexes i on i.index_id = ios.index_id and i.object_id=ios.object_id;
	GO
	/*
	Database_Name	TableName	IndexName	leaf_insert_count	leaf_delete_count	leaf_ghost_count	nonleaf_delete_count
	JSS2015Demo		Person		PK_Person	19972				0					86					0
	*/


	DBCC PAGE (JSS2015Demo,4,21648,3)
	GO
	-- m_ghostRecCnt = 46
	-- slot 11 -> Record Type = GHOST_DATA_RECORD

-- end execution here
	
	/*
	Slot 11 Offset 0x683 Length 137

	Record Type = GHOST_DATA_RECORD     Record Attributes =  NULL_BITMAP VARIABLE_COLUMNS
	Record Size = 137                   
	Memory Dump @0x0000001B0A58A683

	0000000000000000:   3c006c00 0c000000 00000000 00000000 108d50d7  <.l...............P×
	0000000000000014:   19000000 ffffffff f97f0000 c00ef0cf 19000000  ....ÿÿÿÿù...À.ðÏ....
	0000000000000028:   eb95c149 f97f0000 00020000 00000000 3596c149  ë?ÁIù...........5?ÁI
	000000000000003C:   f97f0000 0000f0cf 19000000 a9eacf8e 1c000000  ù.....ðÏ....©êÏ?....
	0000000000000050:   feffffff ffffffff 371b0f4a f97f0000 d00135c5  þÿÿÿÿÿÿÿ7..Jù...Ð.5Å
	0000000000000064:   19000000 eb95c149 04000802 007f0089 00410061  ....ë?ÁI.......?.A.a
	0000000000000078:   0072006f 006e0041 00640061 006d0073 00        .r.o.n.A.d.a.m.s.

	Slot 11 Column 1 Offset 0x4 Length 4 Length (physical) 4
	BusinessEntityID = 12               
	Slot 11 Column 2 Offset 0x75 Length 10 Length (physical) 10
	FirstName = Aaron                   
	Slot 11 Column 3 Offset 0x7f Length 10 Length (physical) 10
	LastName = Adams                    
	Slot 11 Column 4 Offset 0x0 Length 0 Length (physical) 0
	Filler = [NULL]                      
	Slot 11 Offset 0x0 Length 0 Length (physical) 0
	*/



	DECLARE @TransactionID CHAR (20) 
	SELECT @TransactionID = [Transaction ID] 
	FROM fn_dblog (null, null) WHERE [Transaction Name]='DeleteTran' 

	SELECT [Current LSN],[Operation],[Context],[Transaction ID],
		   [Page ID],[Slot ID],[Transaction Name],[Begin Time],[End Time]
	FROM fn_dblog (null, null) WHERE [Transaction ID] = @TransactionID; 
	-- see LOP_DELETE_ROWS / LCX_MARK_AS_GHOST  ...







-- Records are marked as ghost
-- but we have to update PFS pages to track free space

-- copy part of current LSN    00000032:0001d2e0:0045
SELECT [Current LSN],[Operation],[Context],[AllocUnitName],[Transaction ID],
       [Page ID],[Slot ID],[Transaction Name],[Begin Time],[End Time]
FROM fn_dblog (null, null) WHERE [Current LSN] like '00000032:0001d2e0%'; 
/*
http://blogs.msdn.com/b/sqljourney/archive/2012/07/28/an-in-depth-look-at-ghost-records-in-sql-server.aspx

The ghost record(s) presence is registered in:
 - The record itself 
 - The Page on which the record has been ghosted 
 - The PFS for that page 
 - The DBTABLE structure for the corresponding database. You can view the DBTABLE structure by using the DBCC DBTABLE command (make sure you have TF 3604 turned on). 









The ghost records can be cleaned up in 3 ways:
 - If a record of the same key value as the deleted record is inserted
 - If the page needs to be split, the ghost records will be handled
 - The Ghost cleanup task (scheduled to run once every 5 seconds)
*/

SELECT [Current LSN],[Operation],[Context],[AllocUnitName],[Transaction ID],
       [Page ID],[Slot ID],[Transaction Name],[Begin Time],[End Time]
FROM fn_dblog (null, null)
-- see LOP_EXPUNGE_ROWS




-- check again the page
DBCC PAGE (JSS2015Demo,4,21648,3)
-- only 11 slots

-- Sure ?
DBCC PAGE (JSS2015Demo,4,21648,2)
GO
-- the GHOST Cleanup only removes entries in the offset table !
-- the data of the record is not "really" deleted in the page
-- but the record cannot be found (no more offset) and space inside the page can be reused





-- But leaf_delete_count = 0 !!!
SELECT DB_NAME(database_id) AS Database_Name,
       OBJECT_NAME(ios.object_id,database_id) AS TableName,
	   i.name AS IndexName,
	   leaf_insert_count,leaf_delete_count,leaf_ghost_count,nonleaf_delete_count
FROM sys.dm_db_index_operational_stats(DB_ID(),object_id('person'),null,null) ios
INNER JOIN sys.indexes i on i.index_id = ios.index_id and i.object_id=ios.object_id;
GO
/*
Database_Name	TableName	IndexName	leaf_insert_count	leaf_delete_count	leaf_ghost_count	nonleaf_delete_count
JSS2015Demo		Person		PK_Person	19972				0					86					0
*/


-- Page 21648 ...
SELECT TOP 100 plc.*, [Person].*
FROM [Person] 
Cross Apply sys.fn_physLocCracker (%%physloc%%) AS plc
WHERE page_id = 21648
  AND file_id = 4

-- some records

BEGIN TRAN
	;With MyCTE AS
	(
		SELECT [Person].BusinessEntityID
		FROM [Person] 
		Cross Apply sys.fn_physLocCracker (%%physloc%%) AS plc
		WHERE page_id = 21648
		  AND file_id = 4
	)
	DELETE FROM P 
	OUTPUT deleted.*
	FROM Person p 
	INNER JOIN MyCTE on p.BusinessEntityID = MyCTE.BusinessEntityID;

	SELECT DB_NAME(database_id) AS Database_Name,
		   OBJECT_NAME(ios.object_id,database_id) AS TableName,
		   i.name AS IndexName,
		   leaf_insert_count,leaf_delete_count,leaf_ghost_count,nonleaf_delete_count
	FROM sys.dm_db_index_operational_stats(DB_ID(),object_id('person'),null,null) ios
	INNER JOIN sys.indexes i on i.index_id = ios.index_id and i.object_id=ios.object_id;
	/*
	Database_Name	TableName	IndexName	leaf_insert_count	leaf_delete_count	leaf_ghost_count	nonleaf_delete_count
	JSS2015Demo		Person		PK_Person	19972				0					97					0
	*/
COMMIT TRAN
GO


DBCC PAGE (JSS2015Demo,4,21648,3)
GO
-- 1 ghost record remains in the page !

BEGIN TRAN
	DELETE  
	FROM Person;

	SELECT DB_NAME(database_id) AS Database_Name,
		   OBJECT_NAME(ios.object_id,database_id) AS TableName,
		   i.name AS IndexName,
		   leaf_insert_count,leaf_delete_count,leaf_ghost_count,nonleaf_delete_count
	FROM sys.dm_db_index_operational_stats(DB_ID(),object_id('person'),null,null) ios
	INNER JOIN sys.indexes i on i.index_id = ios.index_id and i.object_id=ios.object_id;
COMMIT TRAN
/*
Database_Name	TableName	IndexName	leaf_insert_count	leaf_delete_count	leaf_ghost_count	nonleaf_delete_count
JSS2015Demo		Person		PK_Person	19972				13493				6479				244

PRINT 13493	+ 6479 = 19972
 
*/

