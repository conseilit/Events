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


# Setup SQL ... Traditional way using the GUI
# or the command line / PowerShell scripts
# https://www.youtube.com/watch?v=fQsbK1cl-8U



# Don't forget to setup your maintenance tasks as usual
# House Keeping, Backup, Integritiy Checks, Index reorg / rebuild, Statistics Update
# https://www.youtube.com/watch?v=GjM3Q9grOKc


# Firewall
New-NetFirewallRule -DisplayName "SQL Server default port 1433" -Direction Inbound  -Protocol TCP -LocalPort 1433 -Action Allow
New-NetFirewallRule -DisplayName "SQL Server DAC port 1434"     -Direction Inbound  -Protocol TCP -LocalPort 1434 -Action Allow
New-NetFirewallRule -DisplayName "SQL Server Browser UDP 1434"  -Direction Inbound  -Protocol UDP -LocalPort 1434 -Action Allow

# Specific rules for AlwaysOn Availability Groups / DBM : TCP Port 5022
New-NetFirewallRule -DisplayName "SQL Server AG 5022 IN"  -Direction Inbound   -Protocol TCP -LocalPort 5022 -Action Allow
New-NetFirewallRule -DisplayName "SQL Server AG 5022 OUT" -Direction Outbound  -Protocol TCP -LocalPort 5022 -Action Allow
