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
 
 
cls
# 1. Install Container Feature
Enable-WindowsOptionalFeature -Online -FeatureName containers -All
# if using Windows 10 :
# Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All



# 2. Install Docker
Invoke-WebRequest "https://master.dockerproject.org/windows/amd64/docker-1.13.0-dev.zip" -OutFile "$env:TEMP\docker-1.13.0-dev.zip" -UseBasicParsing
Expand-Archive -Path "$env:TEMP\docker-1.13.0-dev.zip" -DestinationPath $env:ProgramFiles

# for quick use, does not require shell to be restarted
$env:path += ";c:\program files\docker"
# for persistent use, will apply even after a reboot 
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\Docker", [EnvironmentVariableTarget]::Machine)

# Docker as a Windows service
dockerd --register-service

# and start it
Start-Service Docker



# 3. Install base images from Dicker Hub

    # 3.1 Install SQL Server Express Container Images from Docker Hub
    docker pull microsoft/mssql-server-2014-express-windows
    # -> some issues (waiting for Windows 2016 RTM ?)
    # docker run --name 24hop1 -d -p 10001:1433 -v c:\mssql\24hop1:C:\mssql  --env sa_password=Password1 microsoft/mssql-server-2014-express-windows


    # 3.2 Install Base Container Images
    docker pull microsoft/windowsservercore
    # list images in the repository    Docker images
# checkpoint
# VM snapshot

# 4. Create a container with dockerfile

    # download a dockerfile to build the SQL Server image    md C:\Temp -Force    cd C:\Temp    wget https://github.com/brogersyh/Dockerfiles-for-windows/archive/master.zip -outfile master.zip    expand-archive master.zip    cd C:\Temp\master\Dockerfiles-for-windows-master\sqlexpress    Dir    Set-Alias Editeur "c:\windows\system32\WindowsPowerShell\v1.0\PowerShell_ISE.exe"    Editeur  C:\Temp\master\Dockerfiles-for-windows-master\sqlexpress\dockerfile    # and customize it    <#        # Have to replace the dependency for DotnetFX3.5, name has changed        # .NET 3.5 required for SQL Server
        FROM microsoft/dotnet35

        # can also change lo location of teh SQL Server binaries
        # from local web site or copy binaries from nistall folder
        md C:\Temp -force        Invoke-WebRequest "http://192.168.1.4:8080/en_sql_server_2014_express_x64_exe_3941421.exe" -OutFile "C:\Temp\sqlexpr_x64_enu.exe" -UseBasicParsing
        Copy-Item "C:\Temp\sqlexpr_x64_enu.exe" "C:\Temp\master\Dockerfiles-for-windows-master\sqlexpress"

    #>
    # build the image (~ 15 minutes)    docker.exe build -t sqlexpress .
    docker images



# run instances of this image
md c:\mssql\sql01 -force
md c:\mssql\sql02 -force
md c:\mssql\sql03 -force
md c:\mssql\sql04 -force
md c:\mssql\sql05 -force

docker run --name sql01 -d -p 61431:1433 -p 61771:7022 -v c:\mssql\sql01:c:\sql sqlexpress
docker run --name sql02 -d -p 61432:1433 -p 61772:7022 -v c:\mssql\sql02:c:\sql sqlexpress
docker run --name sql03 -d -p 61433:1433 -p 61773:7022 -v c:\mssql\sql03:c:\sql sqlexpress
docker run --name sql04 -d -p 61434:1433 -p 61774:7022 -v c:\mssql\sql04:c:\sql sqlexpress
docker run --name sql05 -d -p 61435:1433 -p 61775:7022 -v c:\mssql\sql05:c:\sql sqlexpress






md c:\mssql\sqlsaturday
docker run --name sqlsaturday -d -p 510:1433 -v c:\mssql\sqlsaturday:c:\sql sqlexpress


# list of running instances
docker ps

SQLCMD.exe -S "SQLContainers,510" -dmaster -Usa -Pthepassword2#  -Q 'PRINT @@servername;PRINT CONVERT(VARCHAR(50),SERVERPROPERTY(''MachineName''))'


# stop and delete an instance
docker stop sqlsaturday
docker rm sqlsaturday


<#
    Get-NetNatStaticMapping | ? ExternalPort -eq 61431 | Remove-NetNatStaticMapping  
    Get-NetNatStaticMapping | ft
    Get-NetNatStaticMapping | Remove-NetNatStaticMapping 
    docker inspect  sqlexpress

    docker ps -a
#>

