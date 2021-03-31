--==============================================================================
--
--  Summary:  Historical Activity
--  Date:     03/2021
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

SELECT * FROM sys.dm_exec_query_stats
OUTER APPLY sys.dm_exec_sql_text(sql_handle) 
ORDER BY last_elapsed_time desc 

USE AdventureWorks
GO

SELECT SalesOrderID,SalesOrderDetailID,ProductID
FROM Sales.SalesOrderDetail

SELECT sod.SalesOrderID,sod.SalesOrderDetailID,sod.ProductID,
       p.Name
FROM Sales.SalesOrderDetail sod
INNER JOIN Production.Product p on p.ProductID = sod.ProductID
GO

CREATE FUNCTION Sales.ufn_getProductName (
    @ProductID int
)
RETURNS VARCHAR(50)
AS
BEGIN 
    RETURN (
        SELECT Name 
        FROM Production.Product
        WHERE ProductID=@ProductID
    )
END
GO

SELECT Sales.ufn_getProductName (777) 
GO

SELECT sod.SalesOrderID,sod.SalesOrderDetailID,sod.ProductID,
       Sales.ufn_getProductName (sod.ProductID)
FROM Sales.SalesOrderDetail sod
GO

SELECT * FROM sys.dm_exec_function_stats
OUTER APPLY sys.dm_exec_sql_text(sql_handle) 
ORDER BY execution_count desc 
GO

