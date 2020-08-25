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

# Pull SQL Server Express 2016 SP1 from Docker Hub
docker pull microsoft/mssql-server-windows-express

# Pull SQL Server Developer 2016 SP1 from Docker Hub
docker pull microsoft/mssql-server-windows-developer

# Pull SQL Server developper v.Next from Docker Hub 
docker pull microsoft/mssql-server-windows



## Build custom SQL Server Express image
docker.exe build -t sqlexpress .


