#==============================================================================
#
#  Summary:  Adjust SQL Agent & xEvents retention
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



Clear-Host

# connect the instance
$InstanceName = "DataFrogs"
$Server = Connect-DbaInstance -SqlInstance $InstanceName 

# increase history retention
Set-DbaErrorLogConfig -sqlinstance $Server -LogCount 99 | Out-Null

Set-DbaAgentServer -sqlinstance $Server -MaximumHistoryRows 999999 `
                                        -MaximumJobHistoryRows 999999  | Out-Null



# Change the retention settings for system_health Extended Events session
# and Stop collecting noise events
$xeSession = Get-DbaXESession -SqlInstance $Server -Session "system_health"
if ($xeSession.Status -eq "Running"){
    $xeSession | Stop-DbaXESession  | Out-Null
}
Invoke-DbaQuery -SqlInstance $Server -Database "master" -Query "
    ALTER EVENT SESSION [system_health] ON SERVER
    DROP TARGET package0.event_file;
    GO
    ALTER EVENT SESSION [system_health] ON SERVER
    ADD TARGET package0.event_file
        (SET FILENAME=N'system_health.xel',
             max_file_size=(100),
             max_rollover_files=(10)
        );
    GO
    ALTER EVENT SESSION [system_health] ON SERVER
    DROP EVENT sqlserver.security_error_ring_buffer_recorded;
"
if ($xeSession.Status -eq "Running"){
    $xeSession | Start-DbaXESession  | Out-Null
}



# Change the retention settings for AlwaysOn_health Extended Events session
$xeSession = Get-DbaXESession -SqlInstance $Server -Session "AlwaysOn_health"
if ($xeSession.Status -eq "Running"){
    $xeSession | Stop-DbaXESession  | Out-Null
}
Invoke-DbaQuery -SqlInstance $Server -Database "master" -Query "
    ALTER EVENT SESSION [AlwaysOn_health] ON SERVER
    DROP TARGET package0.event_file;
    GO
    ALTER EVENT SESSION [AlwaysOn_health] ON SERVER
    ADD TARGET package0.event_file
        (SET FILENAME=N'AlwaysOn_health.xel',
            max_file_size=(100),
            max_rollover_files=(10)
        )

"
if ($xeSession.Status -eq "Running"){
    $xeSession | Start-DbaXESession  | Out-Null
}
