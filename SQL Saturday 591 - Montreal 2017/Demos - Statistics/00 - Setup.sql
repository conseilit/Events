/*============================================================================
  File:     
  Summary:  Restore DB
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
RESTORE DATABASE [AdventureWorks] 
FROM  DISK = N'C:\Temp\AdventureWorks_backup_2010_01_12_195123_0026623.bak' 
WITH  REPLACE, FILE = 1,  NOUNLOAD,  STATS = 5
GO


USE [master]
RESTORE DATABASE [ContosoRetailDW] 
FROM  DISK = N'C:\Temp\ContosoRetailDW.bak' 
WITH  FILE = 1,  REPLACE,
MOVE N'ContosoRetailDW2.0' TO N'C:\Data\ContosoRetailDW.mdf',  
MOVE N'ContosoRetailDW2.0_log' TO N'C:\Data\ContosoRetailDW.ldf', 
NOUNLOAD,  STATS = 5
GO


USE [master]
RESTORE DATABASE [AdventureWorks2008] 
FROM  DISK = N'C:\Temp\AdventureWorks2008_backup_2010_01_12_195123_0066625.bak' 
WITH  FILE = 1,  REPLACE,
MOVE N'AdventureWorks2008_Data' TO N'C:\Data\AdventureWorks2008_Data.mdf', 
MOVE N'AdventureWorks2008_Log' TO N'C:\Data\AdventureWorks2008_Log.ldf', 
MOVE N'FileStreamDocuments' TO N'C:\Data\Documents',  NOUNLOAD,  STATS = 5
GO





DROP DATABASE [TestStatistics]
GO


CREATE DATABASE [TestStatistics]
GO

USE [master]
GO
ALTER DATABASE [TestStatistics] 
MODIFY FILE ( NAME = N'TestStatistics', SIZE = 4GB )
GO
ALTER DATABASE [TestStatistics] 
MODIFY FILE ( NAME = N'TestStatistics_log', SIZE = 3170304KB )
GO

Use [TestStatistics]
go

-- ajout des données : 40 secondes (2012)
SELECT * 
INTO FactOnlineSales
FROM ContosoRetailDW.dbo.FactOnlineSales
GO

-- ajout de la PK : 12 secondes (1min08 SQL2012)
ALTER TABLE FactOnlineSales
ADD CONSTRAINT PK_FactOnlineSales PRIMARY KEY (OnlineSalesKey);
GO
