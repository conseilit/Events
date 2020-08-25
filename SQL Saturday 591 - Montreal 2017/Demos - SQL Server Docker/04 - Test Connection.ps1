<#============================================================================
  File:     
  Summary:  sqlsATURDAY 591 - Montreal 2017
  Date:     03/2017
  SQL Server Versions: 
------------------------------------------------------------------------------
  Written by Christophe LAPORTE, SQL Server MVP / MCM
	Blog    : http://conseilit.wordpress.com
	Twitter : @ConseilIT
  
  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you give due credit.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================#>

# Container on Ubuntu Public Cloud

[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
$Server = New-Object -TypeName  Microsoft.SQLServer.Management.Smo.Server("158.69.74.60,40001")
$Server.ConnectionContext.LoginSecure=$false
$server.ConnectionContext.Login="sa"
$server.ConnectionContext.Password="Password1!"

$Server| select ComputerNamePhysicalNetBIOS,ServiceName,VersionString,EngineEdition,ProductLevel,DefaultFile,DefaultLog,Processors,PhysicalMemory

$Server.Databases | select name


$db = New-Object Microsoft.SqlServer.Management.Smo.Database($Server, "SQLSaturdayMontreal")
$db.Create()
Write-Host $db.CreateDate
$Server.Databases | select name




# Container on Windows Public Cloud

# On VM :
New-NetFirewallRule -DisplayName "SQL Server sqldocker01 40001" -Direction Inbound  -Protocol TCP -LocalPort 40001 -Action Allow

# On AWS console
# Add Rule on security group
# Retrive public IP



[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
$Server = New-Object -TypeName  Microsoft.SQLServer.Management.Smo.Server("34.252.67.81,40001")
$Server.ConnectionContext.LoginSecure=$false
$server.ConnectionContext.Login="sa"
$server.ConnectionContext.Password="Password1!"

$Server| select ComputerNamePhysicalNetBIOS,ServiceName,VersionString,EngineEdition,ProductLevel,DefaultFile,DefaultLog,Processors,PhysicalMemory

$Server.Databases | select name


$db = New-Object Microsoft.SqlServer.Management.Smo.Database($Server, "SQLSaturdayMontreal")
$db.Create()
Write-Host $db.CreateDate
$Server.Databases | select name



#TSQL
:CONNECT tcp:137.74.26.146,40001 -Usa -PPassword1!
select @@servername,@@version
GO

:CONNECT tcp:137.74.26.146,40001 -Usa -PPassword1!
CREATE DATABASE SQLSaturdayMontreal
GO

# Start-VM -Name Docker
# Get-VM -Name Docker | Select -ExpandProperty NetworkAdapters | Select VMName, IPAddresses, Status

:CONNECT tcp:xx,40001 -Usa -PPassword1!
select @@servername,@@version
GO


:CONNECT tcp:xx,40001 -Usa -PPassword1!
CREATE DATABASE SQLSaturdayMontreal
GO

