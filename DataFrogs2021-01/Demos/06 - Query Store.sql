--==============================================================================
--
--  Summary:  Query Store
--  Date:     04/2021
--
--  ----------------------------------------------------------------------------
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
--==============================================================================

USE master
GO

CREATE DATABASE DemoQS
GO

USE DemoQS
GO


CREATE TABLE dbo.Customer( 
	 Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	 FirstName NVARCHAR(50), 
	 LastName NVARCHAR(50))
GO

-- Populate 100,000 customers with unique FirstName 
INSERT INTO dbo.Customer (FirstName, LastName)
SELECT TOP 100000 NEWID(), NEWID()
FROM SYS.all_columns SC1 
    CROSS JOIN SYS.all_columns SC2
GO 

-- Populate 15000 customers with FirstName as Chris
INSERT INTO dbo.Customer (FirstName, LastName)
SELECT TOP 15000 'Chris', NEWID()
FROM SYS.all_columns SC1
CROSS JOIN SYS.all_columns SC2


CREATE INDEX IX_Customer_FirstName on dbo.Customer (FirstName)
GO


CREATE PROCEDURE dbo.GetCustomersByFirstName
(@FirstName AS NVARCHAR(50))
AS
BEGIN
    SELECT * FROM dbo.Customer 
    WHERE FirstName = @FirstName
END

-- Enable QS


-- Show query plan

EXEC dbo.GetCustomersByFirstName @FirstName = N'Abc'


-- View top resource consuming queries report


-- remove query plan from cache
DBCC FREEPROCCACHE

-- Cluster index scan query plan
EXEC dbo.GetCustomersByFirstName @FirstName = N'Chris'

-- Still cluster index scan query plan ...
EXEC dbo.GetCustomersByFirstName @FirstName = N'Abc'


-- force query plan

