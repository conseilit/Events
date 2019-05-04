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

# pull the official image for nginx
docker pull nginx

## install docker-compose application
# apt-get install docker-compose 
## and update it to the latest version
# sudo curl -L https://github.com/docker/compose/releases/download/1.21.1/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
# sudo chmod +x /usr/local/bin/docker-compose
# docker-compose --version

# copy files into the host - change to UNIX format
# copy docker-compose.yml 
# copy nginx.conf file

# Run the application (1 load balancer and 5 SQL Server as backend)
docker-compose up -d 

# connect to the load balancer
/opt/mssql-tools/bin/sqlcmd -S 127.0.0.1,1433 -U SA -P 'Password1!' -Q "select @@servername"


# Stop teh entire application
docker-compose down 

