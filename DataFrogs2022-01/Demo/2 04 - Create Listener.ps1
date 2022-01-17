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


Add-DbaAgListener -SqlInstance $SQL1 -AvailabilityGroup $AGName -Dhcp -Port 1433

<#
  # T-SQL Version from powershell

  $tSQL = "
    ALTER AVAILABILITY GROUP [$AGName]
    ADD LISTENER N'$AGName ' (
    WITH DHCP  , PORT=1433);
  "
  Write-Host $tSQL 
  Invoke-SqlCmd -Query $tSQL -Serverinstance $SQL1

#>

