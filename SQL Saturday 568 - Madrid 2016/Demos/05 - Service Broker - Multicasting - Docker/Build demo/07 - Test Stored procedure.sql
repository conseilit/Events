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
use MultiplexInitiator
exec usp_SendRequestToMultipleTarget


-- Step 2
:connect SQLContainer02
Use MultiplexTarget
exec usp_ProcessRequestSendReply
GO
:connect SQLContainer03
Use MultiplexTarget
exec usp_ProcessRequestSendReply
GO


-- Step 3
:connect SQLNODE01
use MultiplexInitiator
exec usp_ReceiveReplyEnDialog

-- Step 4
:connect SQLContainer02
Use MultiplexTarget
exec usp_ReceiveEndDialog_CloseConversation
GO
:connect SQLContainer03
Use MultiplexTarget
exec usp_ReceiveEndDialog_CloseConversation
GO


-- view data
:connect SQLNODE01
Use MultiplexInitiator
select * from LogActivity
go

:connect SQLContainer02
Use MultiplexTarget
select * from TargetTable
go


:connect SQLContainer03
Use MultiplexTarget
select * from TargetTable
go









:connect SQLNODE01
use MultiplexInitiator
exec usp_SendRequestToMultipleTarget
select * from LogActivity
GO




:connect SQLContainer02
Use MultiplexTarget
select * from TargetTable
go


:connect SQLContainer03
Use MultiplexTarget
select * from TargetTable
go


:connect SQLNODE01
use MultiplexInitiator
exec usp_SendRequestToMultipleTarget
select * from LogActivity
GO


:connect SQLNODE01
use MultiplexInitiator
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

:connect SQLContainer02
Use MultiplexTarget
select * from targetqueue
GO

:connect SQLContainer03
Use MultiplexTarget
select * from targetqueue
GO




:connect SQLContainer02
Use MultiplexTarget
--select * from TargetTable
--select * from sys.conversation_endpoints
--select * from targetqueue
exec usp_ProcessRequestSendReply
select * from TargetTable
--select * from sys.conversation_endpoints
--select * from targetqueue


:connect SQLContainer03
Use MultiplexTarget
--select * from TargetTable
--select * from sys.conversation_endpoints
--select * from targetqueue
exec usp_ProcessRequestSendReply
select * from TargetTable
--select * from sys.conversation_endpoints
--select * from targetqueue


:connect SQLNODE01
use MultiplexInitiator
--select * from LogActivity
--select * from sys.conversation_endpoints
--select * from InitiatorQueue
exec usp_ReceiveReplyEnDialog
select * from LogActivity



:connect SQLContainer02
Use MultiplexTarget
--select * from TargetTable
--select * from sys.conversation_endpoints
--select * from targetqueue
exec usp_ReceiveEndDialog_CloseConversation
select * from TargetTable
--select * from sys.conversation_endpoints
--select * from targetqueue



:connect SQLContainer02
Use MultiplexTarget
select * from TargetTable
go


:connect SQLContainer03
Use MultiplexTarget
select * from TargetTable
go


/*


:connect SQLNODE01
use MultiplexInitiator
DELETE from LogActivity
GO

:connect SQLContainer02
Use MultiplexTarget
delete from TargetTable
go


:connect SQLContainer03
Use MultiplexTarget
delete from TargetTable
go

*/