--==============================================================================
--
--  Summary:  SQLSaturday Montréal #758 - 2018
--  Date:     06/2018
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



USE Master
GO

DBCC DROPCLEANBUFFERS;

SELECT * FROM sys.dm_os_buffer_descriptors
WHERE database_id = DB_ID('performance')
GO

SELECT * FROM sys.dm_os_buffer_descriptors
WHERE database_id = DB_ID('ContosoRetailDW')
GO
-- new session 

SELECT * FROM sys.dm_exec_session_wait_stats WHERE session_id = @@spid
ORDER BY wait_time_ms DESC;


SELECT *
INTO #temptable
FROM Performance.dbo.Orders
OPTION (maxdop 1);

SELECT *
INTO #temptable
FROM ContosoRetailDW.dbo.FactOnlineSales
OPTION (maxdop 1);

SELECT * FROM sys.dm_exec_session_wait_stats WHERE session_id = @@spid
ORDER BY wait_time_ms DESC;