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


$Location1 = "eastus2"
$Location2 = "westus2"
$serverName1 = "eus-webinar-sqlserver-sql"
$serverName2 = "wus-webinar-sqlserver-sql"

$resourceGroupName = "webinar-sqlserver-rg"

$PoolName = "Pool1"
$DatabaseName1 = "DemoDB1"
$DatabaseName2 = "DemoDB2"


# Create two blank databases in the first pool
$firstDatabase = New-AzSqlDatabase  -ResourceGroupName $resourceGroupName `
    -ServerName $serverName1 `
    -DatabaseName $DatabaseName1 `
    -ElasticPoolName $PoolName

$secondDatabase = New-AzSqlDatabase  -ResourceGroupName $resourceGroupName `
    -ServerName $serverName1 `
    -DatabaseName $DatabaseName2 `
    -ElasticPoolName $PoolName

Get-AzSqlDatabase -ResourceGroupName $resourceGroupName -ServerName $serverName1


$FailoverGroupName =  $ProjectName + "-fg"
$failoverGroup = New-AzSqlDatabaseFailoverGroup -ResourceGroupName $resourceGroupName `
                                                -ServerName $serverName1 `
                                                -PartnerServerName $serverName2 `
                                                -FailoverGroupName $FailoverGroupName `
                                                -FailoverPolicy Automatic `
                                                -GracePeriodWithDataLossHours 1

$databases = Get-AzSqlElasticPoolDatabase -ResourceGroupName $resourceGroupName -ServerName $serverName1 -ElasticPoolName $PoolName 
$databases| ft
Add-AzSqlDatabaseToFailoverGroup -ResourceGroupName $resourceGroupName `
                                    -FailoverGroupName $FailoverGroupName `
                                    -ServerName $serverName1 `
                                    -Database $databases 



$ReadWriteListenerEndpoint = "webinar-sqlserver-fg.database.windows.net"
$ReadOnlyListenerEndpoint = "webinar-sqlserver-fg.secondary.database.windows.net"

$sqlcred = Get-Credential Christophe
Invoke-DbaQuery -sqlinstance $ReadWriteListenerEndpoint -query "SELECT @@servername,@@version;" -SqlCredential $sqlcred
Invoke-DbaQuery -sqlinstance $ReadWriteListenerEndpoint -query "CREATE TABLE DemoTable (
                                                                            ID INT IDENTITY(1,1),
                                                                            EventDateTime DATETIME2 DEFAULT GETUTCDATE()
                                                                                        )" `
                                                        -database $DatabaseName1 `
                                                        -SqlCredential $sqlcred

Invoke-DbaQuery -sqlinstance $ReadWriteListenerEndpoint -query "INSERT INTO DemoTable DEFAULT VALUES" `
                                                        -database $DatabaseName1 `
                                                        -SqlCredential $sqlcred

Invoke-DbaQuery -sqlinstance $ReadWriteListenerEndpoint -query "SELECT * FROM  DemoTable" -database $DatabaseName1 -SqlCredential $sqlcred | Format-Table
Invoke-DbaQuery -sqlinstance $ReadOnlyListenerEndpoint -query "SELECT * FROM  DemoTable" -database $DatabaseName1 -SqlCredential $sqlcred | Format-Table



