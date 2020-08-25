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



select top 5 * 
from sys.dm_exec_query_stats
cross apply sys.dm_exec_query_plan(plan_handle)
order by last_elapsed_time desc 


select top 5 * 
from sys.dm_exec_query_stats
cross apply sys.dm_exec_query_plan(plan_handle)
order by last_logical_reads desc 

