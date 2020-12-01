#==============================================================================
#
#  Event   : SQL Saturday #1012 - Montreal 2020
#  Session : From Docker to Big Data Clusters - a new era for SQL Server
#  Date    : 11/2020
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
kubectl create namespace sqlsaturday
kubectl get namespaces

# refresh every 2 seconds the resources created
watch kubectl get all --namespace sqlsaturday

# Create a secret to be used by SQL Server deployment
kubectl create secret generic mssql \
            --from-literal=SA_PASSWORD="MyC0m9l&xP@ssw0rd"  \
            --namespace sqlsaturday

# Deploy a SQL Server Pod with a single YAML file containing
#  - Storage Class
#  - Persistent Volume Claim
#  - Deployment
#  - Service
cat AKS-SQLServer-AllinOne.yaml
kubectl apply -f AKS-SQLServer-AllinOne.yaml --namespace sqlsaturday



# But we can also create objects independently
# Load Balancer might take a while to bring online
cat AKS-SQLServer-LoadBalancer.yaml
cat AKS-SQLServer-Storage.yaml
cat AKS-SQLServer-Deployment.yaml
kubectl apply -f AKS-SQLServer-LoadBalancer.yaml --namespace sqlsaturday
kubectl apply -f AKS-SQLServer-Storage.yaml --namespace sqlsaturday
kubectl apply -f AKS-SQLServer-Deployment.yaml --namespace sqlsaturday


# Get some information during deployment
kubectl get events --namespace sqlsaturday

kubectl get deployment --namespace sqlsaturday
kubectl get pods --namespace sqlsaturday
kubectl get services --namespace sqlsaturday

kubectl describe pod mssql-deployment-68757dd56b-l8ttt --namespace sqlsaturday

# Connect to SQL server instance
sqlcmd -S 20.44.87.119,1433 -U SA -P 'MyC0m9l&xP@ssw0rd' -Q "SELECT @@servername,@@version;"
sqlcmd -S 20.44.87.119,1433 -U SA -P 'MyC0m9l&xP@ssw0rd' -Q "CREATE DATABASE [HighlyCriticalDatabase];"
sqlcmd -S 20.44.87.119,1433 -U SA -P 'MyC0m9l&xP@ssw0rd' -Q "SELECT name from sys.databases;"

# Connect to a pod
kubectl get pods --namespace sqlsaturday
kubectl exec -it mssql-deployment-68757dd56b-gj2jh  bash --namespace sqlsaturday
ls /var/opt/mssql/data/
/opt/mssql-tools/bin/sqlcmd -S 127.0.0.1,1433 -U SA -P 'MyC0m9l&xP@ssw0rd' -Q "SELECT name from sys.databases;"
exit


# Desired State Configuration
kubectl delete pod mssql-deployment-68757dd56b-gj2jh --namespace sqlsaturday

# The instance is still alive ... The Pod has bee recreated and the storage attached
sqlcmd -S 20.44.87.119,1433 -U SA -P 'MyC0m9l&xP@ssw0rd' -Q "SELECT name from sys.databases;"



# cleanup
kubectl delete -f AKS-SQLServer-AllinOne.yaml --namespace sqlsaturday
kubectl delete -f AKS-SQLServer-Deployment.yaml --namespace sqlsaturday
kubectl delete -f AKS-SQLServer-LoadBalancer.yaml --namespace sqlsaturday
kubectl delete -f AKS-SQLServer-Storage.yaml --namespace sqlsaturday
kubectl delete secret mssql --namespace sqlsaturday
kubectl delete namespace sqlsaturday
