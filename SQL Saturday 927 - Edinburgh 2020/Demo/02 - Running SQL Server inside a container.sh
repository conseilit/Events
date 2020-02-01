#==============================================================================
#
#  Summary:  SQLSaturday Edinburgh #927 - 2020
#  Date:     01/2020
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

# SQL Server tag list : https://mcr.microsoft.com/v2/mssql/server/tags/list 
wget -qO- https://mcr.microsoft.com/v2/mssql/server/tags/list 

# Pull the latest version from Microsoft Repository
sudo docker pull mcr.microsoft.com/mssql/server:2019-latest


# Run (Pull+Create+Start) the container in detach mode
# /!\ SQL Server 2019 containers automatically start up as non-root
docker run  --detach \
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
docker exec -it sqldocker bash 
ls /var/opt/mssql/data

/opt/mssql-tools/bin/sqlcmd -S localhost,1433 -U SA -P 'Password1!' -Q "SELECT @@servername,@@version;"

# Exit from container
exit

# Connect to SQL server instance
/opt/mssql-tools/bin/sqlcmd -S localhost,1433 -U SA -P 'Password1!' -Q "SELECT @@servername,@@version;"
/opt/mssql-tools/bin/sqlcmd -S localhost,1433 -U SA -P 'Password1!' -Q "SELECT name from sys.databases;"

/opt/mssql-tools/bin/sqlcmd -S localhost,1433 -U SA -P 'Password1!' -Q "CREATE DATABASE SQLSatLisbon;"


# cleanup
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)

# Remove MSSQL Folder on LXDocker
rm -rf /mssql/
mkdir /mssql 
chmod +777 /mssql # because of non-root containers in SQL 2019
ls /mssql