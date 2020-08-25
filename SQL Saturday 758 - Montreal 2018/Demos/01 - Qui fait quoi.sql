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



SELECT er.*,es.*,ec.*
FROM sys.dm_exec_sessions AS es  
INNER JOIN sys.dm_exec_connections AS ec  ON es.session_id = ec.session_id
inner join sys.dm_exec_requests AS er on er.connection_id = ec.connection_id 
WHERE es.session_id <> @@SPID
AND es.is_user_process = 1


EXEC sp_whoisactive @show_sleeping_spids =1,
				@get_task_info=2,
				@get_additional_info =1,
				@get_full_inner_text = 1,	
				@get_outer_command = 1,
				@get_locks = 1,
				@find_block_leaders = 1,
				@get_plans = 1
