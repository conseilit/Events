/*============================================================================
  File    :  Insert   
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

CREATE TABLE [dbo].[Person](
	[BusinessEntityID] [int] NOT NULL,
	[FirstName] [varchar](50) NOT NULL,
	[LastName] [varchar](50) NOT NULL,
	[Filler] [char] (500)  NULL, -- /!\ 1 row per page
CONSTRAINT [PK_Person] PRIMARY KEY CLUSTERED 
	(
		[BusinessEntityID] ASC
	)
) 
GO


DECLARE @i INT =1
WHILE (@i<20000)
BEGIN
	If EXISTS ( SELECT BusinessEntityID,FirstName,LastName
				FROM AdventureWorks2008.Person.Person
				WHERE BusinessEntityID = @i) 
		INSERT INTO Person (BusinessEntityID,FirstName,LastName)
		SELECT BusinessEntityID,FirstName,LastName
		FROM AdventureWorks2008.Person.Person
		WHERE BusinessEntityID = @i;
	SET @i+=1
END
GO



SELECT DB_NAME(database_id) AS Database_Name,
       OBJECT_NAME(ips.object_id,database_id) AS TableName,
	   i.name AS IndexName,i.index_id,i.type_desc,index_depth,index_level,page_count,record_count
FROM sys.dm_db_index_physical_stats(DB_ID(),object_id('dbo.Person'),null,null,'detailed')  ips
INNER JOIN sys.indexes i on i.index_id = ips.index_id and i.object_id=ips.object_id;
/*
Database_Name		TableName	IndexName	index_id	type_desc	index_depth	index_level	page_count	record_count
JSS2015Demo			Person		PK_Person	1			CLUSTERED	3			0			1280		19194
JSS2015Demo			Person		PK_Person	1			CLUSTERED	3			1			4			1280
JSS2015Demo			Person		PK_Person	1			CLUSTERED	3			2			1			4
*/

SELECT DB_NAME(database_id) AS Database_Name,
       OBJECT_NAME(ius.object_id,database_id) AS TableName,
	   i.name AS IndexName,
	   ius.user_updates,ius.last_user_update
FROM sys.dm_db_index_usage_stats ius
INNER JOIN sys.indexes i on i.index_id = ius.index_id and i.object_id=ius.object_id
WHERE database_id = DB_ID() AND i.object_id = object_id('dbo.Person');
/*
Database_Name	TableName	IndexName	user_updates	last_user_update
JSS2015Demo		Person		PK_Person	19194			2015-11-28 18:17:59.550
*/

SELECT DB_NAME(database_id) AS Database_Name,
       OBJECT_NAME(ios.object_id,database_id) AS TableName,
	   i.name AS IndexName,
	   ios.leaf_allocation_count,leaf_insert_count,nonleaf_allocation_count,nonleaf_insert_count
FROM sys.dm_db_index_operational_stats(DB_ID(),object_id('person'),null,null) ios
INNER JOIN sys.indexes i on i.index_id = ios.index_id and i.object_id=ios.object_id;
/*
Database_Name		TableName	IndexName	leaf_allocation_count	leaf_insert_count	nonleaf_allocation_count	nonleaf_insert_count
JSS2015Demo			Person		PK_Person	1280					19194				5							1280
*/



-- Compare read and write usage stats to track "Bad" indexes


CREATE NONCLUSTERED INDEX [NCI_Person_LastName] 
ON [Person] 
(
	[LastName] ASC 
)
GO

DECLARE @i INT =1
WHILE (@i<10000)
BEGIN
	INSERT INTO Person (BusinessEntityID,FirstName,LastName)
	SELECT BusinessEntityID+100000,FirstName,LastName
	FROM AdventureWorks2008.Person.Person
	WHERE BusinessEntityID = @i;
	SET @i+=1
END
GO

DECLARE @i INT =1
WHILE (@i<30000)
BEGIN
	UPDATE Person
	SET LastName = UPPER(lastName)
	WHERE BusinessEntityID = @i;
	SET @i+=1
END
GO


SELECT DB_NAME(database_id) AS Database_Name,
       OBJECT_NAME(ius.object_id,database_id) AS TableName,
	   i.name AS IndexName,i.index_id,
	   ius.user_updates,ius.user_scans,ius.user_seeks,ius.user_lookups,
	   (ius.user_scans+ius.user_seeks+ius.user_lookups) AS [user_reads],
	   ius.user_updates - (ius.user_scans+ius.user_seeks+ius.user_lookups) AS [Difference]
FROM sys.dm_db_index_usage_stats ius
INNER JOIN sys.indexes i on i.index_id = ius.index_id and i.object_id=ius.object_id
WHERE database_id = DB_ID() AND i.object_id = object_id('dbo.Person');
/*
Database_Name	TableName	IndexName			index_id	user_updates	user_scans	user_seeks	user_lookups	user_reads	Difference
JSS2015Demo		Person		NCI_Person_LastName	2			39998			0			0			0				0			39998
JSS2015Demo		Person		PK_Person			1			59192			0			29999		0				29999		29193
*/


/*
	Key point : NC index with high number of writes, very low numbre of reads 
	            consider workload and uptime before dropping !
*/




/*
sys.dm_db_index_physical_stats
	Structure physique de l'index, niveaux, nombre de pages, ...

sys.dm_db_index_usage_stats
	nombre d'opération de modification

sys.dm_db_index_operational_stats
	allocation de pages, nombre d'inserts
*/
