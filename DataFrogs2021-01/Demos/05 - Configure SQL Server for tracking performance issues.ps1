#==============================================================================
#
#  Summary:  Configure for tracking performance issues
#  Date:     04/2021
#
#  ----------------------------------------------------------------------------
#  Written by Christophe LAPORTE, SQL Server MVP / MCM
#	Blog    : http://conseilit.wordpress.com
#	Twitter : @ConseilIT
#  
#  You may alter this code for your own *non-commercial* purposes. You may
#  republish altered code as long as you give due credit.
#  
#  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
#  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
#  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
#  PARTICULAR PURPOSE.
#==============================================================================



# connect the instance
$InstanceName = "DataFrogs"
$Server = Connect-DbaInstance -SqlInstance $InstanceName 



# Install sp_whoisactive stored procedure. Thanks Adam Machanic 
# Feedback: mailto:adam@dataeducation.com
# Updates: http://whoisactive.com
# Blog: http://dataeducation.com
$dbaDatabase = "_DBA"
Install-DbaWhoIsActive -SqlInstance $Server -Database $dbaDatabase



Set-DbaSpConfigure -SqlInstance $Server -name BlockedProcessThreshold -value 1

# create my own xEvent session to trakc performance issues
Invoke-DbaQuery -SqlInstance $Server -Database "master" -Query "
    CREATE EVENT SESSION [PerformanceIssues] ON SERVER 
    ADD EVENT sqlserver.blocked_process_report(
        ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.query_hash,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)),
    ADD EVENT sqlserver.lock_timeout_greater_than_0(SET collect_database_name=(0)
        ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)),
    ADD EVENT sqlserver.locks_lock_waits(
        ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)
        WHERE ([increment]>=(1000) AND [count]<=(100))),
    ADD EVENT sqlserver.rpc_completed(SET collect_statement=(1)
        ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.query_hash,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)
        WHERE ([package0].[greater_than_equal_uint64]([duration],(250000)))),
    ADD EVENT sqlserver.sql_batch_completed(
        ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.query_hash,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)
        WHERE ([package0].[greater_than_equal_uint64]([duration],(250000)))),
    ADD EVENT sqlserver.xml_deadlock_report(
        ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.query_hash,sqlserver.session_id,sqlserver.sql_text,sqlserver.username))
    ADD TARGET package0.event_file(SET filename=N'PerformanceIssues',max_file_size=(50),max_rollover_files=(10))
    WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=ON,STARTUP_STATE=ON)
"
Start-DbaXESession -SqlInstance $Server -Session "PerformanceIssues"

# maybe remove the event from system_health
Invoke-DbaQuery -SqlInstance $Server -Database "master" -Query "
    ALTER EVENT SESSION [system_health] ON SERVER
    DROP EVENT sqlserver.xml_deadlock_report;
"


# Optional :
<#
    ADD EVENT sqlserver.attention(
        WHERE (package0.greater_than_uint64(database_id,(4)) 
        AND package0.equal_boolean(sqlserver.is_system,(0)))) ,
    ADD EVENT sqlserver.auto_stats(
        WHERE (package0.greater_than_uint64(database_id,(4)) 
        AND package0.equal_boolean(sqlserver.is_system,(0)) 
        AND package0.greater_than_equal_int64(object_id,(1000000)) 
        AND package0.greater_than_uint64(duration,(10)))),
    ADD EVENT sqlserver.database_file_size_change,
    ADD EVENT sqlserver.database_started,
    ADD EVENT sqlserver.lock_escalation,
    ADD EVENT sqlserver.lock_timeout_greater_than_0, 
    ADD EVENT sqlserver.long_io_detected,

    ADD EVENT qds.query_store_plan_forcing_failed,
    ADD EVENT sqlserver.exchange_spill,
    ADD EVENT sqlserver.execution_warning,
    ADD EVENT sqlserver.hash_spill_details,
    ADD EVENT sqlserver.hash_warning,
    ADD EVENT sqlserver.optimizer_timeout,
    ADD EVENT sqlserver.query_memory_grant_blocking,
    ADD EVENT sqlserver.query_memory_grants,
    ADD EVENT sqlserver.sort_warning,       
    ADD EVENT sqlserver.window_spool_ondisk_warning
#>

<#
-- Demo Blocked Process report / deadlock

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



-- Now let's create a deadlock
-- Session 2
    update Production.Product
    set name = 'Session 2 - Product 722'
    where ProductID = 722


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

#>