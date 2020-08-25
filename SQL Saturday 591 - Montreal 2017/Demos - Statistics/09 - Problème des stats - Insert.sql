/*============================================================================
  File:     
  Summary:  Statistiques - ajout de donn�es
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


USE [TestStatistics]
GO


CREATE INDEX IX_OrderDetail_ModifiedDate
ON OrderDetail ([ModifiedDate])
GO

/*
SELECT  MIN([ModifiedDate]) AS MinValue,
		MAX([ModifiedDate]) as MaxValue
FROM OrderDetail;
GO
*/

-- Ajout de 20000 enregistrements
INSERT INTO OrderDetail 
	(	 [SalesOrderID]
		,[CarrierTrackingNumber]
		,[OrderQty]
		,[ProductID]
		,[SpecialOfferID]
		,[UnitPrice]
		,[UnitPriceDiscount]
		,[LineTotal]
		,[rowguid]
		,[ModifiedDate]
	)
SELECT TOP 20000 
	   [SalesOrderID]
      ,[CarrierTrackingNumber]
      ,[OrderQty]
      ,[ProductID]
      ,[SpecialOfferID]
      ,[UnitPrice]
      ,[UnitPriceDiscount]
      ,[LineTotal]
      ,[rowguid]
      ,'20131204'
FROM OrderDetail;
GO 


-- affichage du plan d'ex�cution


-- affichage du nombre de pages lues
SET STATISTICS IO ON

-- Visualisation des lectures
-- 20 075 reads / 20 000 rows
SELECT *
FROM OrderDetail
WHERE [ModifiedDate] = '20131204'


-- le nombre de lecture n�c�ssaires pour lire l'int�gralit� 
-- de la table est bien inf�rieur
-- 1 766 reads / 141 317 rows
SELECT *
FROM OrderDetail;
GO
-- => mauvais plan

-- Pourquoi ?

-- La statistique n'a pa s�t� mise � jour
SELECT   object_name(object_id) AS [Table Name]
       , name AS [Index Name]
       , stats_date(object_id, stats_id) AS [Last Updated]
FROM sys.stats
WHERE object_name(object_id) = 'OrderDetail'


-- Visualisation des statistiques (densit�, histogramme)
DBCC SHOW_STATISTICS ("dbo.OrderDetail", IX_OrderDetail_ModifiedDate);

-- => en cas d'ajout de donn�es au del� de la valeur maximale
-- SQL Server <= 2012 pense qu'il n'y a qu'un seul enregistrement
-- SQL Server >= 2014 estime un peu mieux le nombre d'enregstrements
-- Mais globalement, cela reste faux


UPDATE STATISTICS dbo.OrderDetail(IX_OrderDetail_ModifiedDate); 
GO


SELECT *
FROM OrderDetail
WHERE [ModifiedDate] = '20131204'

-- une fois la statistique � jour
-- le plan a �t� modif�
