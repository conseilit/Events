/*============================================================================
  File:     
  Summary:  Ressources pour Maj Stats
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

SELECT *
INTO OrderHeader
FROM AdventureWorks.sales.SalesOrderHeader 
GO

-- Visualisation de la date de maj des statistiques
SELECT   object_name(object_id) AS [Table Name]
       , name AS [Index Name]
       , stats_date(object_id, stats_id) AS [Last Updated]
FROM sys.stats
WHERE object_name(object_id) = 'OrderHeader'
GO

-- Pas de stats


SELECT *
FROM OrderHeader
WHERE OrderDate = getdate()
GO


-- Visualisation de la date de maj des statistiques
SELECT   object_name(object_id) AS [Table Name]
       , name AS [Index Name]
       , stats_date(object_id, stats_id) AS [Last Updated]
FROM sys.stats
WHERE object_name(object_id) = 'OrderHeader'
GO

-- Auto_Create_Stats a joué son rôle


-- Il est légitime de se poser la question de la création d'index
-- lorsqu'un stat a été créé par SQL Server
-- Mais surtout ne pas faire du systématique !

CREATE INDEX IX_OrderHeader_OrderDate
ON OrderHeader(OrderDate)
GO


-- Visualisation de la date de maj des statistiques
SELECT   object_name(object_id) AS [Table Name]
       , name AS [Index Name]
       , stats_date(object_id, stats_id) AS [Last Updated]
FROM sys.stats
WHERE object_name(object_id) = 'OrderHeader'
GO

-- Il existe maintenant 2 statistiques d'index
-- pour la colonne OrderDate


-- Lorsque le seuil de recalcul des stats est atteint
-- est-ce que toutes les statistiques sont mises à jour ?

-- Création d'une trace dans le profiler (ou XEvent )
-- stmtcompleted + autostats

-- Mise à jour des données
-- avec dépassement du seuil
UPDATE TOP (25) PERCENT OrderHeader
SET OrderDate = GETDATE()
GO

-- on provoque la maj des statistiques
SELECT *
FROM OrderHeader
WHERE OrderDate = getdate()
GO

-- Toutes les stats ont été mise à jour
-- ce qui prends du temps.

-- Il faut penser  vérifier l'utilité des stats auto générées

SELECT   object_name(object_id) AS [Table Name]
       , name AS [Index Name]
       , stats_date(object_id, stats_id) AS [Last Updated]
FROM sys.stats
WHERE object_name(object_id) = 'OrderHeader'
GO

drop statistics OrderHeader._WA_Sys_00000003_145C0A3F


