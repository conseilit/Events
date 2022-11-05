#==============================================================================
#
#  Summary:  Setup SQL for DPS2022 demos
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

# Scripts based on dbaTools commands
# Thanks to Chrissy LeMaire (@cl | https://blog.netnerds.net/ )
#         , Rob Sewell (@SQLDBAWithBeard | https://sqldbawithabeard.com/)
#         , and all SQL Server community
# http://dbatools.io
# Install-Module dbatools 

Clear-Host

$InstanceName = "DPS2022"

# my super secure sa password for demos
$Username = 'sa'
$Password = 'Password1!'
$pass = ConvertTo-SecureString -AsPlainText $Password -Force
$saCred = New-Object System.Management.Automation.PSCredential -ArgumentList $Username,$pass

# the credential used to install SQL Server on the remote computers
$CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$InstallCred = Get-Credential -Message "Enter current user and password to connect remote computer" -UserName $CurrentUser

# some configuration stuffs
$config = @{
    AGTSVCSTARTUPTYPE = "Automatic"
    SQLCOLLATION = "Latin1_General_CI_AS"
    BROWSERSVCSTARTUPTYPE = "Manual"
    FILESTREAMLEVEL = 1
    INSTALLSQLDATADIR="D:" 
    SQLBACKUPDIR="D:\MSSQL15.MSSQLSERVER\Backup" 
    SQLUSERDBDIR="D:\MSSQL15.MSSQLSERVER\MSSQL\Data" 
    SQLUSERDBLOGDIR="L:\MSSQL15.MSSQLSERVER\Log" 
    SQLTEMPDBDIR="D:\MSSQL15.MSSQLSERVER\Data" 
    SQLTEMPDBLOGDIR="L:\MSSQL15.MSSQLSERVER\Log" 
}

# Perform the installation
Install-DbaInstance -SqlInstance $InstanceName `
                    -Credential $InstallCred `
                    -Version 2019 `
                    -Feature Engine,Replication,FullText,IntegrationServices `
                    -AuthenticationMode Mixed `
                    -AdminAccount $CurrentUser `
                    -SaCredential $saCred `
                    -PerformVolumeMaintenanceTasks `
                    -SaveConfiguration D:\InstallScripts `
                    -Path "\\formation\sources\ISO" `
                    -UpdateSourcePath "\\formation\sources\CU" `
                    -Configuration $config `
                    -Confirm:$false



# check connection to the instance
$Server = Connect-DbaInstance -SqlInstance $InstanceName
#$cred = Get-Credential
#$Server = Connect-DbaInstance -SqlInstance $InstanceName -SqlCredential $cred
$Server | Select-Object DomainInstanceName,VersionMajor,EngineEdition


# List of backup files
$backupPath = "\\Formation\backup\AdventureWorks"
Get-ChildItem -Path $backupPath 

# Restore multiple databases at once - the quickest way
Restore-DbaDatabase -SqlInstance $InstanceName `
                    -Path $backupPath `
                    -UseDestinationDefaultDirectories -WithReplace
 
$backupPath = "\\Formation\backup\performance.bak" 
Restore-DbaDatabase -SqlInstance $InstanceName `
                    -Path $backupPath `
                    -UseDestinationDefaultDirectories -WithReplace

# list databases
Get-dbaDatabase -SqlInstance $InstanceName -ExcludeSystem | format-table -autosize

