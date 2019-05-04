#==============================================================================
#
#  Summary:  Using DBAtools commands to configure SQL Server
#            Awesome job from Chrissy (@cl), Rob (@sqldbawithbeard)
#            and all contributors. Thank you. 
#            https://dbatools.io/ 
#  Date:     SQLSaturday Stockholm #851 - 05/2019
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

<#
    # If Powershell v4.0 (Windows 2012)
    Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?linkid=839516" -OutFile c:\temp\Win8.1AndW2K12R2-KB3191564-x64.msu 
    $PSVersionTable.PSVersion
#>


Install-Module -Name dbatools  # https://dbatools.io/
#Install-module -Name SqlServer

<#
    # or 
    # Invoke-Expression (Invoke-WebRequest -UseBasicParsing https://dbatools.io/in) 
#>


Get-DbaService -Type Agent | Where-Object {$_.State -eq "Stopped"} | Start-DbaService


[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.Management.XEvent') | out-null



$instance = Hostname
$dbaDatabase = "_DBA"

$ProfileName = "Profile_$instance"  
$AccountName = "Account_$instance" 
$smtpServer = "127.0.0.1"
$EmailDomain = "contoso.com"
$AccountEmailAddress = "$instance@$EmailDomain" 
$DelayBetweenResponses = 300 # seconds
$OperatorName = "DBAs"
$OperatorEmailAddress = "$OperatorName@$EmailDomain" 

$EnableStartupTraceFlag = $true


function Enable-DbaStartupTraceFlag([string]$InstanceNameParameter,[string]$StartupParameter) 
{ 
    <#

    .SYNOPSIS

    Adds an entry to the startup parameters list for a given instance

    .EXAMPLE

    AddTraceFlag -StartupParameter '-T3226' -InstanceNameParameter 'SQL2016'

    #>

    $hklmRootNode = "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server"

    $InstanceList = (get-itemproperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server').InstalledInstances 
    foreach ($CurrentInstance in $InstanceList) 
    {
        if($CurrentInstance -eq $InstanceNameParameter) 
        {
            $InstanceRegPath =  (get-itemproperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL').$InstanceNameParameter
            Write-host "Instance $InstanceNameParameter found"
            break;
        }
    }

    $regKey = "$hklmRootNode\$InstanceRegPath\MSSQLServer\Parameters"


    Write-host "Reading instance parameters from " $regKey

    # Read the registry to get all startup parameters
    $RegkeyValue = Get-ItemProperty $regKey
    $StartupParameterList = $RegkeyValue.psobject.properties | ?{$_.Name -like 'SQLArg*'} | select Name, Value



    $StartupParameterAlreadySet = $false

    # check if Trace Flag already set
    foreach ($param in $StartupParameterList) 
    {
        if($param.Value -eq $StartupParameter) 
        {
            $StartupParameterAlreadySet = $true
            break;
        }
    }

    # add the startup parameter if not present
    if (-not $StartupParameterAlreadySet) 
    {
        Write-host  "Adding $StartupParameter"
        $newRegProp = "SQLArg"+($StartupParameterList.Count)
        Set-ItemProperty -Path $regKey -Name $newRegProp -Value $StartupParameter
    } 
    else 
    {
        Write-host  "$StartupParameter already set"
    }
}


if ((Test-DbaPowerPlan -ComputerName $instance).ActivePowerPlan -eq (Test-DbaPowerPlan -ComputerName $instance).RecommendedPowerPlan) {
    write-host "ActivePowerPlan correct"
}
else {
    Set-DbaPowerPlan -ComputerName $ComputerName -PowerPlan 'High Performance'
}


#$Server = New-Object -TypeName  Microsoft.SQLServer.Management.Smo.Server($instance)
$Server = Connect-DbaInstance -SqlInstance $instance

$TempDBLogPath = split-path (Get-DbaDBFile -SqlInstance $instance -Database TempDB | Where-Object {$_.ID -eq 2}).PhysicalName -Parent
$TempDBDataPath = split-path (Get-DbaDBFile -SqlInstance $instance -Database TempDB | Where-Object {$_.ID -eq 1}).PhysicalName -Parent

$TempDBDataFileSizeMB = 1024 
$TempDBDataFileCount = $(Get-DbaInstanceProperty -SqlInstance $instance  -InstanceProperty  Processors).value
Set-DbaTempDbConfig -SqlServer $instance -DataPath $TempDBDataPath -LogPath $TempDBLogPath -DataFileSize $TempDBDataFileSizeMB -DataFileCount $TempDBDataFileCount -LogFileSize 1024 -LogFileGrowth 256



Set-DbaErrorLogConfig -SqlInstance $instance -LogCount 99
Set-DbaSpConfigure -SqlServer $instance -name ShowAdvancedOptions -Value 1
Set-DbaSpConfigure -SqlServer $instance -name RemoteDacConnectionsEnabled -value 1 
Set-DbaSpConfigure -SqlServer $instance -name OptimizeAdhocWorkloads -value 1 
Set-DbaSpConfigure -SqlServer $instance -name CostThresholdForParallelism -value 25 
Set-DbaSpConfigure -SqlServer $instance -name DefaultBackupCompression -value 1 
Set-DbaSpConfigure -SqlServer $instance -name ContainmentEnabl -value 1 

Set-DbaMaxMemory -SqlInstance $instance 

# Get-DbaSpConfigure -SqlServer $instance | out-gridview

Stop-DbaXESession -SqlInstance $instance -Session "system_health"

Invoke-DbaQuery -SqlInstance $instance -Database "Master" -Query "
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


Start-DbaXESession -SqlInstance $instance -Session "system_health"


if (!($(Get-DbaInstanceProperty -SqlInstance $instance -InstanceProperty  Edition).value -Match "Express")){
    Set-DbaAgentServer -SqlInstance $instance -MaximumHistoryRows 999999 -MaximumJobHistoryRows 999999 
}


# Create DBA database if needed
if (!(Get-DbaDatabase -SqlInstance $instance -Database $dbaDatabase )){
    New-DbaDatabase -SqlInstance $instance -Name $dbaDatabase
}
else {
    Write-Host "[$dbaDatabase] database already exists"
}


Install-DbaWhoIsActive -SqlServer $instance -Database $dbaDatabase 

#region Trace Flags

# remove successful backup message
If ($EnableStartupTraceFlag) {
    Enable-DbaStartupTraceFlag -InstanceNameParameter $server.DbaInstanceName -StartupParameter "-T3226" 
}
else {
    Enable-DbaTraceFlag -SqlInstance $instance -TraceFlag 3226 
}
 

# 1117 auto growth all files simultaneously
# 1118 remove single page allocations
# 2371 lower statistics update threshold
if ( (Get-DbaInstanceProperty -SqlInstance $instance  -InstanceProperty  VersionMajor).value -lt 13) {
    If ($EnableStartupTraceFlag) {
        Enable-DbaStartupTraceFlag -InstanceNameParameter $server.DbaInstanceName -StartupParameter "-T1117"
        Enable-DbaStartupTraceFlag -InstanceNameParameter $server.DbaInstanceName -StartupParameter "-T1118"
        Enable-DbaStartupTraceFlag -InstanceNameParameter $server.DbaInstanceName -StartupParameter "-T2371"
    }
    else {
        Enable-DbaTraceFlag -SqlInstance $instance -TraceFlag 1117 
        Enable-DbaTraceFlag -SqlInstance $instance -TraceFlag 1118 
        Enable-DbaTraceFlag -SqlInstance $instance -TraceFlag 2371 
    }
}

# backup checksum default
if ( (Get-DbaInstanceProperty -SqlInstance $instance  -InstanceProperty  VersionMajor).value -ge 12) {
    Set-DbaSpConfigure -SqlServer $instance -name BackupChecksumFefault -value 1 
}
else {
    If ($EnableStartupTraceFlag) {
        Enable-DbaStartupTraceFlag -InstanceNameParameter $server.DbaInstanceName -StartupParameter "-T3023"
    }
    else {
        Enable-DbaTraceFlag -SqlInstance $instance -TraceFlag 3023 
    }
}

# enable DAC for SQL Server Express
if ($(Get-DbaInstanceProperty -SqlInstance $instance -InstanceProperty  Edition).value -Match "Express"){
    If ($EnableStartupTraceFlag) {
        Enable-DbaStartupTraceFlag -InstanceNameParameter $server.DbaInstanceName -StartupParameter "-T7806"
    }
    else {
        Enable-DbaTraceFlag -SqlInstance $instance -TraceFlag 7806 
    }
}


# enable lightweight profiling SQL2017
if ((Get-DbaInstanceProperty -SqlInstance $instance  -InstanceProperty  VersionMajor).value -eq 14){
    If ($EnableStartupTraceFlag) {
        Enable-DbaStartupTraceFlag -InstanceNameParameter $server.DbaInstanceName -StartupParameter "-T7412"
    }
    else {
        Enable-DbaTraceFlag -SqlInstance $instance -TraceFlag 7412 
    }
}

# enable lightweight profiling SQL2016SP1+
if (((Get-DbaInstanceProperty -SqlInstance $instance  -InstanceProperty  VersionMajor).value -eq 13) -and `
   ((Get-DbaInstanceProperty -SqlInstance $instance  -InstanceProperty  ProductLevel).value -ne "RTM")){
    If ($EnableStartupTraceFlag) {
        Enable-DbaStartupTraceFlag -InstanceNameParameter $server.DbaInstanceName -StartupParameter "-T7412"
    }
    else {
        Enable-DbaTraceFlag -SqlInstance $instance -TraceFlag 7412 
    }
}
#endregion


#region configuration model
Invoke-DbaQuery -SqlInstance $instance -Database "Master" -Query "Alter database model modify file (name=modeldev, size=512MB, filegrowth=64MB);"
Invoke-DbaQuery -SqlInstance $instance -Database "Master" -Query "Alter database model modify file (name=modellog, size=64MB, filegrowth=64MB);"
Invoke-DbaQuery -SqlInstance $instance -Database "Master" -Query "Alter database model SET RECOVERY FULL;"
#endregion

#region configuration MSDB
Invoke-DbaQuery -SqlInstance $instance -Database "Master" -Query "Alter database msdb modify file (name=MSDBData, size=512MB, filegrowth=64MB);"
Invoke-DbaQuery -SqlInstance $instance -Database "Master" -Query "Alter database msdb modify file (name=MSDBLog, size=64MB,	 filegrowth=64MB);"
#endregion

#region DatabaseMail & Operators & Alerts
$Server.Configuration.DatabaseMailEnabled.ConfigValue = 1 
$Server.Configuration.Alter() 

#Create Mail Account 
$DBAccount = New-Object -TypeName Microsoft.SqlServer.Management.SMO.Mail.MailAccount -argumentlist $Server.Mail,$AccountName -ErrorAction Stop 
$DBAccount.Description = "SQL Server Email Account" 
$DBAccount.DisplayName = $AccountName 
$DBAccount.EmailAddress = $AccountEmailAddress 
$DBAccount.Create() 
$mailServer = $DBAccount.MailServers.Item(0)
$mailServer.Rename($smtpServer)
$mailServer.Alter()



#Create Mail Profile 
$DBProfile = New-Object -TypeName Microsoft.SqlServer.Management.SMO.Mail.MailProfile -argumentlist $Server.Mail,$ProfileName -ErrorAction Stop 
$DBProfile.Description = "SQL Server Email Profile" 
$DBProfile.Create() 
$DBProfile.AddAccount($AccountName,0) 
$DBProfile.AddPrincipal("Public",$true) 
$DBProfile.Alter() 

$server.JobServer.DatabaseMailProfile = $ProfileName
$server.JobServer.Properties['SaveInSentFolder'].Value = $true
$server.JobServer.Alter()

$operator = New-Object ('Microsoft.SqlServer.Management.Smo.Agent.Operator') ($server.JobServer,$OperatorName)
$operator.EmailAddress = $OperatorEmailAddress
$operator.Create()

$AlertSeverityList = 19..25
foreach ($item in $AlertSeverityList) {
    $alert = New-Object ('Microsoft.SqlServer.Management.Smo.Agent.Alert') ($server.JobServer, "Alert on Error Gravity $item ")
    $alert.Severity = $item
    $alert.IncludeEventDescription = 'NotifyEmail'
    $alert.DelayBetweenResponses = $DelayBetweenResponses
    $alert.Create()
    $alert.AddNotification($operator.Name, [Microsoft.SqlServer.Management.Smo.Agent.NotifyMethods]::NotifyEmail)
    $alert.Alter()
}

$ErrorMessageList = 823,824,825,829
foreach ($item in $ErrorMessageList) {
    $alert = New-Object ('Microsoft.SqlServer.Management.Smo.Agent.Alert') ($server.JobServer, "Alert on Error Number $item ")
    $alert.MessageID = $item
    $alert.IncludeEventDescription = 'NotifyEmail'
    $alert.DelayBetweenResponses = $DelayBetweenResponses
    $alert.Create()
    $alert.AddNotification($operator.Name, [Microsoft.SqlServer.Management.Smo.Agent.NotifyMethods]::NotifyEmail)
    $alert.Alter()
}
#endregion


#region display configuration
Get-DbaSpConfigure -SqlServer $instance | Select-Object DisplayName,ConfiguredValue | Sort-Object -property Displayname | Format-Table -AutoSize

Get-DbaXESession -SqlInstance  $instance | Select-Object Name,Status,AutoStart,Targets | Sort-Object -property Name | Format-Table -AutoSize

Get-DbaTraceFlag -SqlInstance $instance | Select-Object TraceFlag | Format-Table -AutoSize
Get-DbaDbMailConfig -SqlInstance $instance | Select-Object Name,Value,Description | Format-Table -AutoSize
Get-DbaDbMailServer -SqlInstance $instance | Select-Object Account,Name,Port,ServerType,EnableSsl,UserName | Format-Table -AutoSize
Get-DbaDbMailProfile -SqlInstance $instance | Select-Object Name,Description | Format-Table -AutoSize
Get-DbaDbMailAccount -SqlInstance $instance | Select-Object Name,Description,EmailAddress | Format-Table -AutoSize

Get-DbaAgentAlert -SqlInstance $instance | Select-Object Name,AlertType,IsEnabled,DelayBetweenResponses,OccurrenceCount,LastRaised | Format-Table -AutoSize
#endregion