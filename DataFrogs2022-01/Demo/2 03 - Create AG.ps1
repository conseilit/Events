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
$Domain = "ConseilIT.local"
$AGName = "DataFrogsAG"


New-DbaAvailabilityGroup -Name $AGName `
                         -Primary $SQL1 -Secondary $SQL2 `
                         -FailoverMode Automatic -SeedingMode Automatic -AutomatedBackupPreference Primary  `
                         -EndpointUrl "TCP://$SQL1`.$Domain`:5022", "TCP://$SQL2`.$Domain`:5022" `
                         -confirm:$false


<#
# T-SQL Version from powershell

  $tSQL = "
  CREATE AVAILABILITY GROUP [$AGName]
  FOR REPLICA ON 
  '$SQL1' 
      WITH (   ENDPOINT_URL = 'TCP://$SQL1`.$Domain`:5022', 
              AVAILABILITY_MODE = SYNCHRONOUS_COMMIT, 
              FAILOVER_MODE = AUTOMATIC,
              SEEDING_MODE = AUTOMATIC  ),
  '$SQL2' 
      WITH (   ENDPOINT_URL = 'TCP://$SQL2`.$Domain`:5022', 
              AVAILABILITY_MODE = SYNCHRONOUS_COMMIT, 
              FAILOVER_MODE = AUTOMATIC,
              SEEDING_MODE = AUTOMATIC )
  "
  Invoke-SqlCmd -Query $tSQL -Serverinstance $SQL1

  # grant the AG to create a database
  $tSQL = "ALTER AVAILABILITY GROUP [$AGName] GRANT CREATE ANY DATABASE"
  Invoke-SqlCmd -Query $tSQL -Serverinstance $SQL1


  # join the secondary node and also grant create database
  $tSQL = "
  ALTER AVAILABILITY GROUP [$AGName] JOIN
  ALTER AVAILABILITY GROUP [$AGName] GRANT CREATE ANY DATABASE
  "
  Invoke-SqlCmd -Query $tSQL -Serverinstance $SQL2

#>