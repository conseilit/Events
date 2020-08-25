/*============================================================================
  File:     
  Summary:  Statistiques auto générées
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

-- affichage du plan d'exécution

ALTER DATABASE [TestStatistics] 
SET AUTO_CREATE_STATISTICS ON WITH NO_WAIT
GO

-- Visu stats utilisées par optimiseur
DBCC TRACEON(8666)

SELECT *
FROM OrderDetail 
WHERE SalesOrderID = 43692




-- Estimation pas très précise dans ce cas là, 
-- Mais mieux que sans statistiques.

-- Moralité : laisser auto create stats a on

-- Visualisation de la statistiques dans SSMS

-- Déchiffrer le nom de la statistique auto générée

-- http://www.sqlservercentral.com/scripts/T-SQL/31486/ 
/*
	Input has to be a Valid Hexadecimal number. Example 4F or 04F or 004F. 
	7FFFFFFF is the maximum value and it gives 2147483647 (Max INT)

	Hans Lindgren
*/

CREATE FUNCTION dbo.HexToINT 
(
	@Value VARCHAR(8)
)
RETURNS INT
AS
BEGIN

SET @Value =  REVERSE( RIGHT( UPPER( '0000000' + @Value ) , 8 ) )

RETURN (
                (CHARINDEX( SUBSTRING( @Value , 1 , 1 ) , '0123456789ABCDEF' , 1 ) - 1 ) +
      16*       (CHARINDEX( SUBSTRING( @Value , 2 , 1 ) , '0123456789ABCDEF' , 1 ) - 1 ) +
      256*      (CHARINDEX( SUBSTRING( @Value , 3 , 1 ) , '0123456789ABCDEF' , 1 ) - 1 ) +
      4096*     (CHARINDEX( SUBSTRING( @Value , 4 , 1 ) , '0123456789ABCDEF' , 1 ) - 1 ) +
      65536*    (CHARINDEX( SUBSTRING( @Value , 5 , 1 ) , '0123456789ABCDEF' , 1 ) - 1 ) +
      1048576*  (CHARINDEX( SUBSTRING( @Value , 6 , 1 ) , '0123456789ABCDEF' , 1 ) - 1 ) +
      16777216* (CHARINDEX( SUBSTRING( @Value , 7 , 1 ) , '0123456789ABCDEF' , 1 ) - 1 ) +
      268435456*(CHARINDEX( SUBSTRING( @Value , 8 , 1 ) , '0123456789ABCDEF' , 1 ) - 1 )
		)
END
GO


-- 2014 [_WA_Sys_00000001_117F9D94]
-- 2012 [_WA_Sys_00000001_108B795B]
SELECT name AS TableName FROM sys.tables
WHERE object_id = dbo.HexToINT('108B795B');

SELECT name as ColumName FROM sys.columns
WHERE object_id = dbo.HexToINT('108B795B')
AND   column_id = dbo.HexToINT('00000001');

-- Le nom de la statistique n'est pas si obscur que cela ...




-- Conclusion : sauf cas spécifique, on laisse auto_create_stats à ON

DBCC TRACEOFF(8666)


