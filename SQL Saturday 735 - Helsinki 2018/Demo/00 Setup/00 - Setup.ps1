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

DS4V2
# create 3 VMs ds4v2
# 1 VM Ubuntu 
# 1 VM Windows 
# 1 VM Windows (backup) + tout installé 


ZoomIT dans VM


# copy demo files on c:\sources

# download and install SSMS on VM
mkdir c:\sources
Set-Location c:\sources
#Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?linkid=847722" -OutFile ssms-setup-enu.exe 
Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?linkid=870039&clcid=0x409" -OutFile ssms-setup-enu.exe # 17.6
# .\ssms-setup-enu.exe /install /passive


# download SQL Server express binaries 
Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?linkid=829176" -OutFile c:\sources\sqlexpress.exe 

# The PowerShell command to install the SQL Server module is: 
Install-module -Name SqlServer -Scope CurrentUser

.\ssms-setup-enu.exe /install /passive




Install-Module -Name DockerMsftProvider -Repository PSGallery -Force
Install-Module -Name DockerMsftProvider -Force

# install the latest version of Docker
Install-Package -Name docker -ProviderName DockerMsftProvider -Force

# check if reboot needed
(Install-WindowsFeature Containers).RestartNeeded

# If so restart Windows
Restart-Computer -Force

# /!\ Pulling Windows Core image takes a while (writting to disk / latency)
# TotalSeconds      : 487.5883516 (8 minutes DS4V2)
# so run the docker pull now
docker pull microsoft/windowsservercore
docker images


docker pull microsoft/mssql-server-windows-express
docker pull microsoft/mssql-server-windows-developer
docker pull microsoft/mssql-server-windows





# install tools and connect on linux VM
curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
add-apt-repository "$(curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list)"

apt-get update
apt-get install -y mssql-tools unixodbc-dev

echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
source ~/.bashrc



# Import the public repository GPG keys
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | apt-key add -

# Register the Microsoft Ubuntu repository
curl -o /etc/apt/sources.list.d/microsoft.list https://packages.microsoft.com/config/ubuntu/16.04/prod.list

# Update the list of products
apt-get update

# Install mssql-cli
apt-get install mssql-cli


# install docker-compose application
apt-get install docker-compose # version 1.8
docker-compose --version

curl -L https://github.com/docker/compose/releases/download/1.21.1/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version

# install htop application
apt-get install htop




sudo su error :
vi /etc/hostname file contains just the name of the machine.
vi /etc/hosts has an entry for localhost. 

