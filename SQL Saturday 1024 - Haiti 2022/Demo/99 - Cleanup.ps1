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
$SQL2 = "FROGSQL2"
$AGName = "DataFrogsAG"
$Database = "Kermit"
$Domain = "ConseilIT"
$CNO = "WSFCFrog"


Remove-DbaAvailabilityGroup -SqlInstance $SQL1 -AvailabilityGroup $AGName -Confirm:$false

Get-DbaEndpoint -SqlInstance $SQL1,$SQL2 -Endpoint hadr_endpoint | Remove-DbaEndpoint -Confirm:$false

Remove-DbaDatabase -SqlInstance $SQL1,$SQL2  -Database $Database -Confirm:$false

Remove-DbaLogin -SqlInstance $SQL1 -Login "$Domain`\$SQL2`$" -Confirm:$false
Remove-DbaLogin -SqlInstance $SQL2 -Login "$Domain`\$SQL1`$" -Confirm:$false

Disable-DbaAgHadr -SqlInstance $SQL1,$SQL2 -Force

Get-Cluster -Name $CNO | Remove-Cluster -Force -CleanupAD
Clear-ClusterNode -Name $SQL1 -Force
Clear-ClusterNode -Name $SQL2 -Force

Remove-WindowsFeature -Name Failover-Clustering -ComputerName $SQL1
Remove-WindowsFeature -Name Failover-Clustering -ComputerName $SQL2


restart-computer -ComputerName $SQL1 -Force
restart-computer -ComputerName $SQL2 -Force
