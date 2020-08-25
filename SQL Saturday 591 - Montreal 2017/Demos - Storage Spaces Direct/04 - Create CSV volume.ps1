<#============================================================================
  File:     Docker - SQL Server
  Summary:  SQL Saturday 591 - Montreal
  Date:     03/2017
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
 
 
$Username = 'DEMO\Administrator'
$Password = 'Password1'

$pass = ConvertTo-SecureString -AsPlainText $Password -Force
$Cred = New-Object System.Management.Automation.PSCredential -ArgumentList $Username,$pass

Invoke-Command -Credential $Cred -VMName $VmName { 

    New-Volume -StoragePoolFriendlyName 'S2D on ClustS2D' `
               -FriendlyName SQLServer `
               -ResiliencySettingName 'Mirror' `
               -PhysicalDiskRedundancy 1 `
               -FileSystem CSVFS_REFS `
               -Size 20GB

}


# show cluster console

<#
# 2 way mirroring 
New-Volume -StoragePoolFriendlyName 'S2D on ClustS2D' `
               -FriendlyName 2wmVolume `
               -ResiliencySettingName 'Mirror' `
               -PhysicalDiskRedundancy 1 `
               -FileSystem CSVFS_REFS `
               -Size 20GB


# 3 way mirroring 
New-Volume -StoragePoolFriendlyName 'S2D on ClustS2D' `
               -FriendlyName 3wmVolume `
               -ResiliencySettingName 'Mirror' `
               -PhysicalDiskRedundancy 2 `
               -FileSystem CSVFS_REFS `
               -Size 20GB


# Single Parity
New-Volume -StoragePoolFriendlyName 'S2D on ClustS2D' `
               -FriendlyName spVolume `
               -ResiliencySettingName 'Parity' `
               -PhysicalDiskRedundancy 1 `
               -FileSystem CSVFS_REFS `
               -Size 20GB


# Dual partity
New-Volume -StoragePoolFriendlyName 'S2D on ClustS2D' `
               -FriendlyName dpVolume `
               -ResiliencySettingName 'Parity' `
               -PhysicalDiskRedundancy 2 `
               -FileSystem CSVFS_REFS `
               -Size 20GB

#>
