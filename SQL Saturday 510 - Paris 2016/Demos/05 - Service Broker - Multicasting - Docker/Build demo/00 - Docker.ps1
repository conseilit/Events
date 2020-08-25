<#============================================================================
  File:     
  Summary:  SQL Saturday 510 - Paris
  Date:     06/2016
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
 


# Inital steps to enable containers & docker on Windows 2016

Install-windowsfeature NET-Framework-Features -source D:\Sources\sxs
Install-WindowsFeature containers

New-Item -Type Directory -Path 'C:\Program Files\docker\'
Invoke-WebRequest https://aka.ms/tp5/b/dockerd -OutFile $env:ProgramFiles\docker\dockerd.exe
Invoke-WebRequest https://aka.ms/tp5/b/docker -OutFile $env:ProgramFiles\docker\docker.exe
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\Docker", [EnvironmentVariableTarget]::Machine)

Start-Service Docker


# install the container image package provider 
Install-PackageProvider ContainerImage -Force

# Install the Windows Server core image. 
Install-ContainerImage -Name WindowsServerCore

Docker image
Stop-Service Docker
Start-Service DOCKER
Docker image

docker tag 50eb6792a3d4 windowsservercore:latest
docker images

# get a docker file to build images
wget https://github.com/brogersyh/Dockerfiles-for-windows/archive/master.zip -outfile master.zip
expand-archive master.zip
cd C:\Users\Administrator\master\Dockerfiles-for-windows-master\sqlexpress

# build an image
docker.exe build -t sqlexpress .
docker images

# run instances of this image
docker run --name sql01 -d -p 61431:1433 -p 61771:7022 -v e:\mssql\sql01:c:\sql sqlexpress
docker run --name sql02 -d -p 61432:1433 -p 61772:7022 -v e:\mssql\sql02:c:\sql sqlexpress
docker run --name sql03 -d -p 61433:1433 -p 61773:7022 -v e:\mssql\sql03:c:\sql sqlexpress
docker run --name sql04 -d -p 61434:1433 -p 61774:7022 -v e:\mssql\sql04:c:\sql sqlexpress
docker run --name sql05 -d -p 61435:1433 -p 61775:7022 -v e:\mssql\sql05:c:\sql sqlexpress

md E:\mssql\sqlsaturday
docker run --name sqlsaturday -d -p 510:1433 -v e:\mssql\sqlsaturday:c:\sql sqlexpress


# list of running instances
docker ps

SQLCMD.exe -S "HVBlue3,510" -dmaster -Usa -Pthepassword2#  -Q 'PRINT @@servername;PRINT CONVERT(VARCHAR(50),SERVERPROPERTY(''MachineName''))'


# stop and delete an instance
docker stop sqlsaturday
docker rm sqlsaturday

