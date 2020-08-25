/*============================================================================
  File:     
  Summary:  AUTO_CREATE_STATISTICS OFF
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



USE [master]
GO

ALTER DATABASE [TestStatistics] 
SET AUTO_CREATE_STATISTICS OFF WITH NO_WAIT
GO


USE [TestStatistics]
GO

-- Affichage du plan d'exécution

-- Recopie de 121317 enregistrements
SELECT *
INTO OrderDetail
FROM AdventureWorks.Sales.SalesOrderDetail 


SELECT *
FROM orderdetail 
where SalesOrderID = 43692

-- Un warning est affiché dans le plan d'exécution
-- On constate qu'aucune statistique n'apparait dans SSMS


-- 6500 (2012) ou 348 (2014) estimated number of rows
-- 28 actual number of rows
-- => pas un bon plan !
-- SQL Server possède un certain nombre de règles 
-- et de "nombres magiques" en interne pour obtenir cette estimation.
-- Elle peut s'averer proche de la réalité ou au contraire
-- complètement fausse et donc potentiellement problématique



