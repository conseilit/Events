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

$CNO = "WSFCFrog"

Get-Cluster -Name $CNO | Format-List *subnet*

(Get-Cluster -Name $CNO).SameSubnetThreshold = 20 
(Get-Cluster -Name $CNO).CrossSubnetThreshold = 20 
(Get-Cluster -Name $CNO).RouteHistoryLength = 40 

#(Get-Cluster -Name $CNO).SameSubnetDelay=2000

(Get-Cluster -Name $CNO).ClusterLogSize

Set-ClusterLog -Cluster $CNO -Size 2000

(Get-Cluster -Name $CNO).ClusterLogSize



