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


$ProjectName = "webinar-sqlserver"
$ResourceGroupName = $ProjectName + "-rg"
$Location = "EastUS2"
$VirtualNetworkName = $ProjectName + "-vnet"
$VnetDefaultName = "default"
$StorageAccountName = $ProjectName + "-sto"
$NetworkSecurityGroupName = $ProjectName + "-nsg"


#region Login
    Import-Module AZ
    Get-AzEnvironment
    Connect-AzAccount -Environment AzureCloud

    Get-AzSubscription

    Select-AzSubscription -SubscriptionName "Microsoft Azure Sponsorship"
#endregion

#region Resource Group
    Get-AzResourceGroup | Format-Table
    Get-AzResource -ResourceGroupName $ResourceGroupName | Format-Table

    $ResourceGroup = New-AzResourceGroup -Name $ResourceGroupName -Location $Location
    $ResourceGroup
#endregion

#region vNet

    $virtualNetwork = New-AzVirtualNetwork `
    -ResourceGroupName $ResourceGroupName `
    -Location $Location `
    -Name $VirtualNetworkName `
    -AddressPrefix 10.1.0.0/16

    $VnetDefault = Add-AzVirtualNetworkSubnetConfig `
                        -Name $VnetDefaultName  `
                        -AddressPrefix 10.1.1.0/24 `
                        -VirtualNetwork $virtualNetwork

    $virtualNetwork | Set-AzVirtualNetwork

    # Create a network security group
    $rule1 = New-AzNetworkSecurityRuleConfig -Name ssh-rule -Description "Allow SSH" `
        -Access Allow -Protocol Tcp -Direction Inbound -Priority 101 -SourceAddressPrefix `
        Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 22

    $rule2 = New-AzNetworkSecurityRuleConfig -Name http-rule -Description "Allow HTTP" `
        -Access Allow -Protocol Tcp -Direction Inbound -Priority 102 -SourceAddressPrefix `
        Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 80

    $rule3 = New-AzNetworkSecurityRuleConfig -Name https-rule -Description "Allow HTTPS" `
        -Access Allow -Protocol Tcp -Direction Inbound -Priority 103 -SourceAddressPrefix `
        Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 443

    $rule4 = New-AzNetworkSecurityRuleConfig -Name sql-rule -Description "Allow SQL Server" `
        -Access Allow -Protocol Tcp -Direction Inbound -Priority 104 -SourceAddressPrefix `
        Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 1433

    $rule5 = New-AzNetworkSecurityRuleConfig -Name rdp-rule -Description "Allow RDP" `
        -Access Allow -Protocol Tcp -Direction Inbound -Priority 105 -SourceAddressPrefix `
        Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389

    $nsg = New-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName -Location $Location `
        -Name $NetworkSecurityGroupName -SecurityRules $rule1,$rule2,$rule3,$rule4,$rule5

#endregion

#region Linux VM for SQL Server

    #Define the following parameters for the virtual machine.
    $vmAdminUsername = "Christophe"
    $vmAdminPassword = ConvertTo-SecureString "Password1!" -AsPlainText -Force
    
    #Define the following parameters for the Azure resources.
    $azureVmName                = "lxSQL-vm"
    $azureVmOsDiskName          = $azureVmName + "-OS"
    $azureVmSize                = "Standard_B4ms"
    
    #Define the networking information.
    $azureNicName               = $azureVmName + "-nic"
    $azurePublicIpName          = $azureVmName + "-ip"
    
    
    #Define the VM marketplace image details.
    $azureVmPublisherName = "Canonical"
    $azureVmOffer = "UbuntuServer"
    $azureVmSkus = "18.04-LTS"
    
    #Create the public IP address.
    $azurePublicIp = New-AzPublicIpAddress -Name $azurePublicIpName `
                                        -ResourceGroupName $ResourceGroupName `
                                        -Location $Location -AllocationMethod Static -Sku Standard
    
    #Create the NIC and associate the public IpAddress.
    $azureVnetSubnet = (Get-AzVirtualNetwork -Name $virtualnetworkName -ResourceGroupName $ResourceGroupName).Subnets | Where-Object {$_.Name -eq $VnetDefaultName}

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

    
#endregion


#region Linux VM with Docker

    #Define the following parameters for the virtual machine.
    $vmAdminUsername = "Christophe"
    $vmAdminPassword = ConvertTo-SecureString "Password1!" -AsPlainText -Force
    
    #Define the following parameters for the Azure resources.
    $azureVmName                = "lxDocker-vm"
    $azureVmOsDiskName          = $azureVmName + "-OS"
    $azureVmSize                = "Standard_B4ms"
    
    #Define the networking information.
    $azureNicName               = $azureVmName + "-nic"
    $azurePublicIpName          = $azureVmName + "-ip"
    
    
    #Define the VM marketplace image details.
    $azureVmPublisherName = "Canonical"
    $azureVmOffer = "UbuntuServer"
    $azureVmSkus = "18.04-LTS"
    
    #Create the public IP address.
    $azurePublicIp = New-AzPublicIpAddress -Name $azurePublicIpName `
                                        -ResourceGroupName $ResourceGroupName `
                                        -Location $Location -AllocationMethod Static -Sku Standard
    
    #Create the NIC and associate the public IpAddress.
    $azureVnetSubnet = (Get-AzVirtualNetwork -Name $virtualnetworkName -ResourceGroupName $ResourceGroupName).Subnets | Where-Object {$_.Name -eq $VnetDefaultName}

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


    # Install Docker
    $azurePublicIp.IpAddress
    ssh Christophe@52.247.16.158
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update
    apt-cache policy docker-ce
    sudo apt-get install -y docker-ce

    echo manual | sudo tee /etc/init/docker.override
    sudo systemctl enable docker

    sudo docker ps -a
    sudo docker images

    sudo docker pull mcr.microsoft.com/mssql/server:2019-latest

    sudo mkdir /mssql
    sudo chmod 777 /mssql
    
#endregion

#region Azure Container Instance
#endregion

#region Azure Kubernetes Service

    # list currently supproted K8s version 
    az aks get-versions --location eastus --output table

    # create the cluster
    az aks create --name k8s-cluster \
    --resource-group webinar-sqlserver-rg \
    --generate-ssh-keys \
    --node-vm-size Standard_B8ms \
    --node-count 3 \
    --kubernetes-version 1.16.7 



    # add K8s credentials
    az aks get-credentials --overwrite-existing --name k8s-cluster --resource-group=webinar-sqlserver-rg 
    az aks get-credentials --overwrite-existing --name k8s-cluster --resource-group=webinar-sqlserver-rg --admin



    # Kubernetes command survival kit
    kubectl get nodes -o wide
    kubectl get pods -o wide --all-namespaces
    kubectl get services -o wide --all-namespaces

    # Create BDC
    azdata bdc create --accept-eula=yes

#endregion

#region SQLAzure

    $Location1 = "eastus2"
    $Location2 = "westus2"
    $serverName1 = "eus-webinar-sqlserver-sql"
    $serverName2 = "wus-webinar-sqlserver-sql"


    $adminSqlLogin = "Christophe"
    $password = "Password1!"

    # Create servers with a system wide unique server name
    $server1 = New-AzSqlServer -ResourceGroupName $resourceGroupName `
        -ServerName $serverName1 `
        -Location $Location1 `
        -SqlAdministratorCredentials $(New-Object -TypeName System.Management.Automation.PSCredential `
                                                -ArgumentList $adminSqlLogin,`
                                                $(ConvertTo-SecureString -String $password -AsPlainText -Force))

    $server2 = New-AzSqlServer -ResourceGroupName $resourceGroupName `
        -ServerName $serverName2 `
        -Location $Location2 `
        -SqlAdministratorCredentials $(New-Object -TypeName System.Management.Automation.PSCredential `
                                                -ArgumentList $adminSqlLogin,`
                                                $(ConvertTo-SecureString -String $password -AsPlainText -Force))

    # Create a server firewall rule that allows access from the specified IP range
    $startIp = "0.0.0.0"
    $endIp = "0.0.0.0"
    $serverFirewallRule1 = New-AzSqlServerFirewallRule -ResourceGroupName $resourceGroupName `
                                                    -ServerName $serverName1 `
                                                    -FirewallRuleName "AllowedIPs" `
                                                    -StartIpAddress $startIp `
                                                    -EndIpAddress $endIp

    $serverFirewallRule2 = New-AzSqlServerFirewallRule -ResourceGroupName $resourceGroupName `
                                                    -ServerName $serverName2 `
                                                    -FirewallRuleName "AllowedIPs" `
                                                    -StartIpAddress $startIp `
                                                    -EndIpAddress $endIp

    #region Server1

        $PoolName = "Pool1"

        $ElasticPool = New-AzSqlElasticPool -ResourceGroupName $resourceGroupName `
            -ServerName $serverName1 `
            -ElasticPoolName $PoolName `
            -Edition "Standard" `
            -Dtu 50 `
            -DatabaseDtuMin 10 `
            -DatabaseDtuMax 20


    #endregion

    #region Server 2

        $PoolName = "Pool1"

        New-AzSqlElasticPool -ResourceGroupName $resourceGroupName `
                            -ServerName $serverName2 `
                            -ElasticPoolName $PoolName `
                            -Edition "Standard" `
                            -Dtu 50 `
                            -DatabaseDtuMin 10 `
                            -DatabaseDtuMax 20

    #endregion

    Get-AzSqlElasticPool -ResourceGroupName $resourceGroupName -ServerName $serverName1 
    Get-AzSqlElasticPool -ResourceGroupName $resourceGroupName -ServerName $serverName2 
#endregion

