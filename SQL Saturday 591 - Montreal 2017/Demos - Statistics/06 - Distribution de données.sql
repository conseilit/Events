/*============================================================================
  File:     
  Summary:  Distribution de données
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



USE [ContosoRetailDW] 
GO


-- utilisation d'une table des test plus consquente
SELECT COUNT(*) as NbEnregistrements
FROM FactOnlineSales
GO



-- ajout d'un index non cluster : 14 secs
CREATE INDEX IX_FactOnlineSales_ProductKey
ON FactOnlineSales (ProductKey)


-- Affichage du plan d'exécution

-- affichage du nombre de pages lues 
SET STATISTICS IO ON

-- 4796 enregistrements (6448 estimés) / 14708 reads
SELECT * 
FROM [dbo].[FactOnlineSales]
WHERE ProductKey = 1705

-- 20492 enregistrements (6448 estimés) / 62805 reads (~490 MB)
SELECT * 
FROM [dbo].[FactOnlineSales]
WHERE ProductKey = 1706

-- Affichage de l'histogramme 
-- Dans SSSMS pour changer

-- Mauvaise estimation de cardinalité => mauvais plan
-- Une lecture complète de la table prends 4:12 minutes (affichage dans la grille) 
-- 12 627 608 enregistrements / 46535 reads
/*
SELECT * 
FROM [dbo].[FactOnlineSales]
*/

-- Il faut donc affiner les statistiques
-- Quand le nombre d'enregistrements devient trop important : 
-- Créer des statistiques filtrées peut être une solution



CREATE STATISTICS S_FactOnlineSales_ProductKey_1_250
ON FactOnlineSales
	( ProductKey ) 
WHERE ProductKey >= 1 and ProductKey <= 250
WITH FULLSCAN;
GO

CREATE STATISTICS S_FactOnlineSales_ProductKey_251_500
ON FactOnlineSales
	( ProductKey ) 
WHERE ProductKey >= 251 and ProductKey <= 500
WITH FULLSCAN;
GO

CREATE STATISTICS S_FactOnlineSales_ProductKey_501_750
ON FactOnlineSales
	( ProductKey ) 
WHERE ProductKey >= 501 and ProductKey <= 750
WITH FULLSCAN;
GO

CREATE STATISTICS S_FactOnlineSales_ProductKey_751_1000
ON FactOnlineSales
	( ProductKey ) 
WHERE ProductKey >= 751 and ProductKey <= 1000
WITH FULLSCAN;
GO


CREATE STATISTICS S_FactOnlineSales_ProductKey_1001_1250
ON FactOnlineSales
	( ProductKey ) 
WHERE ProductKey >= 1001 and ProductKey <= 1250
WITH FULLSCAN;
GO

CREATE STATISTICS S_FactOnlineSales_ProductKey_1251_1500
ON FactOnlineSales
	( ProductKey ) 
WHERE ProductKey >= 1251 and ProductKey <= 1500
WITH FULLSCAN;
GO

CREATE STATISTICS S_FactOnlineSales_ProductKey_1501_1750
ON FactOnlineSales
	( ProductKey ) 
WHERE ProductKey >= 1501 and ProductKey <= 1750
WITH FULLSCAN;
GO

CREATE STATISTICS S_FactOnlineSales_ProductKey_1751_2000
ON FactOnlineSales
	( ProductKey ) 
WHERE ProductKey >= 1751 and ProductKey <= 2000
WITH FULLSCAN;
GO



CREATE STATISTICS S_FactOnlineSales_ProductKey_2001_2250
ON FactOnlineSales
	( ProductKey ) 
WHERE ProductKey >= 2001 and ProductKey <= 2250
WITH FULLSCAN;
GO

CREATE STATISTICS S_FactOnlineSales_ProductKey_2251_2500
ON FactOnlineSales
	( ProductKey ) 
WHERE ProductKey >= 2251 and ProductKey <= 2500
WITH FULLSCAN;
GO

CREATE STATISTICS S_FactOnlineSales_ProductKey_2501_2750
ON FactOnlineSales
	( ProductKey ) 
WHERE ProductKey >= 2501 and ProductKey <= 2750
WITH FULLSCAN;
GO

CREATE STATISTICS S_FactOnlineSales_ProductKey_2751_3000
ON FactOnlineSales
	( ProductKey ) 
WHERE ProductKey >= 2751 and ProductKey <= 3000
WITH FULLSCAN;
GO




-- 4796 enregistrements / 14708 reads
SELECT * 
FROM [dbo].[FactOnlineSales]
WHERE ProductKey = 1705
OPTION (RECOMPILE)

-- 20492 enregistrements / 47309 reads
SELECT * 
FROM [dbo].[FactOnlineSales]
WHERE ProductKey = 1706
OPTION (RECOMPILE)

-- Le plan d'exécution pour la valeur 1706 a changé.
-- Estimation de cardinalité plus précise => meilleur plan

-- La statistique filtrée permet d'obtenir de meilleurs plans d'exécution
-- si la distribution des données n'est pas uniforme
