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

select 
	DB_NAME(database_id) as DatabaseName,
	OBJECT_NAME(object_id,database_id) as TableName,
	object_id,index_id,
	forwarded_fetch_count,
	row_lock_count,row_lock_wait_count,row_lock_wait_in_ms,
	page_lock_count,page_lock_wait_count,page_lock_wait_in_ms
from sys.dm_db_index_operational_stats(null,null,null,null)
order by forwarded_fetch_count desc
--order by row_lock_wait_count desc