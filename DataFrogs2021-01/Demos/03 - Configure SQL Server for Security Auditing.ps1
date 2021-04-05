#==============================================================================
#
#  Summary:  Configure for security auditing
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


# Disable auditing in Errorlog
$Server.AuditLevel = 0
$Server.Alter()

#region audit and audit specification
    $tSQL = "
        CREATE SERVER AUDIT [SecurityAudit]
        TO FILE 
        (	FILEPATH = N'$($Server.ErrorLogPath)'
            ,MAXSIZE = 500 MB
            ,MAX_ROLLOVER_FILES = 20
            ,RESERVE_DISK_SPACE = OFF
        ) WITH (QUEUE_DELAY = 1000, ON_FAILURE = CONTINUE);

        ALTER SERVER AUDIT [SecurityAudit]
        WITH (STATE = ON);
    "
    Invoke-DbaQuery -SqlInstance $Server -Database master -Query $tSQL

    $tSQL = "
        CREATE SERVER AUDIT SPECIFICATION [SecurityAuditSpecifications]
        FOR SERVER AUDIT [SecurityAudit]
            ADD (FAILED_LOGIN_GROUP),
            ADD (FAILED_DATABASE_AUTHENTICATION_GROUP),
            ADD (LOGIN_CHANGE_PASSWORD_GROUP),
            ADD (USER_CHANGE_PASSWORD_GROUP);
            
        ALTER SERVER AUDIT SPECIFICATION [SecurityAuditSpecifications]
        WITH (STATE = ON);
    "
    Invoke-DbaQuery -SqlInstance $Server -Database master -Query $tSQL
#endregion

#region xEvent
    $tSQL = "
    CREATE EVENT SESSION [LoginFailed] ON SERVER 
    ADD EVENT sqlserver.error_reported(
        ACTION(	sqlserver.client_app_name,
                sqlserver.client_hostname,
                sqlserver.client_pid,
                sqlserver.database_id,
                sqlserver.database_name,
                sqlserver.session_id,
                sqlserver.sql_text,
                sqlserver.username)
        WHERE ((([package0].[equal_int64]([severity],(14))) 
            AND ([package0].[equal_int64]([error_number],(18456)))) 
            AND ([package0].[greater_than_int64]([state],(1)))))
    ADD TARGET package0.event_file(SET filename=N'LoginFailed',max_file_size=(25),max_rollover_files=(20))
    WITH (STARTUP_STATE=ON);

    ALTER EVENT SESSION [LoginFailed] ON SERVER 
    STATE = START;
    "
    Invoke-DbaQuery -SqlInstance $Server -Database master -Query $tSQL
#endregion

# connect with a non existing user
Connect-DbaInstance -SqlInstance $InstanceName `
                    -SqlCredential $(New-Object -TypeName System.Management.Automation.PSCredential `
                                                -ArgumentList "NonExistingLogin",`
                                              $(ConvertTo-SecureString -String "SuperSecurePassword!" -AsPlainText -Force))


# connect with a bad password
Connect-DbaInstance -SqlInstance $InstanceName `
                    -SqlCredential $(New-Object -TypeName System.Management.Automation.PSCredential `
                                                -ArgumentList "sa",`
                                              $(ConvertTo-SecureString -String "WrongPassword!" -AsPlainText -Force))

