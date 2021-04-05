#==============================================================================
#
#  Summary:  SQL Server mainenance plan
#            using Ola hallengren maintenance solution
#            installed with dbaTools
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

$instance = "DataFrogs"

$Server = Connect-DbaInstance -SqlInstance $instance
$Server | Select-Object DomainInstanceName,VersionMajor,DatabaseEngineEdition



$Name = "The DBA Team"  
$EmailDomain = "contoso.com"
$smtpServer = "smtp.$EmailDomain"
$AccountEmailAddress = "DBATeam@$EmailDomain"
$DelayBetweenResponses = 300 # seconds
$OperatorName = "DBATeam"
$OperatorEmailAddress = "$OperatorName@$EmailDomain" 


# enable database mail feature
$Server.Configuration.DatabaseMailEnabled.ConfigValue = 1 
$Server.Configuration.Alter() 


# create account and profile
if ((get-DbaDbMailAccount -SqlInstance $Server -Account $Name).count -eq 0) {
    $account = New-DbaDbMailAccount -SqlInstance $Server -Name $Name -EmailAddress $AccountEmailAddress -MailServer $smtpServer -Force
}
if ((get-DbaDbMailProfile -SqlInstance $Server -Profile $Name).count -eq 0) {
    $Profile = New-DbaDbMailProfile -SqlInstance $Server -Name $Name -MailAccountName $account.Name
}



# enable Database mail
$server.JobServer.AgentMailType = [Microsoft.SqlServer.Management.Smo.Agent.AgentMailType]::DatabaseMail
$server.JobServer.DatabaseMailProfile = $Profile.Name
$server.JobServer.Properties['SaveInSentFolder'].Value = $true
$server.JobServer.Alter()

# create an operator
$operator = New-Object ('Microsoft.SqlServer.Management.Smo.Agent.Operator') ($server.JobServer,$OperatorName)
$operator.EmailAddress = $OperatorEmailAddress
$operator.Create()



# create most important alerts
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

$ErrorMessageList = 823,824,825,829,832,855,856
foreach ($item in $ErrorMessageList) {
    $alert = New-Object ('Microsoft.SqlServer.Management.Smo.Agent.Alert') ($server.JobServer, "Alert on Error Number $item ")
    $alert.MessageID = $item
    $alert.IncludeEventDescription = 'NotifyEmail'
    $alert.DelayBetweenResponses = $DelayBetweenResponses
    $alert.Create()
    $alert.AddNotification($operator.Name, [Microsoft.SqlServer.Management.Smo.Agent.NotifyMethods]::NotifyEmail)
    $alert.Alter()
}

# adding email notification on job failure
$jobs = $Server  | Get-DbaAgentJob | Where-Object {$_.Category -match "Database Maintenance" } 
$jobs | Select-Object Name,EmailLevel,OperatorToEmail | format-table -autosize

$jobs | Set-DbaAgentJob -EmailLevel OnFailure -EmailOperator DBATeam | Out-Null

$jobs | Select-Object Name,EmailLevel,OperatorToEmail | format-table -autosize