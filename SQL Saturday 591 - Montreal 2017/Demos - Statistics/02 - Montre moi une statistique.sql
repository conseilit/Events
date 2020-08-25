/*============================================================================
  File:     
  Summary:  Montre moi une statistique
  Date:     03/2017
  SQL Server Versions: 11/12 (SS2012/SS2014)
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


USE Master;
GO


USE [TestStatistics]
GO

-- Création d'une table de test
CREATE TABLE [dbo].[Person]
(
	[BusinessEntityID] [int] NOT NULL,
	[FirstName]        [nvarchar](100) NOT NULL,
	[LastName]         [nvarchar](100) NOT NULL,
	CONSTRAINT [PK_Person_BusinessEntityID] PRIMARY KEY CLUSTERED 
	(
		[BusinessEntityID] ASC
	)
) 
GO

-- Ajout de données
INSERT INTO [dbo].[Person]
(
	[BusinessEntityID],
	[FirstName],
	[LastName] 
)
SELECT TOP 10000
	[BusinessEntityID],
	[FirstName],
	[LastName] 
FROM AdventureWorks2008.person.Person;
GO


CREATE NONCLUSTERED INDEX [IX_FirstName] 
ON [dbo].[Person] 
	( [FirstName] ASC )
GO


-- Visualisation de la date de maj des statistiques

SELECT  object_name(s.object_id) AS [Table Name]
       , name AS [Index Name]
       , stats_date(s.object_id, s.stats_id) AS [Last Updated],*
FROM sys.stats s
CROSS APPLY sys.dm_db_stats_properties(object_id, stats_id)
WHERE name = 'IX_FirstName'


-- Visualisation des statistiques (densité, histogramme)
DBCC SHOW_STATISTICS ("dbo.person", IX_FirstName);

-- SQL Server v.Next
SELECT *
FROM sys.stats
CROSS APPLY sys.dm_db_stats_histogram(object_id, stats_id)
WHERE name = 'IX_FirstName'



-- Recopie du code restant dans une seconde session

-- all_density :
SELECT 1.0/ COUNT (DISTINCT FirstName)
FROM dbo.Person 

SELECT 1.0/ COUNT (*)
FROM (
	SELECT DISTINCT FirstName, BusinessEntityID
	FROM dbo.Person 
) as t


-- Histogramme

-- EQ_ROWS
SELECT  'A.',COUNT(*) as EQ_ROWS
FROM dbo.Person
WHERE FirstName = 'A.';

SELECT 'Abigail',COUNT(*) as EQ_ROWS 
FROM dbo.Person
WHERE FirstName = 'Abigail';

SELECT 'Adam',COUNT(*)  as EQ_ROWS
FROM dbo.Person
WHERE FirstName = 'Adam';




-- RANGE_ROWS
SELECT COUNT(*) as RANGE_ROWS
FROM dbo.Person
WHERE FirstName > 'A.'
AND   FirstName < 'Abigail';




-- AVG_RANGE_ROWS
SELECT COUNT(*) As RANGE_ROWS, 
       COUNT (DISTINCT FirstName) As DISTINCT_RANGEROWS, 
	   COUNT(*) / COUNT (DISTINCT FirstName) as AVG_RANGE_ROWS
FROM dbo.Person
WHERE FirstName > 'A.'
AND   FirstName < 'Abigail';

