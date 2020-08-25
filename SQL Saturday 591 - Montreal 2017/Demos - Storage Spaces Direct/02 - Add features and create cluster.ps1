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


Invoke-Command -Credential $Cred -VMName SRV1 { 
        
    # Add Features
    Install-WindowsFeature -Name Failover-Clustering,File-Services -IncludeAllSubFeature -IncludeManagementTools -ComputerName srv1
    Install-WindowsFeature -Name Failover-Clustering,File-Services -IncludeAllSubFeature -IncludeManagementTools -ComputerName srv2

    # Test cluster, else SQL Server won't install
    Test-Cluster –Node srv1,srv2 –Include "Storage Spaces Direct", "Inventory", "Network", "System Configuration"

    # Create the Cluster and add a File Share Witness
    New-Cluster -Name ClustS2D -Node srv1,srv2 -NoStorage -StaticAddress 10.0.0.10
    Start-Sleep -s 2
    Get-Cluster  | Set-ClusterQuorum -FileShareWitness "\\AD\FSW"

}

