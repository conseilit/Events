#==============================================================================
#
#  Summary:  Webinar SQL Server
#  Date:     06/2020
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

ssh Christophe@52.177.94.151

# ubuntu
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/18.04/mssql-server-2019.list)"
sudo apt-get update
sudo apt-get install -y mssql-server
sudo /opt/mssql/bin/mssql-conf setup

# tools
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
sudo add-apt-repository "$(curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list)"
sudo apt-get update

sudo apt-get install -y mssql-tools unixodbc-dev
        
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
source ~/.bashrc

sqlcmd -S localhost -U SA -P 'Password1'
sqlcmd -S localhost,14331 -U SA -P 'Password1!'

# mssql-cli : better than sqlcmd
sudo apt-get install mssql-cli
mssql-cli 
select name from sys.databases;

# Exit mssql-cli 
exit

# Exit SSH
exit

Import-module dbaTools
$sqlcred = Get-Credential sa
$server = Connect-DbaInstance -SqlInstance 20.44.82.168 -SqlCredential $sqlcred
$server | Invoke-DbaQuery -query "SELECT @@servername,@@version;"

