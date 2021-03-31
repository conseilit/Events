--==============================================================================
--
--  Summary:  Blocked Process report / deadlock
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

-- Session 1
Use AdventureWorks
GO
BEGIN TRAN
 
    update Production.Product
    set name = 'Session 1 - Product 722'
    where ProductID = 722



-- Session 2
Use AdventureWorks
GO
BEGIN TRAN
     
    update Production.Product
    set name = 'Session 2 - Product 512'
    where ProductID = 512


-- Session 1
    update Production.Product
    set name = 'Session 1 - Product 512'
    where ProductID = 512    


-- Blocked Process report should occur


-- Find the table
SELECT  c.name as schema_name, 
        o.name as object_name, 
        i.name as index_name,
        p.object_id,p.index_id,p.partition_id,p.hobt_id
FROM sys.partitions AS p
INNER JOIN sys.objects as o on p.object_id=o.object_id
INNER JOIN sys.indexes as i on p.index_id=i.index_id and p.object_id=i.object_id
INNER JOIN sys.schemas AS c on o.schema_id=c.schema_id
WHERE p.hobt_id = 72057594045136896;


-- Find the records
SELECT %%lockres%%,sys.fn_physLocFormatter (%%physloc%%) as RID,* 
FROM Production.Product
WHERE %%lockres%% in ('(4637a194cfd9)','(b147776edda1)');

-- Show the datapage and find the record
DBCC TRACEON(3604)
DBCC PAGE('Adventureworks',1,788,3)

-- Now let's create a deadlock
-- Session 2
    update Production.Product
    set name = 'Session 2 - Product 722'
    where ProductID = 722



