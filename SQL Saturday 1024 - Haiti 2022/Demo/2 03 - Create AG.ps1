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
$Domain = "ConseilIT"
$AGName = "DataFrogsAG"

# Creates an empty Availability Group with automatic seeding, synchronous commit and automatic failover
New-DbaAvailabilityGroup -Name $AGName `
                         -Primary $SQL1 -Secondary $SQL2 `
                         -FailoverMode Automatic -SeedingMode Automatic -AutomatedBackupPreference Primary  `
                         -EndpointUrl "TCP://$SQL1`.$Domain`.local:5022", "TCP://$SQL2`.$Domain`.local:5022" `
                         -confirm:$false

