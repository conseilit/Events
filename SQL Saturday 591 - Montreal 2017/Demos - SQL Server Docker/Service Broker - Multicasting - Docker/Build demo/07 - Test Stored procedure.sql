/*============================================================================
  File:     
  Summary:  MsCloudSummit 2017 - Paris
  Date:     01/2017
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
============================================================================*/
 
-- step 1
:CONNECT tcp:192.168.1.136,1433 -Usa -PPassword1!
use MsCloudSummit2017
exec usp_SendRequestToMultipleTarget


-- Step 2
:CONNECT tcp:192.168.1.136,40002 -Usa -PPassword1!
Use MsCloudSummit2017
exec usp_ProcessRequestSendReply
GO
:CONNECT tcp:192.168.1.136,40003 -Usa -PPassword1!
Use MsCloudSummit2017
exec usp_ProcessRequestSendReply
GO


-- Step 3
:CONNECT tcp:192.168.1.136,1433 -Usa -PPassword1!
use MsCloudSummit2017
exec usp_ReceiveReplyEnDialog

-- Step 4
:CONNECT tcp:192.168.1.136,40002 -Usa -PPassword1!
Use MsCloudSummit2017
exec usp_ReceiveEndDialog_CloseConversation
GO
:CONNECT tcp:192.168.1.136,40003 -Usa -PPassword1!
Use MsCloudSummit2017
exec usp_ReceiveEndDialog_CloseConversation
GO


-- view data
:CONNECT tcp:192.168.1.136,1433 -Usa -PPassword1!
Use MsCloudSummit2017
select * from LogActivity
go

:CONNECT tcp:192.168.1.136,40002 -Usa -PPassword1!
Use MsCloudSummit2017
select * from TargetTable
go


:CONNECT tcp:192.168.1.136,40003 -Usa -PPassword1!
Use MsCloudSummit2017
select * from TargetTable
go









:CONNECT tcp:192.168.1.136,1433 -Usa -PPassword1!
use MsCloudSummit2017
exec usp_SendRequestToMultipleTarget
select * from LogActivity
GO




:CONNECT tcp:192.168.1.136,40002 -Usa -PPassword1!
Use MsCloudSummit2017
select * from TargetTable
go


:CONNECT tcp:192.168.1.136,40003 -Usa -PPassword1!
Use MsCloudSummit2017
select * from TargetTable
go


:CONNECT tcp:192.168.1.136,1433 -Usa -PPassword1!
use MsCloudSummit2017
exec usp_SendRequestToMultipleTarget
select * from LogActivity
GO


:CONNECT tcp:192.168.1.136,1433 -Usa -PPassword1!
use MsCloudSummit2017
select * from initiatorqueue
select * from LogActivity
select * from sys.transmission_queue 
select * from sys.conversation_endpoints
select * from sys.dm_broker_activated_tasks 
select * from sys.dm_broker_connections 
select * from sys.dm_broker_forwarded_messages 
select * from sys.dm_broker_queue_monitors 
select * from sys.conversation_groups 
select * from sys.remote_service_bindings
select * from sys.routes
select * from sys.service_contracts
select * from sys.service_contract_message_usages
select * from sys.service_contract_usages
select * from sys.service_message_types
select * from sys.services
GO

:CONNECT tcp:192.168.1.136,40002 -Usa -PPassword1!
Use MsCloudSummit2017
select * from targetqueue
GO

:CONNECT tcp:192.168.1.136,40003 -Usa -PPassword1!
Use MsCloudSummit2017
select * from targetqueue
GO




:CONNECT tcp:192.168.1.136,40002 -Usa -PPassword1!
Use MsCloudSummit2017
--select * from TargetTable
--select * from sys.conversation_endpoints
--select * from targetqueue
exec usp_ProcessRequestSendReply
select * from TargetTable
--select * from sys.conversation_endpoints
--select * from targetqueue


:CONNECT tcp:192.168.1.136,40003 -Usa -PPassword1!
Use MsCloudSummit2017
--select * from TargetTable
--select * from sys.conversation_endpoints
--select * from targetqueue
exec usp_ProcessRequestSendReply
select * from TargetTable
--select * from sys.conversation_endpoints
--select * from targetqueue


:CONNECT tcp:192.168.1.136,1433 -Usa -PPassword1!
use MsCloudSummit2017
--select * from LogActivity
--select * from sys.conversation_endpoints
--select * from InitiatorQueue
exec usp_ReceiveReplyEnDialog
select * from LogActivity



:CONNECT tcp:192.168.1.136,40002 -Usa -PPassword1!
Use MsCloudSummit2017
--select * from TargetTable
--select * from sys.conversation_endpoints
--select * from targetqueue
exec usp_ReceiveEndDialog_CloseConversation
select * from TargetTable
--select * from sys.conversation_endpoints
--select * from targetqueue



:CONNECT tcp:192.168.1.136,40002 -Usa -PPassword1!
Use MsCloudSummit2017
select * from TargetTable
go


:CONNECT tcp:192.168.1.136,40003 -Usa -PPassword1!
Use MsCloudSummit2017
select * from TargetTable
go


/*


:CONNECT tcp:192.168.1.136,1433 -Usa -PPassword1!
use MsCloudSummit2017
DELETE from LogActivity
GO

:CONNECT tcp:192.168.1.136,40002 -Usa -PPassword1!
Use MsCloudSummit2017
delete from TargetTable
go


:CONNECT tcp:192.168.1.136,40003 -Usa -PPassword1!
Use MsCloudSummit2017
delete from TargetTable
go

*/