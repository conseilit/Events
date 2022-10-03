#==============================================================================
#
#  Summary:  Configure for tracking tempdb issues
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

Clear-Host

# Connect the instance
$InstanceName = "DPS2022"
$Server = Connect-DbaInstance -SqlInstance $InstanceName 
$Server | Select-Object DomainInstanceName,VersionMajor,EngineEdition


Invoke-DbaQuery -SqlInstance $Server -Database "master" -Query "
    CREATE EVENT SESSION [TempDBAutogrowth] ON SERVER 
    ADD EVENT sqlserver.database_file_size_change(
        ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text)
        WHERE ([database_id]=(2) AND [session_id]>(50))),
    ADD EVENT sqlserver.databases_log_file_size_changed(
        ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text)
        WHERE ([database_id]=(2) AND [session_id]>(50)))
    ADD TARGET package0.event_file(SET filename=N'TempDBAutogrowth',max_file_size=(50),max_rollover_files=(10))
    WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=ON,STARTUP_STATE=ON)
" | Out-Null

Start-DbaXESession -SqlInstance $Server -Session "TempDBAutogrowth"| Out-Null

# Check TempDB Database
(Get-DbaDatabase -SqlInstance $server -Database tempdb).filegroups["PRIMARY"].files `
        | Select-Object Name,Size,UsedSpace,AvailableSpace,Growth,GrowthType | Format-Table -AutoSize



Invoke-DbaQuery -SqlInstance $Server -Database "master" -Query "
        SELECT *
        INTO [tempdb].[dbo].[orders]
        FROM [Performance].[dbo].[orders]
    " 

# Reconnect to update information
$Server = Connect-DbaInstance -SqlInstance $InstanceName 
(Get-DbaDatabase -SqlInstance $server -Database tempdb).filegroups["PRIMARY"].files `
    | Select-Object Name,Size,UsedSpace,AvailableSpace,Growth,GrowthType `
    | Format-Table -AutoSize


<#

    -- Bonus : record TempDB usage

    USE [_DBA]
    GO
    CREATE TABLE TempDBUsage (
        [CollectTime] [datetime] NOT NULL,
        [usr_obj_kb] INT NULL,
        [internal_obj_kb] INT NULL,
        [version_store_kb] INT NULL,
        [freespace_kb] INT NULL,
        [mixedextent_kb] INT NULL
    )
    GO
    CREATE CLUSTERED INDEX [CI_TempDBUsage_CollectTime] 
    ON [dbo].[TempDBUsage]
    (
        [CollectTime] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
    GO



    USE [msdb]
    GO
    BEGIN TRANSACTION
    DECLARE @ReturnCode INT
    SELECT @ReturnCode = 0

    IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
    BEGIN
    EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

    END

    DECLARE @jobId BINARY(16)
    EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'_DBA - TempDBUsage', 
            @enabled=1, 
            @notify_level_eventlog=0, 
            @notify_level_email=0, 
            @notify_level_netsend=0, 
            @notify_level_page=0, 
            @delete_level=0, 
            @description=N'No description available.', 
            @category_name=N'[Uncategorized (Local)]', 
            @owner_login_name=N'sa', @job_id = @jobId OUTPUT
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

    EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Log to table', 
            @step_id=1, 
            @cmdexec_success_code=0, 
            @on_success_action=3, 
            @on_success_step_id=0, 
            @on_fail_action=2, 
            @on_fail_step_id=0, 
            @retry_attempts=0, 
            @retry_interval=0, 
            @os_run_priority=0, @subsystem=N'TSQL', 
            @command=N'
    INSERT INTO _DBA.dbo.TempDBUsage
    SELECT
        getdate()									as CollectTime,
        SUM (user_object_reserved_page_count)*8     as usr_obj_kb,
        SUM (internal_object_reserved_page_count)*8 as internal_obj_kb,
        SUM (version_store_reserved_page_count)*8   as version_store_kb,
        SUM (unallocated_extent_page_count)*8       as freespace_kb,
        SUM (mixed_extent_page_count)*8             as mixedextent_kb
    FROM sys.dm_db_file_space_usage;
    ', 
            @database_name=N'tempdb', 
            @flags=0
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

    EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Purge data', 
            @step_id=2, 
            @cmdexec_success_code=0, 
            @on_success_action=1, 
            @on_success_step_id=0, 
            @on_fail_action=2, 
            @on_fail_step_id=0, 
            @retry_attempts=0, 
            @retry_interval=0, 
            @os_run_priority=0, @subsystem=N'TSQL', 
            @command=N'DELETE FROM _DBA.dbo.TempDBUsage
    WHERE CollectTime < DATEADD(WEEK,-4,getdate())', 
            @database_name=N'master', 
            @flags=0
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
    EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
    EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'CollectorSchedule_Every_5min', 
            @enabled=1, 
            @freq_type=4, 
            @freq_interval=1, 
            @freq_subday_type=4, 
            @freq_subday_interval=5, 
            @freq_relative_interval=0, 
            @freq_recurrence_factor=0, 
            @active_start_date=20120210, 
            @active_end_date=99991231, 
            @active_start_time=0, 
            @active_end_time=235959
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
    EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
    COMMIT TRANSACTION
    GOTO EndSave
    QuitWithRollback:
        IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
    EndSave:
    GO




#>
