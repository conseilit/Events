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

$CNO = "WSFCFrog"
$FSW = "\\Formation\FSW"
$ADGroup = "ServeursSQL"

<#
# Fileshare on Formation computer
New-Item -type directory -path "E:\FSW"
New-SMBShare –Name “FSW” –Path "E:\FSW" –FullAccess "Administrators"

#>

# Check FSW folder share
Get-SmbShare -Name "FSW" | Format-Table -AutoSize
Get-SmbShareAccess -Name "FSW"  | Format-Table -AutoSize

# Add the CNO to the 
Get-ADGroupMember -Identity $ADGroup
Add-ADGroupMember -Identity $ADGroup -Members "$($CNO)`$"
Get-ADGroupMember -Identity $ADGroup


 # Adjust Quorum settings to use the FSW
Get-Cluster -Name $CNO | Set-ClusterQuorum -FileShareWitness $FSW
