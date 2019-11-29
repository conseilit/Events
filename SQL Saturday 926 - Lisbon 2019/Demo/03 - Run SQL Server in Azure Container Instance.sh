#==============================================================================
#
#  Summary:  SQLSaturday Lisbon #926 - 2019
#  Date:     11/2019
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


az login
	  
az account list 

az account set --subscription "3c4283b9-a29c-4a4d-8098-f661dd48d098"

# create a resource group
az group create --name sqlserver-aci --location westeurope

# and create a container inside ACI
az container create --resource-group sqlserver-aci  \
                    --name mssqlaci \
                    --image mcr.microsoft.com/mssql/server:2019-latest \
                    --ip-address public --ports 1433 \
                    --environment-variables ACCEPT_EULA=Y MSSQL_SA_PASSWORD=P@ssw0rd1! \
                    --dns-name-label conseilit-sqlserver-aci \
                    --cpu 4 --memory 16

# check that the container has been created
az container list --resource-group sqlserver-aci 

# We can see some logs
az container logs --resource-group sqlserver-aci  --name mssqlaci

# connect to the container
az container exec --resource-group sqlserver-aci --name mssqlaci --container-name mssqlaci --exec-command "/bin/bash"

# and finally connect to the SQL Server instance
/opt/mssql-tools/bin/sqlcmd -S conseilit-sqlserver-aci.westeurope.azurecontainer.io \
                            -U SA -P 'P@ssw0rd1!' -Q "SELECT name from sys.databases;"

# cleanup
az container delete --name sqlserver-aci --resource-group sqlserver-aci 
az group delete --name sqlserver-aci --resource-group sqlserver-aci 

