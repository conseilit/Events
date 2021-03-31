--==============================================================================
--
--  Summary:  Current activity
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

-- user sessions
SELECT es.session_id,es.host_name,es.program_name,es.login_name,es.status
FROM sys.dm_exec_sessions es
WHERE es.is_user_process = 1


-- user sessions with connection infos
SELECT es.session_id,es.host_name,es.program_name,es.login_name,es.status,es.last_request_end_time,
	   ec.net_transport,ec.auth_scheme,ec.client_net_address,client_tcp_port
FROM sys.dm_exec_sessions es
INNER JOIN sys.dm_exec_connections ec ON ec.session_id = es.session_id
WHERE es.is_user_process = 1


-- user sessions with associated requests
SELECT es.session_id,es.host_name,es.program_name,es.login_name,es.status,es.last_request_end_time,
	   ec.net_transport,ec.auth_scheme,ec.client_net_address,client_tcp_port,
	   er.start_time,er.status,er.database_id,er.blocking_session_id,er.wait_type,er.wait_time,er.wait_resource, er.open_transaction_count
FROM sys.dm_exec_sessions es
INNER JOIN sys.dm_exec_connections ec ON ec.session_id = es.session_id
LEFT JOIN sys.dm_exec_requests er ON es.session_id = er.session_id
WHERE es.is_user_process = 1


-- user sessions with associated requests statements
SELECT es.session_id,es.host_name,es.program_name,es.login_name,es.status,es.last_request_end_time,
	   ec.net_transport,ec.auth_scheme,ec.client_net_address,client_tcp_port,
	   er.start_time,er.status,er.database_id,er.blocking_session_id,er.wait_type,er.wait_time,er.wait_resource, er.open_transaction_count,
	   sql.text
FROM sys.dm_exec_sessions es
INNER JOIN sys.dm_exec_connections ec ON ec.session_id = es.session_id
LEFT JOIN sys.dm_exec_requests er ON es.session_id = er.session_id
OUTER APPLY sys.dm_exec_sql_text(ec.most_recent_sql_handle) sql
WHERE es.is_user_process = 1

-- and getting locking informations
SELECT * FROM sys.dm_tran_locks
WHERE request_session_id IN (62,54)



-- Much more simpler to use a stored procedure
-- which gather all necessary information

-- Adam Machanic ( adam@dataeducation.com )
-- Updates: http://whoisactive.com
-- Blog: http://dataeducation.com

EXEC _dba.dbo.sp_WhoIsActive @show_sleeping_spids =1,
							 @get_task_info=2,
							 @get_additional_info =1,
							 @get_full_inner_text = 1,	
							 @get_outer_command = 1,
							 @get_locks = 1,
							 @find_block_leaders = 1,
							 @get_plans = 1

