﻿#==============================================================================
#
#  Summary:  SQL Server configuration using dbaTools
#  Date:     03/2021
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

# Script based on dbaTools commands
# Thanks to Chrissy LeMaire (@cl | https://blog.netnerds.net/ )
#          , Row Sewell (@SQLDBAWithBeard | https://sqldbawithabeard.com/)
#          , and all SQL Server community
# http://dbatools.io
# Install-Module dbatools 



<#
    [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.BatchParser.dll') | out-null

    # issue TLS support
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#>

Clear-Host
$InstanceName = "HaitianSQLDay"
$dbaDatabase = "_DBA"
$CleanupTime = 15 <# days #> * 24
$InstallDbaWhoIsActive = $true

# check connection to the instance
$Server = Connect-DbaInstance -SqlInstance $InstanceName
#$cred = Get-Credential
#$Server = Connect-DbaInstance -SqlInstance $InstanceName -SqlCredential $cred
$Server | Select-Object DomainInstanceName,VersionMajor,EngineEdition

#region SQL Server properties configuration

    Set-DbaErrorLogConfig -SqlInstance $Server -LogCount 99 | Out-Null
    Set-DbaSpConfigure -SqlInstance $Server -name RemoteDacConnectionsEnabled -value 1 | Out-Null
    Set-DbaSpConfigure -SqlInstance $Server -name OptimizeAdhocWorkloads -value 1 | Out-Null
    Set-DbaSpConfigure -SqlInstance $Server -name CostThresholdForParallelism -value 25 | Out-Null
    Set-DbaSpConfigure -SqlInstance $Server -name DefaultBackupCompression -value 1 | Out-Null
    Set-DbaSpConfigure -SqlInstance $Server -name BlockedProcessThreshold -value 1 | Out-Null
    Set-DbaSpConfigure -SqlInstance $Server -name ContainmentEnabled -value 1 | Out-Null

    # Export-DbaSpConfigure -SqlInstance $Server -Path "D:\ConfigurationScripts"

    # Change the retention settings for system_health Extended Events session
    Stop-DbaXESession -SqlInstance $Server -Session "system_health"  | Out-Null
    Invoke-DbaQuery -SqlInstance $Server -Database "master" -Query "
        ALTER EVENT SESSION [system_health] ON SERVER
        DROP TARGET package0.event_file;
        GO
        ALTER EVENT SESSION [system_health] ON SERVER
        ADD TARGET package0.event_file
            (SET FILENAME=N'system_health.xel',
                max_file_size=(25),
                max_rollover_files=(20)
            )
    " 
    Start-DbaXESession -SqlInstance $Server -Session "system_health" | Out-Null


    # Change the retention settings for AlwaysOn_health Extended Events session
    Stop-DbaXESession -SqlInstance $Server -Session "AlwaysOn_health" | Out-Null
    Invoke-DbaQuery -SqlInstance $Server -Database "master" -Query "
        ALTER EVENT SESSION [AlwaysOn_health] ON SERVER
        DROP TARGET package0.event_file;
        GO
        ALTER EVENT SESSION [AlwaysOn_health] ON SERVER
        ADD TARGET package0.event_file
            (SET FILENAME=N'AlwaysOn_health.xel',
                max_file_size=(25),
                max_rollover_files=(20)
            )

    "


    # Stop collecting noise events
    # https://www.sqlskills.com/blogs/erin/the-security_error_ring_buffer_recorded-event-and-why-you-dont-need-it/
    Invoke-DbaQuery -SqlInstance $Server -Database "master" -Query "
        ALTER EVENT SESSION [system_health] ON SERVER
        DROP EVENT sqlserver.security_error_ring_buffer_recorded;
    "
    

    
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
            ADD TARGET package0.event_file(SET filename=N'Long running Queries',max_file_size=(50),max_rollover_files=(10))
            WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=ON,STARTUP_STATE=ON)
    "
    Start-DbaXESession -SqlInstance $Server -Session "PerformanceIssues" | Out-Null

    # maybe remove the event from system_health
    Invoke-DbaQuery -SqlInstance $Server -Database "master" -Query "
        ALTER EVENT SESSION [system_health] ON SERVER
        DROP EVENT sqlserver.xml_deadlock_report;
    "

    # increase SQL Agent default retention
    if (!($(Get-DbaInstanceProperty -SqlInstance $Server -InstanceProperty  Edition).value -Match "Express")){
        Set-DbaAgentServer -SqlInstance $Server -MaximumHistoryRows 999999 -MaximumJobHistoryRows 999999 | Out-Null
    }
    
#endregion


# Create DBA database if needed
if (!(Get-DbaDatabase -SqlInstance $Server -Database $dbaDatabase)){
    $dbaDB = New-DbaDatabase -SqlInstance $Server -Name $dbaDatabase
    $dbaDB | Set-DbaDbRecoveryModel -RecoveryModel Simple -Confirm:$false | Out-Null
} else {
    Write-Host "[$dbaDatabase] database already exists"
}

# Install sp_whoisactive stored procedure. Thanks Adam Machanic 
# Feedback: mailto:adam@dataeducation.com
# Updates: http://whoisactive.com
# Blog: http://dataeducation.com
if ($InstallDbaWhoIsActive) {
    Install-DbaWhoIsActive -SqlInstance $Server -Database $dbaDatabase 
}

#region Install Database maintenance objects
# https://ola.hallengren.com/

    $defaultbackuplocation = (Get-DbaDefaultPath -SqlInstance $Server).Backup

    if ($defaultbackuplocation -eq $((Get-DbaDefaultPath -SqlInstance $Server).Backup)){
        Install-DbaMaintenanceSolution -SqlInstance $Server.Name -Database $dbaDatabase -CleanupTime $CleanupTime -InstallJobs -LogToTable -ReplaceExisting    
    } else {
        Install-DbaMaintenanceSolution -SqlInstance $Server.Name -Database $dbaDatabase -BackupLocation $defaultbackuplocation -CleanupTime $CleanupTime -InstallJobs -LogToTable -ReplaceExisting
    }

    $tSQL = "
        CREATE PROCEDURE dbo.sp_sp_start_job_wait
        (
            @job_name SYSNAME,
            @WaitTime DATETIME = '00:00:30', -- this is parameter for check frequency
            @JobCompletionStatus INT = null OUTPUT
        )
        AS
        BEGIN
            -- https://www.mssqltips.com/sqlservertip/2167/custom-spstartjob-to-delay-next-task-until-sql-agent-job-has-completed/

            SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
            SET NOCOUNT ON

            -- DECLARE @job_name sysname
            DECLARE @job_id UNIQUEIDENTIFIER
            DECLARE @job_owner sysname

            --Createing TEMP TABLE
            CREATE TABLE #xp_results (	job_id UNIQUEIDENTIFIER NOT NULL,
                                        last_run_date INT NOT NULL,
                                        last_run_time INT NOT NULL,
                                        next_run_date INT NOT NULL,
                                        next_run_time INT NOT NULL,
                                        next_run_schedule_id INT NOT NULL,
                                        requested_to_run INT NOT NULL, -- BOOL
                                        request_source INT NOT NULL,
                                        request_source_id sysname COLLATE database_default NULL,
                                        running INT NOT NULL, -- BOOL
                                        current_step INT NOT NULL,
                                        current_retry_attempt INT NOT NULL,
                                        job_state INT NOT NULL
                                    )

            SELECT @job_id = job_id FROM msdb.dbo.sysjobs
            WHERE name = @job_name

            SELECT @job_owner = SUSER_SNAME()

            INSERT INTO #xp_results
            EXECUTE master.dbo.xp_sqlagent_enum_jobs 1, @job_owner, @job_id 

            -- Start the job if the job is not running
            IF NOT EXISTS(SELECT TOP 1 * FROM #xp_results WHERE running = 1)
                EXEC msdb.dbo.sp_start_job @job_name = @job_name

            -- Give 5 sec for think time.
            WAITFOR DELAY '00:00:05'

            DELETE FROM #xp_results
            INSERT INTO #xp_results
            EXECUTE master.dbo.xp_sqlagent_enum_jobs 1, @job_owner, @job_id 

            WHILE EXISTS(SELECT TOP 1 * FROM #xp_results WHERE running = 1)
            BEGIN

                WAITFOR DELAY @WaitTime

                -- Information 
                -- raiserror('JOB IS RUNNING', 0, 1 ) WITH NOWAIT 

                DELETE FROM #xp_results

                INSERT INTO #xp_results
                EXECUTE master.dbo.xp_sqlagent_enum_jobs 1, @job_owner, @job_id 

            END

            SELECT TOP 1 @JobCompletionStatus = run_status 
            FROM msdb.dbo.sysjobhistory
            WHERE job_id = @job_id
            AND step_id = 0
            ORDER BY run_date DESC, run_time DESC

            IF @JobCompletionStatus <> 1
            BEGIN
                RAISERROR ('[ERROR]:%s job is either failed, cancelled or not in good state. Please check',16, 1, @job_name) WITH LOG
            END

            RETURN @JobCompletionStatus
        END
    "
    Invoke-DbaQuery -SqlInstance $Server -Database $dbaDatabase -Query $tSQL
#endregion

#region Creating jobs for instance housekeeping
$job = New-DbaAgentJob -SqlInstance $Server -Job 'DBA - HouseKeeping' -Category "Database Maintenance" -OwnerLogin sa

New-DbaAgentJobStep -SqlInstance $Server -Job $job.name -StepName "Cycle Errorlog" -Force `
                    -Database master -StepId 1 `
                    -Subsystem "TransactSql" `
                    -Command "EXEC msdb.dbo.sp_cycle_errorlog" `
                    -OnSuccessAction GoToNextStep `
                    -OnFailAction QuitWithFailure | Out-Null

New-DbaAgentJobStep -SqlInstance $Server -Job $job.name -StepName "CommandLog Cleanup" -Force `
                    -Database master -StepId 2 `
                    -Subsystem "TransactSql" `
                    -Command "EXEC msdb.dbo.sp_start_job 'CommandLog Cleanup'" `
                    -OnSuccessAction GoToNextStep `
                    -OnFailAction QuitWithFailure | Out-Null                        
    
New-DbaAgentJobStep -SqlInstance $Server -Job $job.name -StepName "Output File Cleanup" -Force `
                    -Database master -StepId 3 `
                    -Subsystem "TransactSql" `
                    -Command "EXEC msdb.dbo.sp_start_job 'Output File Cleanup'" `
                    -OnSuccessAction GoToNextStep `
                    -OnFailAction QuitWithFailure | Out-Null                        

New-DbaAgentJobStep -SqlInstance $Server -Job $job.name -StepName "sp_delete_backuphistory" -Force `
                    -Database master -StepId 4 `
                    -Subsystem "TransactSql" `
                    -Command "EXEC msdb.dbo.sp_start_job 'sp_delete_backuphistory'" `
                    -OnSuccessAction GoToNextStep `
                    -OnFailAction QuitWithFailure | Out-Null                        

New-DbaAgentJobStep -SqlInstance $Server -Job $job.name -StepName "sp_purge_jobhistory" -Force `
                    -Database master -StepId 5  `
                    -Subsystem "TransactSql" `
                    -Command "EXEC msdb.dbo.sp_start_job 'sp_purge_jobhistory'" `
                    -OnSuccessAction GoToNextStep `
                    -OnFailAction QuitWithFailure | Out-Null                        

New-DbaAgentJobStep -SqlInstance $Server -Job $job.name -StepName "DatabaseMail - Database Mail cleanup" -Force `
                    -Database master -StepId 6 `
                    -Subsystem "TransactSql" `
                    -Command "DECLARE @DeleteBeforeDate DateTime = (Select DATEADD(d,-30, GETDATE()))
                                EXEC msdb.dbo.sysmail_delete_mailitems_sp @sent_before = @DeleteBeforeDate
                                EXEC msdb.dbo.sysmail_delete_log_sp @logged_before = @DeleteBeforeDate" `
                    -OnSuccessAction GoToNextStep `
                    -OnFailAction QuitWithFailure | Out-Null             
                    
New-DbaAgentJobStep -SqlInstance $Server -Job $job.name -StepName "DatabaseIntegrityCheck - SYSTEM_DATABASES" -Force `
                    -Database master -StepId 7 `
                    -Subsystem "TransactSql" `
                    -Command "EXEC [$dbaDatabase].[dbo].sp_sp_start_job_wait @job_name='DatabaseIntegrityCheck - SYSTEM_DATABASES', @WaitTime = '00:01:00'" `
                    -OnSuccessAction GoToNextStep `
                    -OnFailAction QuitWithFailure | Out-Null             
                    

New-DbaAgentJobStep -SqlInstance $Server -Job $job.name -StepName "DatabaseBackup - SYSTEM_DATABASES - FULL" -Force `
                    -Database master -StepId 8 `
                    -Subsystem "TransactSql" `
                    -Command "EXEC [$dbaDatabase].[dbo].sp_sp_start_job_wait @job_name='DatabaseBackup - SYSTEM_DATABASES - FULL', @WaitTime = '00:01:00'" `
                    -OnSuccessAction QuitWithSuccess `
                    -OnFailAction QuitWithFailure | Out-Null             
                    
New-DbaAgentSchedule -SqlInstance $Server -Schedule $job.name -Job $job.name `
                     -FrequencyType Daily -FrequencyInterval Everyday `
                     -FrequencySubdayType Time -FrequencySubDayinterval 0 `
                     -StartTime "000001" -EndTime "235959" -Force | Out-Null

#endregion

#region Database backup
$job = New-DbaAgentJob -SqlInstance $Server -Job 'DBA - USER_DATABASES - FULL' -Category "Database Maintenance" -OwnerLogin sa

New-DbaAgentJobStep -SqlInstance $Server -Job $job.name -StepName "DatabaseIntegrityCheck - USER_DATABASES" -Force `
                    -Database master -StepId 1 `
                    -Subsystem "TransactSql" `
                    -Command "EXEC [$dbaDatabase].[dbo].sp_sp_start_job_wait @job_name='DatabaseIntegrityCheck - USER_DATABASES', @WaitTime = '00:01:00'" `
                    -OnSuccessAction GoToNextStep `
                    -OnFailAction QuitWithFailure | Out-Null

New-DbaAgentJobStep -SqlInstance $Server -Job $job.name -StepName "IndexOptimize - USER_DATABASES" -Force `
                    -Database master -StepId 2 `
                    -Subsystem "TransactSql" `
                    -Command "EXEC [$dbaDatabase].[dbo].sp_sp_start_job_wait @job_name='IndexOptimize - USER_DATABASES', @WaitTime = '00:01:00'" `
                    -OnSuccessAction GoToNextStep `
                    -OnFailAction QuitWithFailure | Out-Null                        
    
New-DbaAgentJobStep -SqlInstance $Server -Job $job.name -StepName "DatabaseBackup - USER_DATABASES - FULL" -Force `
                    -Database master -StepId 3 `
                    -Subsystem "TransactSql" `
                    -Command "EXEC [$dbaDatabase].[dbo].sp_sp_start_job_wait @job_name='DatabaseBackup - USER_DATABASES - FULL', @WaitTime = '00:01:00'" `
                    -OnSuccessAction QuitWithSuccess `
                    -OnFailAction QuitWithFailure | Out-Null                        

                        
New-DbaAgentSchedule -SqlInstance $Server -Schedule $job.name -Job $job.name `
                    -FrequencyType Weekly -FrequencyInterval Sunday `
                    -FrequencySubdayType Time -FrequencySubDayinterval 0 -FrequencyRecurrenceFactor 1 `
                    -StartTime "010000" -EndTime "235959" -Force | Out-Null

#endregion

#region Diff backup
$job = New-DbaAgentJob -SqlInstance $Server -Job 'DBA - USER_DATABASES - DIFF' -Category "Database Maintenance" -OwnerLogin sa

New-DbaAgentJobStep -SqlInstance $Server -Job $job.name -StepName "DatabaseIntegrityCheck - USER_DATABASES" -Force `
                    -Database master -StepId 1 `
                    -Subsystem "TransactSql" `
                    -Command "EXEC [$dbaDatabase].[dbo].sp_sp_start_job_wait @job_name='DatabaseIntegrityCheck - USER_DATABASES', @WaitTime = '00:01:00'" `
                    -OnSuccessAction GoToNextStep `
                    -OnFailAction QuitWithFailure | Out-Null

New-DbaAgentJobStep -SqlInstance $Server -Job $job.name -StepName "IndexOptimize - USER_DATABASES" -Force `
                    -Database master -StepId 2 `
                    -Subsystem "TransactSql" `
                    -Command "EXEC [$dbaDatabase].[dbo].sp_sp_start_job_wait @job_name='IndexOptimize - USER_DATABASES', @WaitTime = '00:01:00'" `
                    -OnSuccessAction GoToNextStep `
                    -OnFailAction QuitWithFailure | Out-Null                        
    
New-DbaAgentJobStep -SqlInstance $Server -Job $job.name -StepName "DatabaseBackup - USER_DATABASES - DIFF" -Force `
                    -Database master -StepId 3 `
                    -Subsystem "TransactSql" `
                    -Command "EXEC [$dbaDatabase].[dbo].sp_sp_start_job_wait @job_name='DatabaseBackup - USER_DATABASES - DIFF', @WaitTime = '00:01:00'" `
                    -OnSuccessAction QuitWithSuccess `
                    -OnFailAction QuitWithFailure | Out-Null                       

                        
New-DbaAgentSchedule -SqlInstance $Server -Schedule $job.name -Job $job.name `
                    -FrequencyType Weekly -FrequencyInterval Monday,Tuesday,Wednesday,Thursday,Friday,Saturday `
                    -FrequencySubdayType Time -FrequencySubDayinterval 0 -FrequencyRecurrenceFactor 1 `
                    -StartTime "010000" -EndTime "235959" -Force | Out-Null
#endregion

#region Log backup
$job = New-DbaAgentJob -SqlInstance $Server -Job 'DBA - USER_DATABASES - LOG' -Category "Database Maintenance" -OwnerLogin sa 

New-DbaAgentJobStep -SqlInstance $Server -Job $job.name -StepName "DatabaseBackup - USER_DATABASES - LOG" -Force `
                    -Database master -StepId 1 `
                    -Subsystem "TransactSql" `
                    -Command "EXEC msdb.dbo.sp_start_job 'DatabaseBackup - USER_DATABASES - LOG'" `
                    -OnSuccessAction GoToNextStep `
                    -OnFailAction QuitWithFailure | Out-Null

New-DbaAgentJobStep -SqlInstance $Server -Job $job.name -StepName "DatabaseBackup - SYSTEM_DATABASES - LOG" -Force `
                    -Database master -StepId 2 `
                    -Subsystem "TransactSql" `
                    -Command "EXECUTE [$dbaDatabase].[dbo].[DatabaseBackup]
                                @Databases = 'SYSTEM_DATABASES',
                                @Directory = N'$defaultbackuplocation',
                                @BackupType = 'LOG',
                                @Verify = 'Y',
                                @CleanupTime = $CleanupTime,
                                @CheckSum = 'Y',
                                @LogToTable = 'Y' " `
                    -OnSuccessAction QuitWithSuccess `
                    -OnFailAction QuitWithFailure | Out-Null                 

                        
New-DbaAgentSchedule -SqlInstance $Server -Schedule $job.name -Job $job.name `
                     -FrequencyType Daily -FrequencyInterval EveryDay `
                     -FrequencySubdayType Minutes -FrequencySubDayinterval 30 `
                     -StartTime "001500" -EndTime "235959" -Force | Out-Null
#endregion

<#
    $Server | Get-DbaAgentJob | Format-Table
#>

