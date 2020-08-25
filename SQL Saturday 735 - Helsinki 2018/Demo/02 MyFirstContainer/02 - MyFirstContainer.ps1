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


# pull (download) a Windows Server Core image 
docker pull microsoft/windowsservercore
docker images


# download SQL Server express binaries
Get-ChildItem c:\sources
Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?linkid=829176" -OutFile c:\sources\sqlexpress.exe 



# host : create a container (interactive)
# PowerShell and PowerShellISE side-by-side
docker run --name MyFirstContainer -it microsoft/windowsservercore powershell

# container : create folder into container
mkdir sources

# host : list running containers
docker ps

# host : copy somes files into the container
Set-Location c:\sources
docker cp '.\InstallSQL.ps1' MyFirstContainer:/sources/InstallSQL.ps1
docker cp sqlexpress.exe MyFirstContainer:/sources/sqlexpress.exe

# container : expand the binaries
/sources/sqlexpress.exe /q /x:/sources/setup

# container : install SQL Server 
Set-Location sources
.\installSQL.ps1 

# last ~3 minutes, switch back to the slides

# host : list processes on host
Get-Process | Where-Object processname -Like *SQL* | Out-GridView
Get-Service | Where-Object displayname -like *SQL* | Out-GridView

# container : list services
Get-Process | Where-Object processname -Like *SQL* 
Get-Service | Where-Object displayname -like *SQL*


# Host : SQL Server is running we can connect
docker exec -it MyFirstContainer Powershell 

# container : run SQLCMD
.\SQLCMD.EXE -E 

# host : commit the container to create a new image
docker stop MyFirstContainer 
docker commit MyFirstContainer conseilit/myfirstsqlserverimage:version1

# the image has been created in the local repository
docker images


docker image inspect conseilit/myfirstsqlserverimage:version1


# and can run it again
docker run --name MyNewContainer -it conseilit/myfirstsqlserverimage:version1 powershell

