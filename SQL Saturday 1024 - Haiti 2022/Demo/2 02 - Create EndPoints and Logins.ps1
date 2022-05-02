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

# Create an endpoint to allow mirroring sessions to be established
$ep = New-DbaEndpoint -SqlInstance $SQL1,$SQL2 -Name hadr_endpoint -Type DatabaseMirroring -Port 5022
$ep | Start-DbaEndpoint

# On SQL1 create a login for SQL2 and allow to connect the endpoint
New-DbaLogin -SqlInstance $SQL1 -Login "$Domain`\$SQL2`$" 
Grant-DbaAgPermission -SqlInstance $SQL1 -Login "$Domain`\$SQL2`$"  -Type Endpoint -Permission Connect

# On SQL2 create a login for SQL1 and allow to connect the endpoint
New-DbaLogin -SqlInstance $SQL2 -Login "$Domain`\$SQL1`$"
Grant-DbaAgPermission -SqlInstance $SQL2 -Login "$Domain`\$SQL1`$" -Type Endpoint -Permission Connect
