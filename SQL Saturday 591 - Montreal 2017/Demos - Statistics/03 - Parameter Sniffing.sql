/*============================================================================
  File:     
  Summary:  Paraleter sniffing
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


USE AdventureWorks 
GO

-- Affichage du plan d'ex�cution


-- Retour sur la requ�te avec 2 plans diff�rents
SELECT * FROM [Person].[Address]
WHERE [City] = 'LONDON'

SELECT * FROM [Person].[Address]
WHERE [City] = 'NEWARK'
GO

-- Supression de tous les plans en cache
DBCC FREEPROCCACHE

-- Requete de test
DECLARE @city NVARCHAR(50) 
SET @city = 'LONDON'
SELECT * FROM [Person].[Address]
WHERE [City] = @city
GO


-- Faisons plaisir � SQL Server
-- Cr�ation de l'index manquant
CREATE NONCLUSTERED INDEX [IX_Address_City]
ON [Person].[Address] 
	([City])



-- Supression de tous les plans en cache
DBCC FREEPROCCACHE

-- Requete de test
DECLARE @city NVARCHAR(50) 
SET @city = 'LONDON'
SELECT * FROM [Person].[Address]
WHERE [City] = @city



-- Une m�me requ�te
-- la m�me condition Where
-- un plan diff�rent, sans cluster index scan

-- Pourquoi ?
-- Visualisation du plan d'ex�cution
-- estimated number of rows <> actual number of rows


-- L'optimiseur de requ�tes de SQL Server
-- n'a pas r�ussi � "sniffer" le param�tre
-- cela se v�rife dans les donnes XML du plan

-- Do� provient le nombre de lignes estim�es ?
-- 34,1113

-- visualisation des statistiques
-- pour city = london
DBCC SHOW_STATISTICS ("Person.Address", [IX_Address_City]);
-- Visiblement pas de l'histogramme
-- sinon l'estimation aurait �t� correcte


-- C'est l� que la densit� intervient.
-- SQL Server n'arrive pas � sniffer le param�tre, 
-- il doit donc faire un choix sur une valeur repr�sentative 
-- globalement du nombre d'occurence pour une valeur donn�e
SELECT 0.00173913 * 19614.0


-- Donc, si SQL ne parvient pas � r�cup�rer une valeur de param�tre, 
-- il se fie � la densit�, ce qui peut poser des probl�mes de performance
-- comme on vient de le voir
