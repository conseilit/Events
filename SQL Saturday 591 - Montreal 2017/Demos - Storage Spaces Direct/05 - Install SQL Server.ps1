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
 
 


function CreateSQLCluster() 
{ 
    

		$HostName = Hostname
		D:\Setup.exe /ACTION="InstallFailoverCluster" `
                    /FEATURES=SQLENGINE,REPLICATION,FULLTEXT,DQ,CONN `
                    /INSTANCENAME="SQL01" `
                    /INSTANCEID="SQL01" `
                    /INSTALLSQLDATADIR="C:\ClusterStorage\Volume1" `
                    /FAILOVERCLUSTERDISKS="Cluster Virtual Disk (SQLServer)" `
                    /FAILOVERCLUSTERGROUP="SQL Server (SQL01)" `
                    /FAILOVERCLUSTERIPADDRESSES="IPv4;10.0.0.20;Cluster Network 1;255.0.0.0" `
                    /FAILOVERCLUSTERNETWORKNAME="vSQL01" `
                    /SQLSVCACCOUNT="demo\sqlservice" `
                    /SQLSVCPASSWORD="Password1!" `
                    /AGTSVCACCOUNT="demo\sqlservice" `
                    /AGTSVCPASSWORD="Password1!" `
                    /FTSVCACCOUNT="NT Service\MSSQLFDLauncher`$SQL01" `
                    /SQLSYSADMINACCOUNTS="DEMO\administrator" `
                    /SECURITYMODE="SQL" `
                    /SAPWD="Password1!" `
                    /SUPPRESSPRIVACYSTATEMENTNOTICE="True" `
                    /ENU="True" `
                    /QUIET="True" `
                    /QUIETSIMPLE="False" `
                    /UpdateEnabled="False" `
                    /USEMICROSOFTUPDATE="False" `
                    /INSTANCEDIR="C:\Program Files\Microsoft SQL Server" `
                    /UpdateSource="MU" `
                    /HELP="False" `
                    /INDICATEPROGRESS="False" `
                    /X86="False" `
                    /INSTALLSHAREDDIR="C:\Program Files\Microsoft SQL Server" `
                    /INSTALLSHAREDWOWDIR="C:\Program Files (x86)\Microsoft SQL Server" `
                    /COMMFABRICPORT="0" `
                    /COMMFABRICNETWORKLEVEL="0" `
                    /COMMFABRICENCRYPTION="0" `
                    /MATRIXCMBRICKCOMMPORT="0" `
                    /FILESTREAMLEVEL="0" `
                    /SQLCOLLATION="French_CI_AS" `
                    /SQLSVCINSTANTFILEINIT="True" `
                    /SQLTEMPDBFILECOUNT="4" `
                    /SQLTEMPDBFILESIZE="8" `
                    /SQLTEMPDBFILEGROWTH="64" `
                    /SQLTEMPDBLOGFILESIZE="8" `
                    /SQLTEMPDBLOGFILEGROWTH="64" `
					/IACCEPTSQLSERVERLICENSETERMS 
	
	
}

function AddNodeSQLCluster() 
{ 
    

		$HostName = Hostname
		D:\Setup.exe /ACTION="AddNode" `
                    /INSTANCENAME="SQL01" `
                    /FAILOVERCLUSTERGROUP="SQL Server (SQL01)" `
                    /CONFIRMIPDEPENDENCYCHANGE="False" `
                    /FAILOVERCLUSTERIPADDRESSES="IPv4;10.0.0.20;Cluster Network 1;255.0.0.0" `
                    /FAILOVERCLUSTERNETWORKNAME="VSQL01" `
                    /SQLSVCACCOUNT="demo\sqlservice" `
                    /SQLSVCPASSWORD="Password1!" `
                    /AGTSVCACCOUNT="demo\sqlservice" `
                    /AGTSVCPASSWORD="Password1!" `
                    /SUPPRESSPRIVACYSTATEMENTNOTICE="True" `
                    /IACCEPTROPENLICENSETERMS="False" `
                    /ENU="True" `
                    /QUIET="True" `
                    /QUIETSIMPLE="False" `
                    /UpdateEnabled="False" `
                    /USEMICROSOFTUPDATE="False" `
                    /UpdateSource="MU" `
                    /HELP="False" `
                    /INDICATEPROGRESS="False" `
                    /X86="False" `
                    /SQLSVCINSTANTFILEINIT="True" `
                    /FTSVCACCOUNT="NT Service\MSSQLFDLauncher`$SQL01" `
					/IACCEPTSQLSERVERLICENSETERMS 

	
}


$FunctionDefs = "function CreateSQLCluster { ${function:CreateSQLCluster} };function AddNodeSQlCluster { ${function:AddNodeSQlCluster} }"


$Username = 'DEMO\Administrator'
$Password = 'Password1'
$pass = ConvertTo-SecureString -AsPlainText $Password -Force
$Cred = New-Object System.Management.Automation.PSCredential -ArgumentList $Username,$pass



# SQL Server ISO path
$SQLServerISO  = "C:\Sources\en_sql_server_2016_developer_with_service_pack_1_x64_dvd_9548071.iso"	


# attach iso to VM
Set-VMDvdDrive -VMName SRV1 -Path $SQLServerISO
Set-VMDvdDrive -VMName SRV2 -Path $SQLServerISO


Invoke-Command -Credential $Cred -VMName SRV1 { 
    . ([ScriptBlock]::Create($Using:FunctionDefs))

    # Create a new virtual instance
    CreateSQLCluster 
        

}

Invoke-Command -Credential $Cred -VMName SRV2 { 
    . ([ScriptBlock]::Create($Using:FunctionDefs))

    # Add a second node
    AddNodeSQLCluster 

}


