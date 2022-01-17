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


New-DbaDatabase -SqlInstance $SQL1 -Name $Database | Out-Null

Backup-DbaDatabase  -SqlInstance $SQL1 -Database $Database
			
Add-DbaAgDatabase -SqlInstance $SQL1 -AvailabilityGroup $AGName -Database $Database -SeedingMode Automatic


<#
  $tSQL = "
  CREATE DATABASE [$Database];
  "
  Invoke-SqlCmd -Query $tSQL -Serverinstance $SQL1
    
  
  # Dummy backup to fake the controls for adding a DB into an AG
  # Do not run on a production environment
  $tSQL = "
  BACKUP DATABASE [$Database] TO DISK = 'NUL';
  "
  Invoke-SqlCmd -Query $tSQL -Serverinstance $SQL1
  
  
  $tSQL = "
  ALTER AVAILABILITY GROUP [$AG]
  ADD DATABASE [$Database];
  "
  Invoke-SqlCmd -Query $tSQL -Serverinstance $SQL1

#>  