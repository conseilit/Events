<#============================================================================
  
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

Clear-Host

$SQL1 = "FROGSQL1"
$AGName = "DataFrogsAG"
$Database = "Kermit"

# Check status
Get-DbaAgReplica -SqlInstance $SQL1 `
 | Select-Object SqlInstance,AvailabilityGroup,Replica,Role,FailoverMode,ReadonlyRoutingList `
 | Format-Table -autosize 

# Run queries on Primary and Seconday using Routing List 
Invoke-DbaQuery -SqlInstance $AGName -Database $Database -Query "SELECT @@servername" 
Invoke-DbaQuery -SqlInstance $AGName -Database $Database -ReadOnly -Query "SELECT @@servername" 

# Perform a failover
Invoke-DbaAgFailover -SqlInstance $SQL2 -AvailabilityGroup $AGName -Confirm:$false

# And check again the routing list
Invoke-DbaQuery -SqlInstance $AGName -Database $Database -Query "SELECT @@servername" 
Invoke-DbaQuery -SqlInstance $AGName -Database $Database -ReadOnly -Query "SELECT @@servername" 
