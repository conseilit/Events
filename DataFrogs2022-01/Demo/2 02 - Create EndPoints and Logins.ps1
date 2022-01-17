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


$ep = New-DbaEndpoint -SqlInstance $SQL1,$SQL2 -Name hadr_endpoint -Type DatabaseMirroring -Port 5022
$ep | Start-DbaEndpoint


New-DbaLogin -SqlInstance $SQL1 -Login "$Domain`\$SQL2`$" 
Grant-DbaAgPermission -SqlInstance $SQL1 -Login "$Domain`\$SQL2`$"  -Type Endpoint -Permission Connect

New-DbaLogin -SqlInstance $SQL2 -Login "$Domain`\$SQL1`$"
Grant-DbaAgPermission -SqlInstance $SQL2 -Login "$Domain`\$SQL1`$" -Type Endpoint -Permission Connect

<#
New-DbaDbMasterKey -SqlInstance $sql1  -whatif
New-DbaDbCertificate -SqlInstance $sql1 -Confirm:$false
#>

<#
  # T-SQL Version from powershell

  $tSQL = "
    CREATE ENDPOINT MirroringEndpoint  
    STATE=STARTED   
    AS TCP (LISTENER_PORT=5022)   
    FOR DATABASE_MIRRORING (ROLE=ALL)  
    "
  Invoke-SqlCmd -Query $tSQL -Serverinstance $SQL1
  Invoke-SqlCmd -Query $tSQL -Serverinstance $SQL2

  # create the login and grant the service account on the endpoints

  $tSQL = "CREATE LOGIN [$Domain`\$SQL1`$] FROM WINDOWS;"
  Invoke-SqlCmd -Query $tSQL -Serverinstance $SQL2
  $tSQL = "GRANT CONNECT ON ENDPOINT::[MirroringEndpoint] TO [$Domain`\$SQL1`$];"
  Invoke-SqlCmd -Query $tSQL -Serverinstance $SQL2


  $tSQL = "CREATE LOGIN [$Domain`\$SQL2`$] FROM WINDOWS;"
  Invoke-SqlCmd -Query $tSQL -Serverinstance $SQL1
  $tSQL = "GRANT CONNECT ON ENDPOINT::[MirroringEndpoint] TO [$Domain`\$SQL2`$];"
  Invoke-SqlCmd -Query $tSQL -Serverinstance $SQL1

#>
