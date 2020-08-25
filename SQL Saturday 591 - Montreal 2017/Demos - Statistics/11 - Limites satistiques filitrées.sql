/*============================================================================
  File:     
  Summary:  Limites statistiques filtr�es
  Date:     11/2013
  SQL Server Versions: 11 (SS2012)
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

-- affichage du plan d'ex�cution

-- Estimation pr�cises gr�ce aux statistiques filtr�es
SELECT * 
FROM [dbo].[FactOnlineSales]
WHERE ProductKey = 1750;

SELECT * 
FROM [dbo].[FactOnlineSales]
WHERE ProductKey = 1751;

SELECT * 
FROM [dbo].[FactOnlineSales]
WHERE ProductKey BETWEEN 1700 AND 1750;


-- Sauf
SELECT * 
FROM [dbo].[FactOnlineSales]
WHERE ProductKey IN (875,1827)
-- lorsque l'on s�lectionne des donn�es 
-- sur plusieurs intervalles !

-- L'histogramme montre un AVG_RANGE_ROW de  2640,806 
-- pour le produckey 875 (actual rows 391)
-- et un EQ_ROWS de 304 pour le productkey 1827
-- => Estimated rows � 2944.81

-- en modifiant la requ�te pour aider l'optimiseur
-- en choisisant des statistiques plus pr�cises

SELECT * 
FROM [dbo].[FactOnlineSales]
WHERE ProductKey IN (875,1827);


	SELECT * 
	FROM [dbo].[FactOnlineSales]
	WHERE ProductKey = 875
UNION ALL
	SELECT * 
	FROM [dbo].[FactOnlineSales]
	WHERE ProductKey = 1827;

-- l'optimiseur trouve un meilleur plan
-- et la part relative des requ�tes montre clairement
-- qu'une meilleure estimation du nombre de lignes
-- diminue le cout de la requ�te ...

