#==============================================================================
#
#  Summary:  SQLSaturday Helsinki #735 - 2018
#  Date:     05/2018
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


# Create a container with SQL Server 2016 SP1 Express
# using port and volume redirection 
mkdir c:\mssql\sqldocker -Force

# Creates a container with SQL Server 2017 Windows
# using port and volume redirection 
docker run --detach `
           --name sqldocker `
           --hostname sqldocker `
           --publish 1433:1433 `
           --volume c:\mssql\sqldocker:c:\mssql `
           --env sa_password=Password1! `
           --env ACCEPT_EULA=Y `
           microsoft/mssql-server-windows-express

docker ps

# see container output
docker logs sqldocker


# no files yet
Get-ChildItem -Recurse  c:\mssql\sqldocker


# connect to SQL Server inside the container

# host : find the IP on the "private" network
docker network ls
docker network inspect  nat

# host : exactly the same information inspecting the container
$ContainerID = (docker ps | Select-Object -index 1).Substring(0,12)
docker inspect $ContainerID


# The PowerShell command to install the SQL Server module is: 
Install-module -Name SqlServer -Scope CurrentUser


# connect with nat IP address
$ipaddr = docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $ContainerID
write-host "IP address :" $ipaddr
Invoke-Sqlcmd -ServerInstance "$ipaddr,1433" -Username sa -Password Password1! -Query "select name from sys.databases"

# connect with Host IP address
$ipaddr = (Get-NetIPAddress | ? AddressFamily -eq "IPv4" | ? InterfaceAlias -eq "Ethernet 2").IPAddress
write-host "IP address :" $ipaddr
Invoke-Sqlcmd -ServerInstance "$ipaddr,1433" -Username sa -Password Password1! -Query "select name from sys.databases"

# connect with public IP of the VM
$ipaddr = "52.166.49.18"
write-host "IP address :" $ipaddr
Invoke-Sqlcmd -ServerInstance "$ipaddr,1433" -Username sa -Password Password1! -Query "select name from sys.databases"


# Show mssql folder in container
docker exec -it sqldocker powershell.exe


# connect with SSMS
# Might need to add a firewall rule to connect the container 
New-NetFirewallRule -DisplayName "SQL Server sqldocker 1433" -Direction Inbound  -Protocol TCP -LocalPort 1433 -Action Allow

# -v persists the data on the host
$tSQL = "
    CREATE DATABASE [DemoDB]
     ON  PRIMARY 
         ( NAME = N'DemoDB',     FILENAME = N'C:\mssql\DemoDB.mdf'  )
     LOG ON 
         ( NAME = N'DemoDB_log', FILENAME = N'c:\mssql\DemoDB_log.ldf' )
    GO
"
Invoke-Sqlcmd -ServerInstance "$ipaddr,1433" -Username sa -Password Password1! -Query $tSQL


# files are visible inside the container
Get-ChildItem c:\mssql

# files should be on the host
Get-ChildItem c:\mssql\sqldocker

# by default a container is stateless
# no data persisted afeter a docker "rm command"
# using -v allows to persis data
