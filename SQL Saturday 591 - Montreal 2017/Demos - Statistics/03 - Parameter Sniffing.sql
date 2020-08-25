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

-- Affichage du plan d'exécution


-- Retour sur la requête avec 2 plans différents
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


-- Faisons plaisir à SQL Server
-- Création de l'index manquant
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



-- Une même requête
-- la même condition Where
-- un plan différent, sans cluster index scan

-- Pourquoi ?
-- Visualisation du plan d'exécution
-- estimated number of rows <> actual number of rows


-- L'optimiseur de requêtes de SQL Server
-- n'a pas réussi à "sniffer" le paramètre
-- cela se vérife dans les donnes XML du plan

-- Doù provient le nombre de lignes estimées ?
-- 34,1113

-- visualisation des statistiques
-- pour city = london
DBCC SHOW_STATISTICS ("Person.Address", [IX_Address_City]);
-- Visiblement pas de l'histogramme
-- sinon l'estimation aurait été correcte


-- C'est là que la densité intervient.
-- SQL Server n'arrive pas à sniffer le paramètre, 
-- il doit donc faire un choix sur une valeur représentative 
-- globalement du nombre d'occurence pour une valeur donnée
SELECT 0.00173913 * 19614.0


-- Donc, si SQL ne parvient pas à récupérer une valeur de paramètre, 
-- il se fie à la densité, ce qui peut poser des problèmes de performance
-- comme on vient de le voir
