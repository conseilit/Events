/*============================================================================
  File    :  Latch   
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

DROP TABLE IF EXISTS [dbo].[PageLatchDemo]
GO

CREATE TABLE dbo.PageLatchDemo
(
	 PageLatchDemoID INT IDENTITY (1,1)
	,FillerData bit
	,CONSTRAINT PK_PageLatchDemo_PageLatchDemoID 
	 PRIMARY KEY CLUSTERED (PageLatchDemoID)
)
GO



/*
	-- RML utilities
	Ostress.exe -dJSS2015Demo -E –Q"SET NOCOUNT ON; INSERT INTO dbo.PageLatchDemo (FillerData) SELECT t.object_id % 2	FROM sys.objects t;	SELECT TOP 5 *	FROM dbo.PageLatchDemo ORDER BY PageLatchDemoID DESC;"  –n200 –r1000 –oc:\temp\output -Slocalhost 

*/



SELECT DB_NAME(database_id) AS Database_Name,
       OBJECT_NAME(ius.object_id,database_id) AS TableName,
	   i.name AS IndexName,
	   ius.user_scans, ius.user_seeks, ius.user_lookups, ius.user_updates
FROM sys.dm_db_index_usage_stats ius
INNER JOIN sys.indexes i on i.index_id = ius.index_id and i.object_id=ius.object_id
WHERE database_id = DB_ID() AND i.object_id = object_id('dbo.PageLatchDemo');
GO
/*
Database_Name	TableName		IndexName							user_scans	user_seeks	user_lookups	user_updates
JSS2015Demo		PageLatchDemo	PK_PageLatchDemo_PageLatchDemoID	5131		0			0				5131
*/

SELECT DB_NAME(database_id) AS Database_Name,
       OBJECT_NAME(ios.object_id,database_id) AS TableName,
	   ios.page_latch_wait_count ,
	   ios.page_latch_wait_in_ms
FROM sys.dm_db_index_operational_stats(DB_ID(),object_id('dbo.PageLatchDemo'),1,null) ios
INNER JOIN sys.indexes i on i.index_id = ios.index_id and i.object_id=ios.object_id;
GO
/*
Database_Name	TableName		page_latch_wait_count	page_latch_wait_in_ms
JSS2015Demo		PageLatchDemo	549263					2134090
*/

DROP TABLE IF EXISTS [dbo].[PageLatchDemo]
GO
