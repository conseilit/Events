/*============================================================================
  File:     
  Summary:  F5 et la magie opère
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

DBCC FREEPROCCACHE;
Go

-- Affichage du plan d'exécution


SELECT * FROM [Person].[Address]
WHERE [City] = 'LONDON'

SELECT * FROM [Person].[Address]
WHERE [City] = 'NEWARK'
Go





-- Une même requete : 2 plans différents
-- => SQL Server est capable d'adapter un plan d'exécution à la requête
-- De quels moyens dispose SQL Server pour choisir un "bon" plan