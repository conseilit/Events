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


$SQL1 = "FROGSQL1"
$SQL2 = "FROGSQL2"
$Domain = "ConseilIT"
$AGName = "DataFrogsAG"

# Configuring Endpoint URLs for replica 1 and replica 2
Get-DbaAgReplica -SqlInstance $SQL1  -Replica $SQL1 `
    | Set-DbaAgReplica -AvailabilityGroup $AGName `
                       -ReadonlyRoutingConnectionUrl "TCP://$SQL1`.$Domain`.local:1433" `
                       -ConnectionModeInSecondaryRole Yes | Out-Null 
 
Get-DbaAgReplica -SqlInstance $SQL1  -Replica $SQL2 `
    | Set-DbaAgReplica -AvailabilityGroup $AGName `
                       -ReadonlyRoutingConnectionUrl "TCP://$SQL2`.$Domain`.local:1433" `
                       -ConnectionModeInSecondaryRole Yes | Out-Null

# For Read Intent Only : AllowReadIntentConnectionsOnly


# Creating the routing lists
Get-DbaAgReplica -SqlInstance $SQL1  -Replica $SQL1 `
    | Set-DbaAgReplica -AvailabilityGroup $AGName -ReadOnlyRoutingList $SQL2 , $SQL1 | Out-Null
                                          
Get-DbaAgReplica -SqlInstance $SQL1  -Replica $SQL2 `
    | Set-DbaAgReplica -AvailabilityGroup $AGName -ReadOnlyRoutingList $SQL1 , $SQL2 | Out-Null
            
# Adding some load balancing
# -ReadOnlyRoutingList @(,('$SQL2','$SQL3'));

Get-DbaAgReplica -SqlInstance $SQL1 `
 | Select-Object SqlInstance,AvailabilityGroup,Replica,Role,FailoverMode,ReadonlyRoutingList `
 | Format-Table -autosize 

 