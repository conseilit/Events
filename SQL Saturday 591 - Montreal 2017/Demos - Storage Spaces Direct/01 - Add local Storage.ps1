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
 
 

# Adding VHDX to each VM
# At least 4 disks per VM required

$VhdPath     = "C:\Hyper-V\Virtual Hard Disks"			       
$VMNames=”SRV1”,”SRV2”
foreach ($VmName in $VMNames) {
    Get-VM -Name $VmName | Stop-VM -Force
    Add-VMScsiController –VMName $VmName 

    for ($i=1; $i -le 4; $i++){
        New-VHD  -Path $VhdPath"\$VmName-Data$i.vhdx" -SizeBytes 10GB
        Add-VMHardDiskDrive  -VMName $VmName  -Path $VhdPath"\$VmName-Data$i.vhdx" –ControllerType SCSI -ControllerNumber 1
        Write-Host "Disk $VhdPath\$VmName-Data$i.vhdx Added to $VmName"
    }
    Get-VM -Name $VmName | Start-VM
}

