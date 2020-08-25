<#============================================================================
  File:     
  Summary:  MsCloudSummit 2017 - Paris
  Date:     01/2017
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
 
 
clsNew-NetFirewallRule -DisplayName "Docker sqlmaster" -Direction Inbound  -Protocol UDP -LocalPort 1433 -Action Allow -Profile Domain,Public,Private
New-NetFirewallRule -DisplayName "Docker sqlmaster SSB" -Direction Inbound  -Protocol UDP -LocalPort 47022 -Action Allow -Profile Domain,Public,Private

New-NetFirewallRule -DisplayName "Docker sqlexp01" -Direction Inbound  -Protocol UDP -LocalPort 40001 -Action Allow -Profile Domain,Public,Private
New-NetFirewallRule -DisplayName "Docker sqlexp02" -Direction Inbound  -Protocol UDP -LocalPort 40002 -Action Allow -Profile Domain,Public,Private
New-NetFirewallRule -DisplayName "Docker sqlexp03" -Direction Inbound  -Protocol UDP -LocalPort 40003 -Action Allow -Profile Domain,Public,Private
New-NetFirewallRule -DisplayName "Docker sqlexp04" -Direction Inbound  -Protocol UDP -LocalPort 40004 -Action Allow -Profile Domain,Public,Private
New-NetFirewallRule -DisplayName "Docker sqlexp05" -Direction Inbound  -Protocol UDP -LocalPort 40005 -Action Allow -Profile Domain,Public,Private

New-NetFirewallRule -DisplayName "Docker sqlexp01 SSB" -Direction Inbound  -Protocol UDP -LocalPort 47122 -Action Allow -Profile Domain,Public,Private
New-NetFirewallRule -DisplayName "Docker sqlexp02 SSB" -Direction Inbound  -Protocol UDP -LocalPort 47222 -Action Allow -Profile Domain,Public,Private
New-NetFirewallRule -DisplayName "Docker sqlexp03 SSB" -Direction Inbound  -Protocol UDP -LocalPort 47322 -Action Allow -Profile Domain,Public,Private
New-NetFirewallRule -DisplayName "Docker sqlexp04 SSB" -Direction Inbound  -Protocol UDP -LocalPort 47422 -Action Allow -Profile Domain,Public,Private
New-NetFirewallRule -DisplayName "Docker sqlexp05 SSB" -Direction Inbound  -Protocol UDP -LocalPort 47522 -Action Allow -Profile Domain,Public,Private


New-Item -ItemType Directory c:\mssql\sqlmaster -force
New-Item -ItemType Directory c:\mssql\sqlexp01 -force
New-Item -ItemType Directory c:\mssql\sqlexp02 -force
New-Item -ItemType Directory c:\mssql\sqlexp03 -force
New-Item -ItemType Directory c:\mssql\sqlexp04 -force
New-Item -ItemType Directory c:\mssql\sqlexp05 -force


docker run --name sqlmaster -d -p 1433:1433 -p 47022:7022 -v c:\mssql\sqlmaster:c:\data -e sa_password=Password1! -e ACCEPT_EULA=Y microsoft/mssql-server-windows
docker run --name sqlexp01 -d -p 40001:1433 -p 47122:7022 -v c:\mssql\sqlexp01:c:\data -e sa_password=Password1! -e ACCEPT_EULA=Y microsoft/mssql-server-windows
docker run --name sqlexp02 -d -p 40002:1433 -p 47222:7022 -v c:\mssql\sqlexp02:c:\data -e sa_password=Password1! -e ACCEPT_EULA=Y microsoft/mssql-server-windows
docker run --name sqlexp03 -d -p 40003:1433 -p 47322:7022 -v c:\mssql\sqlexp03:c:\data -e sa_password=Password1! -e ACCEPT_EULA=Y microsoft/mssql-server-windows
docker run --name sqlexp04 -d -p 40004:1433 -p 47422:7022 -v c:\mssql\sqlexp04:c:\data -e sa_password=Password1! -e ACCEPT_EULA=Y microsoft/mssql-server-windows
docker run --name sqlexp05 -d -p 40005:1433 -p 47522:7022 -v c:\mssql\sqlexp05:c:\data -e sa_password=Password1! -e ACCEPT_EULA=Y microsoft/mssql-server-windows


docker run --name sqlexp06 -d -p 40006:1433 -p 47022:7022 -v c:\mssql\sqlexp06:c:\data -e sa_password=Password1! -e ACCEPT_EULA=Y microsoft/mssql-server-windows-express
docker run --name sqlexp07 -d -p 40007:1433 -p 47022:7022 -v c:\mssql\sqlexp07:c:\data -e sa_password=Password1! -e ACCEPT_EULA=Y microsoft/mssql-server-windows-express
docker run --name sqlexp08 -d -p 40008:1433 -p 47022:7022 -v c:\mssql\sqlexp08:c:\data -e sa_password=Password1! -e ACCEPT_EULA=Y microsoft/mssql-server-windows-express
docker run --name sqlexp09 -d -p 40009:1433 -p 47022:7022 -v c:\mssql\sqlexp09:c:\data -e sa_password=Password1! -e ACCEPT_EULA=Y microsoft/mssql-server-windows-express
docker run --name sqlexp10 -d -p 40010:1433 -p 47022:7022 -v c:\mssql\sqlexp10:c:\data -e sa_password=Password1! -e ACCEPT_EULA=Y microsoft/mssql-server-windows-express

docker stop sqlmaster
docker stop sqlexp01
docker stop sqlexp02
docker stop sqlexp03
docker stop sqlexp04
docker stop sqlexp05


docker start sqlexp01
docker start sqlexp02
docker start sqlexp03
docker start sqlexp04
docker start sqlexp05




docker rm sqlmaster
docker rm sqlexp01
docker rm sqlexp02
docker rm sqlexp03
docker rm sqlexp04
docker rm sqlexp05



docker ps -a


# list of running instances
docker ps

SQLCMD.exe -S "DockerWin2016,40001" -dmaster -Usa -PPassword1!  -Q 'Select CONVERT(VARCHAR(50),SERVERPROPERTY(''MachineName'')),@@servername'
SQLCMD.exe -S "DockerWin2016,40002" -dmaster -Usa -PPassword1!  -Q 'Select CONVERT(VARCHAR(50),SERVERPROPERTY(''MachineName'')),@@servername'
SQLCMD.exe -S "DockerWin2016,40003" -dmaster -Usa -PPassword1!  -Q 'Select CONVERT(VARCHAR(50),SERVERPROPERTY(''MachineName'')),@@servername'
SQLCMD.exe -S "DockerWin2016,40004" -dmaster -Usa -PPassword1!  -Q 'Select CONVERT(VARCHAR(50),SERVERPROPERTY(''MachineName'')),@@servername'
SQLCMD.exe -S "DockerWin2016,40005" -dmaster -Usa -PPassword1!  -Q 'Select CONVERT(VARCHAR(50),SERVERPROPERTY(''MachineName'')),@@servername'




<#
    Get-NetNatStaticMapping | ? ExternalPort -eq 61431 | Remove-NetNatStaticMapping  
    Get-NetNatStaticMapping | ft
    Get-NetNatStaticMapping | Remove-NetNatStaticMapping 
    docker inspect  sqlexpress

    docker ps -a
#>

