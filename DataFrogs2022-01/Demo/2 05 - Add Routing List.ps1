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
$Domain = "ConseilIT.local"
$AGName = "DataFrogsAG"



  # T-SQL Version from powershell
    
    $tSQL = "
        ALTER AVAILABILITY GROUP [$AGName]
        MODIFY REPLICA ON N'$SQL1' 
        WITH (SECONDARY_ROLE (ALLOW_CONNECTIONS = READ_ONLY));

        ALTER AVAILABILITY GROUP [$AGName]
        MODIFY REPLICA ON N'$SQL1' 
        WITH (SECONDARY_ROLE (READ_ONLY_ROUTING_URL = N'TCP://$SQL1`.$Domain`:1433'));

        ALTER AVAILABILITY GROUP [$AGName]
        MODIFY REPLICA ON N'$SQL2' 
        WITH (SECONDARY_ROLE (ALLOW_CONNECTIONS = READ_ONLY));

        ALTER AVAILABILITY GROUP [$AGName]
        MODIFY REPLICA ON N'$SQL2' 
        WITH (SECONDARY_ROLE (READ_ONLY_ROUTING_URL = N'TCP://$SQL1`.$Domain`:1433'));

        ALTER AVAILABILITY GROUP [$AGName] 
        MODIFY REPLICA ON N'$SQL1'
        WITH (PRIMARY_ROLE (READ_ONLY_ROUTING_LIST=('$SQL2','$SQL1')));

        ALTER AVAILABILITY GROUP [$AGName] 
        MODIFY REPLICA ON N'$SQL2' 
        WITH (PRIMARY_ROLE (READ_ONLY_ROUTING_LIST=('$SQL1','$SQL2')));
        GO
    "
    Invoke-SqlCmd -Query $tSQL -Serverinstance "$SQL1" 

