--============================================================================
--  
--  Written by Christophe LAPORTE, SQL Server MVP / MCM
--	Blog    : http://conseilit.wordpress.com
--	Twitter : @ConseilIT
--  
--  You may alter this code for your own *non-commercial* purposes. You may
--  republish altered code as long as you give due credit.
--  
--  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
--  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
--  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
--  PARTICULAR PURPOSE.
--
--============================================================================

USE [AdventureWorks2017]
GO

SELECT *
FROM [Production].[Product]
WHERE ProductID=715;













-- Find the data page
SELECT sys.fn_physLocFormatter (%%physloc%%) as RowLocator,*
FROM [Production].[Product]
WHERE ProductID=715;

-- Crack the Data Page
DBCC TRACEON(3604)
DBCC PAGE(0,1,16131,3)

