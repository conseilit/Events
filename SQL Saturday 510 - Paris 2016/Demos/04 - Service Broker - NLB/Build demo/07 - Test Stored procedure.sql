/*============================================================================
  File:     
  Summary:  SQL Saturday 510 - Paris
  Date:     06/2016
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
:connect SQLNODE01
use InitiatorDB
exec usp_SendRequestToTarget


-- Step 2
:connect SQLNODE02
Use TargetDB
exec usp_ProcessRequestSendReply
GO
:connect SQLNODE03
Use TargetDB
exec usp_ProcessRequestSendReply
GO


-- Step 3
:connect SQLNODE01
use InitiatorDB
exec usp_ReceiveReplyEnDialog

-- Step 4
:connect SQLNODE02
Use TargetDB
exec usp_ReceiveEndDialog_CloseConversation
GO
:connect SQLNODE03
Use TargetDB
exec usp_ReceiveEndDialog_CloseConversation
GO


-- view data
:connect SQLNODE01
Use InitiatorDB
select * from LogActivity
go

:connect SQLNODE02
Use TargetDB
select * from TargetTable
go


:connect SQLNODE03
Use TargetDB
select * from TargetTable
go









:connect SQLNODE01
use InitiatorDB
exec usp_SendRequestToTarget
select * from LogActivity
GO




:connect SQLNODE02
Use TargetDB
select * from TargetTable
go


:connect SQLNODE03
Use TargetDB
select * from TargetTable
go


:connect SQLNODE01
use InitiatorDB
exec usp_SendRequestToTarget
select * from LogActivity
GO


:connect SQLNODE01
use InitiatorDB
select * from initiatorqueue
select * from LogActivity
select * from sys.conversation_endpoints
select * from sys.dm_broker_activated_tasks 
select * from sys.dm_broker_connections 
select * from sys.dm_broker_forwarded_messages 
select * from sys.dm_broker_queue_monitors 
select * from sys.transmission_queue 
select * from sys.transmission_queue 
select * from sys.conversation_endpoints 
select * from sys.conversation_groups 
select * from sys.conversation_endpoints
select * from sys.remote_service_bindings
select * from sys.routes
select * from sys.service_contracts
select * from sys.service_contract_message_usages
select * from sys.service_contract_usages
select * from sys.service_message_types
select * from sys.services
GO

:connect SQLNODE02
Use TargetDB
select * from targetqueue
GO

:connect SQLNODE03
Use TargetDB
select * from targetqueue
GO




:connect SQLNODE02
Use TargetDB
--select * from TargetTable
--select * from sys.conversation_endpoints
--select * from targetqueue
exec usp_ProcessRequestSendReply
select * from TargetTable
--select * from sys.conversation_endpoints
--select * from targetqueue


:connect SQLNODE03
Use TargetDB
--select * from TargetTable
--select * from sys.conversation_endpoints
--select * from targetqueue
exec usp_ProcessRequestSendReply
select * from TargetTable
--select * from sys.conversation_endpoints
--select * from targetqueue


:connect SQLNODE01
use InitiatorDB
--select * from LogActivity
--select * from sys.conversation_endpoints
--select * from InitiatorQueue
exec usp_ReceiveReplyEnDialog
select * from LogActivity



:connect SQLNODE02
Use TargetDB
--select * from TargetTable
--select * from sys.conversation_endpoints
--select * from targetqueue
exec usp_ReceiveEndDialog_CloseConversation
select * from TargetTable
--select * from sys.conversation_endpoints
--select * from targetqueue



:connect SQLNODE02
Use TargetDB
select * from TargetTable
go


:connect SQLNODE03
Use TargetDB
select * from TargetTable
go


/*


:connect SQLNODE01
use InitiatorDB
DELETE from LogActivity
GO

:connect SQLNODE02
Use TargetDB
delete from TargetTable
go


:connect SQLNODE03
Use TargetDB
delete from TargetTable
go

*/