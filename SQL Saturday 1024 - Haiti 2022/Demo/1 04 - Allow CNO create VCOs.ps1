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

# create child objects pour le CNO 
$ou = "AD:\" + (Get-ADObject -Filter 'Name -like "Computers"').DistinguishedName 
$sid = (Get-ADComputer -Filter 'ObjectClass -eq "Computer"' | where-object name -eq "$CNO").SID
$acl = get-acl -path $ou


$acl.access | Select-Object IdentityReference, ActiveDirectoryRights | Sort-Object –unique | Out-GridView  #to get access right of the OU


# Create a new access control entry to allow access to the OU
$identity = [System.Security.Principal.IdentityReference] $sid
$type = [System.Security.AccessControl.AccessControlType] "Allow"
$inheritanceType = [System.DirectoryServices.ActiveDirectorySecurityInheritance] "All"
$adRights = [System.DirectoryServices.ActiveDirectoryRights] "CreateChild"
$ace1 = New-Object System.DirectoryServices.ActiveDirectoryAccessRule $identity,$adRights,$type,$inheritanceType
$adRights = [System.DirectoryServices.ActiveDirectoryRights] "GenericRead"
$ace2 = New-Object System.DirectoryServices.ActiveDirectoryAccessRule $identity,$adRights,$type,$inheritanceType


# Add the ACE in the ACL and set the ACL on the object 
$acl.AddAccessRule($ace1)
$acl.AddAccessRule($ace2)
set-acl -aclobject $acl $ou

