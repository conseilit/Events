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

-- rampup
SELECT *
INTO #temptable
FROM Performance.dbo.Orders

SELECT *
FROM sys.dm_os_waiting_tasks
WHERE session_id=56

-- new session 

	SELECT * FROM sys.dm_exec_session_wait_stats WHERE session_id = @@spid
	ORDER BY wait_time_ms DESC;


	SELECT *
	FROM ContosoRetailDW.dbo.FactOnlineSales


	SELECT * FROM sys.dm_exec_session_wait_stats WHERE session_id = @@spid
	ORDER BY wait_time_ms DESC;


