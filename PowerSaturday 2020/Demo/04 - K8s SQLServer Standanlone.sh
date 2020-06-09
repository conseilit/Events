#==============================================================================
#
#  Summary:  PowerSaturday Online 2020
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



# Survival kit : Kubernetes commands
kubectl get nodes 

kubectl get deployment --all-namespaces             # kubectl get deployment -A
kubectl get services --all-namespaces               # kubectl get svc -A
kubectl get pods --all-namespaces                   # kubectl get pods -A
kubectl get persistentvolume --all-namespaces       # kubectl get pv -A
kubectl get persistentvolumeclaim --all-namespaces  # kubectl get pvc -A

# List all namespaces
kubectl get namespaces                         

# Now, create a SQL Server Pod

# Create a dedicated Namespace
kubectl create namespace mssql-standalone
kubectl get namespaces

# Create a secret to be used by SQL Server deployment
kubectl create secret generic mssql --from-literal=SA_PASSWORD="MyC0m9l&xP@ssw0rd"  --namespace mssql-standalone

# Deply a SQL Server Pod with a single YAML file containing
#  - Storage Class
#  - Persistent Volume Claim
#  - Deployment
#  - Service
cat sqlserver-standalone.yaml 
kubectl apply -f sqlserver-standalone.yaml --namespace mssql-standalone

# Get some information during deployment
kubectl get events --namespace=mssql-standalone

kubectl get deployment --namespace mssql-standalone
kubectl get pods --namespace mssql-standalone
kubectl get services --namespace mssql-standalone

watch kubectl get all --namespace mssql-standalone


# Connect to SQL server instance
/opt/mssql-tools/bin/sqlcmd -S 52.184.243.96,1433 -U SA -P 'MyC0m9l&xP@ssw0rd' -Q "SELECT @@servername,@@version;"
/opt/mssql-tools/bin/sqlcmd -S 52.184.243.96,1433 -U SA -P 'MyC0m9l&xP@ssw0rd' -Q "SELECT name from sys.databases;"

# Connect to a pod
kubectl exec -it mssql-deployment-c6b47c4b9-z7mfx  bash  --namespace mssql-standalone
ls /var/opt/mssql/data/
/opt/mssql-tools/bin/sqlcmd -S 127.0.0.1,1433 -U SA -P 'MyC0m9l&xP@ssw0rd' -Q "SELECT name from sys.databases;"
exit

# mssql-cli looks better !
sudo mssql-cli -S 52.184.243.96,1433 -U sa -P 'MyC0m9l&xP@ssw0rd' -d master 

# delete the pod !
kubectl delete pods mssql-deployment-c6b47c4b9-z7mfx  --namespace mssql-standalone
kubectl get pods --namespace mssql-standalone


# cleanup
kubectl delete -f sqlserver-standalone.yaml --namespace mssql-standalone
kubectl delete secret mssql --namespace mssql-standalone
kubectl delete namespace mssql-standalone
