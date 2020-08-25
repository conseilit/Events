/*============================================================================
  File:     
  Summary:  Statistiques - modification de données
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




USE TestStatistics
GO


-- SSMS : visualisation du stockage de la table FactOnlineSales

-- ajout d'un index sur la date : 13 secondes
CREATE INDEX IX_FactOnlineSales_DateKey
ON FactOnlineSales ([DateKey])
GO


-- Visualisation de la date de maj des statistiques
SELECT   object_name(object_id) AS [Table Name]
       , name AS [Index Name]
       , stats_date(object_id, stats_id) AS [Last Updated]
FROM sys.stats
WHERE object_name(object_id) = 'FactOnlineSales'
 AND Name = 'IX_FactOnlineSales_DateKey';
GO


-- 20% des données modifiées soit 2 525 522 enregistrements (1min30)
UPDATE TOP (20) PERCENT [dbo].[FactOnlineSales] 
SET datekey = '20131204';
GO


-- affichage du plan d'exécution

SET STATISTICS IO ON

-- 52 secondes, 2014 : 7 740 079 reads (~60 469 MB !)
-- 52 secondes, 2012 : 7 582 225 reads (~59 236 MB !)
SELECT * FROM FactOnlineSales
WHERE datekey = '20131204'
-- 2014 estimated 3388 rows , 2 525 522 actual rows
-- 2012 estimated 1 row , 2 525 522 actual rows


SELECT   object_name(object_id) AS [Table Name]
       , name AS [Index Name]
       , stats_date(object_id, stats_id) AS [Last Updated]
FROM sys.stats
WHERE object_name(object_id) = 'FactOnlineSales'

-- les statistiques n'ont pas été mises à jour


--  SQL2014, SQL Server 2012 Service Pack 1 et SQL Server 2008 R2 SP2
SELECT * 
FROM sys.dm_db_stats_properties (object_id('FactOnlineSales'), 2)


-- petite mise à jour pour dépasser le seuil
UPDATE TOP (510) [dbo].[FactOnlineSales]
SET datekey = '20131204';
GO



SELECT   object_name(object_id) AS [Table Name]
       , name AS [Index Name]
       , stats_date(object_id, stats_id) AS [Last Updated]
FROM sys.stats
WHERE object_name(object_id) = 'FactOnlineSales'
-- Statistiques toujours pas à jour



-- plan d'exécution estimé suffit
SELECT * FROM FactOnlineSales
WHERE datekey = '20131204'
-- le plan d'exécution est différent


-- la statistique a été mise à jour
SELECT   object_name(object_id) AS [Table Name]
       , name AS [Index Name]
       , stats_date(object_id, stats_id) AS [Last Updated]
FROM sys.stats
WHERE object_name(object_id) = 'FactOnlineSales'






















------------------------------------------------------------------------------
-- Short version

USE [TestStatistics]
GO

-- Visualisation de la date de maj des statistiques
SELECT   object_name(object_id) AS [Table Name]
       , name AS [Index Name]
       , stats_date(object_id, stats_id) AS [Last Updated]
FROM sys.stats
WHERE object_name(object_id) = 'OrderDetail'


-- 20% des données modifiées
UPDATE TOP (20) PERCENT OrderDetail
SET modifieddate = '20101010'

SELECT   object_name(object_id) AS [Table Name]
       , name AS [Index Name]
       , stats_date(object_id, stats_id) AS [Last Updated]
FROM sys.stats
WHERE object_name(object_id) = 'OrderDetail'

select * from orders
where orderdate = '20101010'

update top (510)  orders
set orderdate = '20101010'



