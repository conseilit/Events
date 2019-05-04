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



# cleanup
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)

# run multiple containers for fun
docker run  -d -p 14331:1433  -e 'MSSQL_PID=developer' -e 'SA_PASSWORD=Password1!' -e 'ACCEPT_EULA=Y' microsoft/mssql-server-linux
docker run  -d -p 14332:1433  -e 'MSSQL_PID=developer' -e 'SA_PASSWORD=Password1!' -e 'ACCEPT_EULA=Y' microsoft/mssql-server-linux
docker run  -d -p 14333:1433  -e 'MSSQL_PID=developer' -e 'SA_PASSWORD=Password1!' -e 'ACCEPT_EULA=Y' microsoft/mssql-server-linux
docker run  -d -p 14334:1433  -e 'MSSQL_PID=developer' -e 'SA_PASSWORD=Password1!' -e 'ACCEPT_EULA=Y' microsoft/mssql-server-linux
docker run  -d -p 14335:1433  -e 'MSSQL_PID=developer' -e 'SA_PASSWORD=Password1!' -e 'ACCEPT_EULA=Y' microsoft/mssql-server-linux

# Faster than creating VMs !

# cleanup
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)


