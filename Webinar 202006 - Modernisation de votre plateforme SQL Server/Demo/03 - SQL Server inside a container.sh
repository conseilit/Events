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

# Enter SSH session
ssh Christophe@52.247.16.158

# SQL Server tag list : https://mcr.microsoft.com/v2/mssql/server/tags/list 
wget -qO- https://mcr.microsoft.com/v2/mssql/server/tags/list 

# Pull the latest version from Microsoft Repository
sudo docker pull mcr.microsoft.com/mssql/server:2019-latest


# Run (Pull+Create+Start) the container in detach mode
sudo docker run  --detach \
                 --name sqldocker \
                 --hostname sqldocker \
                 --env 'MSSQL_PID=developer' \
                 --env 'SA_PASSWORD=Password1!' \
                 --env 'ACCEPT_EULA=Y' \
                 --volume /mssql:/var/opt/mssql/data \
                 --publish 1433:1433 \
                 mcr.microsoft.com/mssql/server:2019-latest

# show SQL Server data & log files on the host
ls /mssql


# Connect to the running container
sudo docker exec -it sqldocker bash 
ls /var/opt/mssql/data

/opt/mssql-tools/bin/sqlcmd -S localhost,1433 -U SA -P 'Password1!' -Q "SELECT @@servername,@@version;"

# Exit from container
exit

# Exit from SSH
exit


# Connect to SQL server instance
Import-module dbaTools
$sqlcred = Get-Credential sa
$server = Connect-DbaInstance -SqlInstance 40.70.160.214 -SqlCredential $sqlcred
$server | Invoke-DbaQuery -query "SELECT @@servername,@@version;"


# cleanup
ssh Christophe@40.70.160.214
sudo docker stop $(sudo docker ps -a -q)
sudo docker rm $(sudo docker ps -a -q)
sudo rm -rf /mssql/
sudo docker ps -a
exit
