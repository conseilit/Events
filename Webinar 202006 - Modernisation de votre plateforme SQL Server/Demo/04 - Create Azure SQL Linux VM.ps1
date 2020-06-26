#==============================================================================
#
#  Summary:  Webinar SQL Server
#  Date:     06/2020
#
#  ----------------------------------------------------------------------------
#  Written by Christophe LAPORTE, SQL Server MVP / MCM
#	Blog    : http://conseilit.wordpress.com
#	Twitter : @ConseilIT
#  
#  You may alter this code for your own *non-commercial* purposes. You may
#  republish altered code as long as you give due credit.
#  
#  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
#  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
#  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
#  PARTICULAR PURPOSE.
#==============================================================================

$ResourceGroupName = "webinar-sqlserver-rg"
$Location = "EastUS2"
$virtualnetworkName = "webinar-sqlserver-vnet"
$VnetDefaultName = "default"

#Define the following parameters for the virtual machine.
$vmAdminUsername = "Christophe"
$vmAdminPassword = ConvertTo-SecureString "Password1!" -AsPlainText -Force
 
#Define the following parameters for the Azure resources.
$azureVmName                = "eus-sqlubuntu-vm"
$azureVmOsDiskName          = $azureVmName + "-OS"
$azureVmSize                = "Standard_B4ms"
 
#Define the networking information.
$azureNicName               = $azureVmName + "-nic"
$azurePublicIpName          = $azureVmName + "-ip"
 
 
#Define the VM marketplace image details.
$azureVmPublisherName = "MicrosoftSQLServer"
$azureVmOffer = "sql2019-ubuntu1804"
$azureVmSkus = "sqldev"

<#
    $locName = "FranceCentral"
    Get-AzVMImagePublisher -Location $locName | where-object {$_.PublisherName -match "microsoft"} | Select PublisherName
    MicrosoftWindowsServer
    MicrosoftSQLServer
    $pubName="MicrosoftSQLServer"
    Get-AzVMImageOffer -Location $locName -PublisherName $pubName | Select Offer
    $offerName="sql2019-ubuntu1804"
    $offerName="sql2019-ws2019"
    Get-AzVMImageSku -Location $locName -PublisherName $pubName -Offer $offerName | Select Skus
    $skuName="sqldev"
    Get-AzVMImage -Location $locName -PublisherName $pubName -Offer $offerName -Sku $skuName | Select *
#>


#Create the public IP address.
$azurePublicIp = New-AzPublicIpAddress -Name $azurePublicIpName `
                                       -ResourceGroupName $ResourceGroupName `
                                       -Location $Location -AllocationMethod Static -Sku Standard
 
#Create the NIC and associate the public IpAddress.
$azureVnetSubnet = (Get-AzVirtualNetwork -Name $virtualnetworkName -ResourceGroupName $ResourceGroupName).Subnets | Where-Object {$_.Name -eq $VnetDefaultName}

Get-AzNetworkSecurityGroup -name $NetworkSecurityGroupName  -ResourceGroupName $ResourceGroupName
$azureNIC = New-AzNetworkInterface -Name $azureNicName `
                                   -ResourceGroupName $ResourceGroupName `
                                   -Location $Location `
                                   -SubnetId $azureVnetSubnet.Id `
                                   -PublicIpAddressId $azurePublicIp.Id `
                                   -NetworkSecurityGroupId $nsg.ID
 
#Store the credentials for the local admin account.
$vmCredential = New-Object System.Management.Automation.PSCredential ($vmAdminUsername, $vmAdminPassword)
 
#Define the parameters for the new virtual machine.
$VirtualMachine = New-AzVMConfig -VMName $azureVmName -VMSize $azureVmSize 
$VirtualMachine = Set-AzVMOperatingSystem -Linux -VM $VirtualMachine  -ComputerName $azureVmName -Credential $vmCredential 
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $azureNIC.Id
$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName $azureVmPublisherName -Offer $azureVmOffer -Skus $azureVmSkus -Version "latest"
$VirtualMachine = Set-AzVMBootDiagnostic -VM $VirtualMachine -Disable
$VirtualMachine = Set-AzVMOSDisk -VM $VirtualMachine -StorageAccountType "Premium_LRS" -Caching ReadWrite -Name $azureVmOsDiskName -CreateOption FromImage

#Create the virtual machine.
New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location  -VM $VirtualMachine 

# Test TCP connection
Test-NetConnection -computer $azurePublicIp.IpAddress -Port 1433

# SA Password was never asked ...
$azurePublicIp.IpAddress
ssh Christophe@52.179.222.36
sudo systemctl stop mssql-server
sudo /opt/mssql/bin/mssql-conf set-sa-password
sudo systemctl start mssql-server

# Exit SSH session
exit

# Test SQL Server connectivity
Import-module dbaTools
$sqlcred = Get-Credential sa
$server = Connect-DbaInstance -SqlInstance 52.179.222.36 -SqlCredential $sqlcred
$server | Invoke-DbaQuery -query "SELECT @@servername,@@version;"
$server | New-DbaDatabase -Name "SQLServerWebinar"
$server | get-dbadatabase | Format-Table


