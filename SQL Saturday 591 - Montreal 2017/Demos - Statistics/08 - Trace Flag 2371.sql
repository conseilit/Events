/*============================================================================
  File:     
  Summary:  Trace Flag Maj Stats
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



DBCC TRACEON (2371,-1)



-- Visualisation de la date de maj des statistiques
SELECT   object_name(object_id) AS [Table Name]
       , name AS [Index Name]
       , stats_date(object_id, stats_id) AS [Last Updated]
FROM sys.stats
WHERE object_name(object_id) = 'FactOnlineSales'
GO

-- 631 381 rows : 59 secondes
UPDATE TOP (5) PERCENT [dbo].[FactOnlineSales] 
SET datekey = '20131205';
GO

-- pendant l'exécution :
-- nouvelle requête
-- http://blogs.msdn.com/b/saponsqlserver/archive/2011/09/07/changes-to-automatic-update-statistics-in-sql-server-traceflag-2371.aspx


--  SQL2014, SQL Server 2012 Service Pack 1 et SQL Server 2008 R2 SP2
SELECT * 
FROM sys.dm_db_stats_properties (object_id('FactOnlineSales'), 2)


-- Plan estimé
SELECT * FROM FactOnlineSales
WHERE datekey = '20131205'


--  SQL2014, SQL Server 2012 Service Pack 1 et SQL Server 2008 R2 SP2
SELECT * 
FROM sys.dm_db_stats_properties (object_id('FactOnlineSales'), 2)

-- La statistiques a été mise à jour bien avant le seuil des 20% + 500

-- Visualisation de la date de maj des statistiques
SELECT   object_name(object_id) AS [Table Name]
       , name AS [Index Name]
       , stats_date(object_id, stats_id) AS [Last Updated]
FROM sys.stats
WHERE object_name(object_id) = 'FactOnlineSales'




-- La statistiques a bien été mise a jour 
-- la modification du seuil est bénéfique


DBCC TRACEOFF (2371,-1)



