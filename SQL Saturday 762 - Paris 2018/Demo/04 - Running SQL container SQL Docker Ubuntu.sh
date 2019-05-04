#==============================================================================
#
#  Summary:  SQLSaturday Paris #762 - 2018
#  Date:     07/2018
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



# Product ID of the version of SQL server you're installing
# Must be evaluation, developer, express, web, standard, enterprise, or your 25 digit product key
# Defaults is developer

sudo su 

# Creates a container with SQL Server 2017 Linux
docker run  --detach \
            --name sqldocker \
            --hostname sqldocker \
            --env 'MSSQL_PID=developer' \
            --env 'SA_PASSWORD=Password1!' \
            --env 'ACCEPT_EULA=Y' \
            --publish 1433:1433 \
            microsoft/mssql-server-linux

# see container output
docker logs sqldocker

# check resource limits on host
docker container stats sqldocker

# check resource limits inside the container (no restrictions)
docker exec -it sqldocker bash
nproc

# stop teh container and restart with some limitations
docker container update sqldocker \
                        --cpuset-cpus="0,1" \
                        --memory="2GB" \
                        --memory-swap="2GB"

# check resource limits on host (2GB RAM)
docker container stats sqldocker                        

# check resource limits inside the container (2 cores)
docker exec -it sqldocker bash
nproc



# install tools and connect on host
curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
add-apt-repository "$(curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list)"

apt-get update
apt-get install -y mssql-tools unixodbc-dev


/opt/mssql-tools/bin/sqlcmd -S localhost,1433 -U SA -P 'Password1!' 

/opt/mssql-tools/bin/sqlcmd -S localhost,1433 -U SA -P 'Password1!' -Q "CREATE DATABASE [DemoDB]
     ON  PRIMARY 
         ( NAME = N'DemoDB',     FILENAME = N'/var/opt/mssql/data/DemoDB.mdf'  )
     LOG ON 
         ( NAME = N'DemoDB_log', FILENAME = N'/var/opt/mssql/data/DemoDB_log.ldf' )
    GO"

/opt/mssql-tools/bin/sqlcmd -S localhost,1433 -U SA -P 'Password1!' \
 -Q "CREATE TABLE [DemoDB].[dbo].[Users] (
        UserID    INT PRIMARY KEY,
        FirstName VARCHAR (50),
        LastName  VARCHAR (50)
     );
     GO
     INSERT INTO [DemoDB].[dbo].[Users]
     VALUES
        (1,'Gustavo','Achong'),
        (2,'Catherine','Abel'),
        (3,'Kim','Abercrombie'),
        (4,'Humberto','Acevedo'),
        (5,'Pilar','Ackerman'),
        (6,'Frances','Adams'),
        (7,'Margaret','Smith'),
        (8,'Carla','Adams'),
        (9,'Jay','Adams'),
        (10,'Ronald','Adina'),
        (11,'Samuel','Agcaoili'),
        (12,'James','Aguilar'),
        (13,'Robert','Ahlering'),
        (14,'François','Ferrier'),
        (15,'Kim','Akers'),
        (16,'Lili','Alameda'),
        (17,'Amy','Alberts'),
        (18,'Anna','Albright'),
        (19,'Milton','Albury'),
        (20,'Paul','Alcorn')
    GO"


/opt/mssql-tools/bin/sqlcmd -S localhost,1433 -U SA -P 'Password1!' -q "SELECT * FROM [DemoDB].[dbo].[Users];"


# ouch : this GUI looks like ... Oracle ! (kidding)

# Import the public repository GPG keys
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | apt-key add -

# Register the Microsoft Ubuntu repository
curl -o /etc/apt/sources.list.d/microsoft.list https://packages.microsoft.com/config/ubuntu/16.04/prod.list

# Update the list of products
apt-get update

# Install mssql-cli
apt-get install mssql-cli

clear 

mssql-cli -S localhost,1433 -U sa -d master
SELECT * FROM [DemoDB].[dbo].[Users];

exit

# Stops and remove all containers
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)

#apt install firewalld
#sudo firewall-cmd --zone=public --add-port=1433/tcp --permanent



