#==============================================================================
#
#  Summary:  DAC and Remote DAC
#  Date:     04/2021
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



# connect the instance
$InstanceName = "DataFrogs"
$Server = Connect-DbaInstance -SqlInstance $InstanceName 

# enable Remote DAC
Set-DbaSpConfigure -SqlInstance $Server -name RemoteDacConnectionsEnabled -value 1

# don't forget to add the corresponding FW rule ....
Enter-PsSession –ComputerName DataFrogs.conseilit.local
New-NetFirewallRule  -DisplayName "SQL Server DAC port 1434"     -Direction Inbound  -Protocol TCP -LocalPort 1434 -Action Allow
Exit-PSSession



# now, let's make something stupid !
$tSQL = "
    CREATE TRIGGER a_stupid_logon_trigger  
    ON ALL SERVER   
    FOR LOGON  
    AS  
    BEGIN  
        ROLLBACK;  
    END;  
"
Invoke-DbaQuery -SqlInstance $Server -Database master -Query $tSQL



<#
    /*
        DROP TRIGGER a_stupid_logon_trigger   
        ON ALL SERVER
    */
#>