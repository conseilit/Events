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

docker build -t customsqlserverimage .
docker run -d --name sqldocker -p 1433:1433 -e sa_password=Password1! -e ACCEPT_EULA=Y  customsqlserverimage
docker logs sqldocker

docker ps 
docker exec -it sqldocker bash
/opt/mssql-tools/bin/sqlcmd -S localhost,1433 -U SA -PPassword1!
docker exec -it sqldocker /opt/mssql-tools/bin/sqlcmd -S localhost,1433 -Usa -PPassword1! -Q 'SELECT name FROM sys.server_principals;'
docker exec -it sqldocker /opt/mssql-tools/bin/sqlcmd -S localhost,1433 -Udba1 -Pdba1 -Q 'SELECT name FROM sys.server_principals;'
docker exec -it sqldocker /opt/mssql-tools/bin/sqlcmd -S localhost,1433 -UDockerHealthCheck -PDockerHealthCheck -Q 'select login_name,program_name,host_name from sys.dm_exec_sessions WHERE is_user_process=1;'


docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker rmi customsqlserverimage

docker images 
