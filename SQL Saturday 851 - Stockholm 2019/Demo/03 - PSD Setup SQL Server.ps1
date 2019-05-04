#==============================================================================
#
#  Summary:  A simple PowerShell direct command to setup SQL Server inside the VM
#  Date:     SQLSaturday Stockholm #851 - 05/2019
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

$VmName   = "SQLSat851"
$Username = 'Administrator'
$Password = 'Password1'
$SQLServerISO  = "C:\Sources\en_sql_server_2017_developer_x64_dvd_11296168.iso"	

# attach iso to VM
Set-VMDvdDrive -VMName $VmName -Path $SQLServerISO

function SetupSQL() 
{ 
    

		$HostName = Hostname
		D:\Setup.exe /ACTION=Install /FEATURES=SQLEngine,Replication,IS,Conn,FullText  `
					/INSTANCENAME=MSSQLSERVER `
					/SQLSVCACCOUNT="NT Service\MSSQLServer" `
					/AGTSVCACCOUNT="NT Service\SQLServerAgent" `
					/FTSVCACCOUNT="NT Service\MSSQLFDLauncher" `
					/ISSVCACCOUNT="NT Service\MsDtsServer140" `
                    /AGTSVCSTARTUPTYPE="Automatic" `
					/TCPENABLED="1" `
                    /FILESTREAMLEVEL="3" `
                    /FILESTREAMSHARENAME="MSSQLSERVER" `
					/UpdateEnabled=FALSE `
					/SECURITYMODE=SQL /SAPWD="Password1" /SQLSYSADMINACCOUNTS="$Hostname\Administrator" `
                    /INSTALLSQLDATADIR="G:" `
                    /SQLBACKUPDIR="G:\MSSQLServer\Backup" `
					/SQLUSERDBDIR="G:\MSSQLServer\Data" `
					/SQLUSERDBLOGDIR="F:\MSSQLServer\Log" `
					/SQLTEMPDBDIR="E:\MSSQLServer\Data" `
					/SQLTEMPDBLOGDIR="H:\MSSQLServer\Log" `
					/SQLTEMPDBFILECOUNT=4  `
					/SQLTEMPDBFILESIZE=256 `
					/SQLTEMPDBFILEGROWTH=64 `
					/SQLTEMPDBLOGFILESIZE=256 `
					/SQLTEMPDBLOGFILEGROWTH=256 `
					/SQLSVCINSTANTFILEINIT=TRUE `
					/HELP="False" /INDICATEPROGRESS="False" /QUIET="True" /QUIETSIMPLE="False" `
					/X86="False" /ENU="True" /ERRORREPORTING="False" /SQMREPORTING="False" `
					/IACCEPTSQLSERVERLICENSETERMS 
}


function RestartComputer () 
{
    write-host "Rebooting computer now ..." -ForegroundColor Red
    Restart-Computer -Force
}


$FunctionDefs = "function SetupSQL { ${function:SetupSQL} }; function RestartComputer { ${function:RestartComputer}} "


$pass = ConvertTo-SecureString -AsPlainText $Password -Force
$Cred = New-Object System.Management.Automation.PSCredential -ArgumentList $Username,$pass



Invoke-Command -Credential $Cred -VMName $VmName { 

        . ([ScriptBlock]::Create($Using:FunctionDefs))

        SetupSQL 
        
        RestartComputer
}

