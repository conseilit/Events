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

# Creates a dummy database
New-DbaDatabase -SqlInstance $SQL1 -Name $Database | Out-Null

# Even with automatic seeding, a full backup is required
Backup-DbaDatabase  -SqlInstance $SQL1 -Database $Database

# And finally add the database to the Availability group
Add-DbaAgDatabase -SqlInstance $SQL1 -AvailabilityGroup $AGName -Database $Database -SeedingMode Automatic

