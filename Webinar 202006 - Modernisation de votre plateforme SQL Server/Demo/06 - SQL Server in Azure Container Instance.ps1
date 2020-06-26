#==============================================================================
#
#  Summary:  Webinar SQL Server
#  Date:     06/2020
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


$ResourceGroupName = "webinar-sqlserver-rg"
$Location = "EastUS2"
$virtualnetworkName = "webinar-sqlserver-vnet"
$VnetDefaultName = "default"
$containerName = "eus-sql2019-aci"
$dnsName = "eus-webinar-sqlserver-sql2019-aci"

New-AzContainerGroup -ResourceGroupName $ResourceGroupName  `
                     -Location $Location `
                     -Name $containerName `
                     -Image mcr.microsoft.com/mssql/server:2019-latest `
                     -OsType Linux -Cpu 4 -MemoryInGB 16 `
                     -IpAddressType Public -Port @(1433) `
                     -EnvironmentVariable @{"ACCEPT_EULA"="Y";"MSSQL_SA_PASSWORD"="Password1!"} `
                     -DnsNameLabel $dnsName

                     
# Test SQL Server connectivity
Import-module dbaTools
$sqlcred = Get-Credential sa
$sqlinstance = $dnsName + ".eastus2.azurecontainer.io"
$server = Connect-DbaInstance -SqlInstance $sqlinstance  -SqlCredential $sqlcred
$server | Invoke-DbaQuery -query "SELECT @@servername,@@version;"
$server | New-DbaDatabase -Name "SQLServerACIWebinar"
$server | get-dbadatabase | Select-object ComputerName,SQLInstance,Name | Format-Table

# https://docs.microsoft.com/en-us/powershell/module/az.containerinstance/new-azcontainergroup?view=azps-3.8.0

