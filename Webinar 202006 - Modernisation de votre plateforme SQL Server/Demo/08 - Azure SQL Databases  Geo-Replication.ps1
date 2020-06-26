#==============================================================================
#
#  Summary:  Webinar SQL Server
#  Date:     06/2020
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


$databasename = "AdventureWorksLT"
$rootname = "conseilit-"
$primaryResourceGroupName = $rootname + "fr"
$primaryServerName = $rootname + "fr"


# Establish Active Geo-Replication

$Secondaries = "sas","wus","eus"
foreach ($Secondary in $Secondaries){

    $secondaryResourceGroupName = $rootname + $Secondary
    $secondaryServerName = $rootname + $Secondary
    $database = Get-AzSqlDatabase -DatabaseName $databasename -ResourceGroupName $primaryResourceGroupName -ServerName $primaryServerName
    $database | New-AzSqlDatabaseSecondary -PartnerResourceGroupName $secondaryResourceGroupName `
                                           -PartnerServerName $secondaryServerName `
                                           -AllowConnections "All" -AsJob
}

# Update data to check synchronization
$cred = Get-Credential christophe.laporte
Invoke-DbaQuery -SqlInstance "conseilit-fr.database.windows.net" -Database $databasename `
                                                                 -Query "select * from SalesLT.Customer WHERE CustomerID = 1" `
                                                                 -SqlCredential $cred | Format-Table
Invoke-DbaQuery -SqlInstance "conseilit-wus.database.windows.net" -Database $databasename `
                                                                  -Query "select * from SalesLT.Customer WHERE CustomerID = 1" `
                                                                  -SqlCredential $cred | Format-Table

Invoke-DbaQuery -SqlInstance "conseilit-fr.database.windows.net" -Database $databasename `
                                                                 -Query "UPDATE SalesLT.Customer SET FirstName='Jean' WHERE CustomerID = 1" `
                                                                 -SqlCredential $cred | Format-Table

Invoke-DbaQuery -SqlInstance "conseilit-fr.database.windows.net" -Database $databasename `
                                                                 -Query "select * from SalesLT.Customer WHERE CustomerID = 1" `
                                                                 -SqlCredential $cred | Format-Table
Invoke-DbaQuery -SqlInstance "conseilit-wus.database.windows.net" -Database $databasename `
                                                                  -Query "select * from SalesLT.Customer WHERE CustomerID = 1" `
                                                                  -SqlCredential $cred | Format-Table

# Remove the replication link
# Remove the databases
$Secondaries = "sas","wus","eus"
foreach ($Secondary in $Secondaries){
    $secondaryResourceGroupName = $rootname + $Secondary
    $secondaryServerName = $rootname + $Secondary
    
    $database = Get-AzSqlDatabase -DatabaseName $databasename -ResourceGroupName $secondaryResourceGroupName -ServerName $secondaryServerName
    $secondaryLink = $database | Get-AzSqlDatabaseReplicationLink -PartnerResourceGroupName $primaryResourceGroupName -PartnerServerName $primaryServerName
    $secondaryLink | Remove-AzSqlDatabaseSecondary 
    $database | Remove-AzSqlDatabase
}

