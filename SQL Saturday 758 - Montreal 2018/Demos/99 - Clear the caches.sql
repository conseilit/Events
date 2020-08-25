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


-- Clear the caches
CHECKPOINT
DBCC DROPCLEANBUFFERS
DBCC FREEPROCCACHE
DBCC SQLPERF('sys.dm_os_wait_stats',CLEAR)
DBCC SQLPERF('sys.dm_os_latch_stats',CLEAR)


-- Code to set measurements
SET STATISTICS IO ON
SET STATISTICS TIME ON
SET SHOWPLAN_XML ON -- or GUI
SET STATISTICS PROFILE ON