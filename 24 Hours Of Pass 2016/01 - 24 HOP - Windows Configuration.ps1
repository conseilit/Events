<#============================================================================
  File: Windows Configuration    
  Summary:  24HOP
  Date:     08/2016
  SQL Server Versions: 
------------------------------------------------------------------------------
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
 
 
 cls $StartDate=(Get-Date)# "High performance", "Balanced", "Power saver"function SetPowerPlan([string]$PreferredPlan) {     Write-Host "Setting Powerplan to $PreferredPlan"     $guid = (Get-WmiObject -Class win32_powerplan -Namespace root\cimv2\power -Filter "ElementName='$PreferredPlan'").InstanceID.tostring()     $regex = [regex]"{(.*?)}$"     $newpowerVal = $regex.Match($guid).groups[1].value     # setting power setting to high performance     powercfg -S  $newpowerVal } # set power optionSetPowerPlan "High performance"# RDPSet-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name fDenyTSConnections -Value 0Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name UserAuthentication -Value 1    # disable open server manager at logonSet-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\ServerManager' -Name DoNotOpenServerManagerAtLogon -Value 1Set-ItemProperty -Path 'HKCU:\Software\Microsoft\ServerManager' -Name CheckedUnattendLaunchSetting  -Value 0Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False# Download SSMSmd C:\Temp -forceInvoke-WebRequest "http://go.microsoft.com/fwlink/?LinkID=824938&clcid=0x409" -OutFile "C:\Temp\ssms-setup.exe" -UseBasicParsingcd C:\Temp.\ssms-setup.exe# Download SQL Server Expressmd C:\Temp -forceInvoke-WebRequest "http://192.168.1.4:8080/en_sql_server_2014_express_x64_exe_3941421.exe" -OutFile "C:\Temp\sqlexpr_x64_enu.exe" -UseBasicParsingRename-Computer -NewName 24HOP -Restart