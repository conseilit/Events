#==============================================================================
#
#  Event   : SQL Saturday #1012 - Montreal 2020
#  Session : From Docker to Big Data Clusters - a new era for SQL Server
#  Date    : 11/2020
#
#  ----------------------------------------------------------------------------
#  Written by : Christophe LAPORTE, SQL Server MVP / MCM
#  Blog       : http://conseilit.wordpress.com
#  Email      : conseilit@outlook.com
#  Twitter    : @ConseilIT
#  
#  You may alter this code for your own *non-commercial* purposes. You may
#  republish altered code as long as you give due credit.
#  
#  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
#  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
#  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
#  PARTICULAR PURPOSE.
#==============================================================================

# Connect to the Ubuntu VM
ssh chris@192.168.1.140

#region  install Docker
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update
    apt-cache policy docker-ce
    sudo apt-get install -y docker-ce

    echo manual | sudo tee /etc/init/docker.override
    sudo systemctl enable docker

    sudo docker ps -a
    sudo docker images

    sudo docker pull mcr.microsoft.com/mssql/server:2019-latest

    sudo mkdir /mssql
    sudo chmod 777 /mssql
    ls /mssql
#endregion 

# SQL Server tag list : https://mcr.microsoft.com/v2/mssql/server/tags/list 
wget -qO- https://mcr.microsoft.com/v2/mssql/server/tags/list 

# Pull the latest version from Microsoft Repository
sudo docker pull mcr.microsoft.com/mssql/server:2019-latest

# Pull specific versions
sudo docker pull mcr.microsoft.com/mssql/server:2019-CU6-ubuntu-18.04
sudo docker pull mcr.microsoft.com/mssql/server:2019-CU8-ubuntu-18.04

# List all pulled images
sudo docker images

# Run (Pull+Create+Start) the container in detach mode
sudo docker run  --detach \
            --name sqldocker \
            --hostname sqldocker \
            --env 'MSSQL_PID=developer' \
            --env 'SA_PASSWORD=Password1!' \
            --env 'ACCEPT_EULA=Y' \
            --volume /mssql:/var/opt/mssql/data \
            --publish 1433:1433 \
            mcr.microsoft.com/mssql/server:2019-CU6-ubuntu-18.04


# grab some information about the container
sudo docker logs sqldocker

# Connect to SQL server instance from the host
/opt/mssql-tools/bin/sqlcmd -S localhost,1433 -U SA -P 'Password1!' -Q "SELECT @@servername,@@version;"
/opt/mssql-tools/bin/sqlcmd -S localhost,1433 -U SA -P 'Password1!' -Q "SELECT name from sys.databases;"


# Open a session onto the running container
sudo docker exec -it sqldocker bash 

# Run some T-SQL commands
/opt/mssql-tools/bin/sqlcmd -S localhost,1433 -U SA -P 'Password1!' -Q "CREATE DATABASE [SQLServerDBinsideDocker];"
/opt/mssql-tools/bin/sqlcmd -S localhost,1433 -U SA -P 'Password1!' -Q "SELECT name from sys.databases;"

# show SQL Server data & log files inside the container
ls /var/opt/mssql/data -l


# Exit from container
exit


# stop and remove the container
sudo docker stop sqldocker
sudo docker rm sqldocker
sudo docker ps -a

# SQL Server data & log files are stored on the host
ls /mssql -l

# recreate the container using a newer image !
sudo docker run  --detach \
            --name sqldocker \
            --hostname sqldocker \
            --env 'MSSQL_PID=developer' \
            --env 'SA_PASSWORD=Password1!' \
            --env 'ACCEPT_EULA=Y' \
            --volume /mssql:/var/opt/mssql/data \
            --publish 1433:1433 \
            mcr.microsoft.com/mssql/server:2019-CU8-ubuntu-18.04


sudo docker logs sqldocker

# Version has changed
/opt/mssql-tools/bin/sqlcmd -S localhost,1433 -U SA -P 'Password1!' -Q "SELECT @@servername,@@version;"

# Database is still there, without volume redirection, user databases will be lost
/opt/mssql-tools/bin/sqlcmd -S localhost,1433 -U SA -P 'Password1!' -Q "SELECT name from sys.databases;"

# CU downgrade is also possible !
sudo docker stop sqldocker
sudo docker rm sqldocker

sudo docker run  --detach \
            --name sqldocker \
            --hostname sqldocker \
            --env 'MSSQL_PID=developer' \
            --env 'SA_PASSWORD=Password1!' \
            --env 'ACCEPT_EULA=Y' \
            --volume /mssql:/var/opt/mssql/data \
            --publish 1433:1433 \
            mcr.microsoft.com/mssql/server:2019-CU6-ubuntu-18.04

sudo docker logs sqldocker
/opt/mssql-tools/bin/sqlcmd -S localhost,1433 -U SA -P 'Password1!' -Q "SELECT @@servername,@@version;"

# spin up multiple containers
sudo docker run  --detach --name sqldocker1 --hostname sqldocker1 --publish 14331:1433 --env 'MSSQL_PID=developer' --env 'SA_PASSWORD=Password1!' --env 'ACCEPT_EULA=Y' mcr.microsoft.com/mssql/server:2019-latest
sudo docker run  --detach --name sqldocker2 --hostname sqldocker2 --publish 14332:1433 --env 'MSSQL_PID=developer' --env 'SA_PASSWORD=Password1!' --env 'ACCEPT_EULA=Y' mcr.microsoft.com/mssql/server:2019-latest
sudo docker run  --detach --name sqldocker3 --hostname sqldocker3 --publish 14333:1433 --env 'MSSQL_PID=developer' --env 'SA_PASSWORD=Password1!' --env 'ACCEPT_EULA=Y' mcr.microsoft.com/mssql/server:2019-latest
sudo docker run  --detach --name sqldocker4 --hostname sqldocker4 --publish 14334:1433 --env 'MSSQL_PID=developer' --env 'SA_PASSWORD=Password1!' --env 'ACCEPT_EULA=Y' mcr.microsoft.com/mssql/server:2019-latest
sudo docker run  --detach --name sqldocker5 --hostname sqldocker5 --publish 14335:1433 --env 'MSSQL_PID=developer' --env 'SA_PASSWORD=Password1!' --env 'ACCEPT_EULA=Y' mcr.microsoft.com/mssql/server:2019-latest

# list all running containers
sudo docker ps



# Exit from the Docker host
exit

# connect from my computer
/opt/mssql-tools/bin/sqlcmd -S 192.168.1.140,1433 -U SA -P 'Password1!' -Q "SELECT @@servername,name from sys.databases;"
/opt/mssql-tools/bin/sqlcmd -S 192.168.1.140,14331 -U SA -P 'Password1!' -Q "SELECT @@servername,name from sys.databases;"
/opt/mssql-tools/bin/sqlcmd -S 192.168.1.140,14332 -U SA -P 'Password1!' -Q "SELECT @@servername,name from sys.databases;"






# Cleanup - Remove MSSQL Folder on LXDocker
ssh chris@192.168.1.140
sudo docker stop $(sudo docker ps -a -q)
sudo docker rm $(sudo docker ps -a -q)
sudo docker ps -a

sudo rm -rf /mssql/
sudo mkdir /mssql 
sudo chmod +777 /mssql # because of non-root containers in SQL 2019
ls /mssql

