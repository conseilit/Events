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

# Create a container with SQ Server 2016 SP1 Express 
docker run --name sqldocker01 -d -p 40001:1433 -e sa_password=Password1! -e ACCEPT_EULA=Y microsoft/mssql-server-windows-express

# list all running containers
docker ps

# see container output
docker logs sqldocker01

# interactive connection to the container
docker exec -it sqldocker01 powershell.exe
docker exec -it sqldocker01 sqlcmd


# if image not found, pull it from docker hub, Next SQL Server release
docker run --name sqldocker02 -d -p 40002:1433 -e sa_password=Password1! -e ACCEPT_EULA=Y microsoft/mssql-server-windows
