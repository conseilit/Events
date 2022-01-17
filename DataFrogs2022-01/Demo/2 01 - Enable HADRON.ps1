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


Enable-DbaAgHadr -SqlInstance $SQL1,$SQL2 -Force


<#
  # SQLPS version

  function EnableHADRON([string]$ServerName) 
  { 

      Enable-SqlAlwaysOn -Path SQLSERVER:\SQL\$ServerName\DEFAULT -Force
      Restart-Service -InputObject $(Get-Service -Computer $ServerName -Name "MSSQLSERVER") -Force

  }

  EnableHADRON $SQL1
  EnableHADRON $SQL2



#>
