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
 
:connect SQLNODE01
use MultiplexInitiator
exec usp_SendRequestToMultipleTarget



-- view data
:connect SQLNODE01
Use MultiplexInitiator
select * from LogActivity
go

:connect SQLContainer01..05
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
delete  from TargetTable
go


:connect SQLContainer03
Use MultiplexTarget
delete  from TargetTable
go

*/






:connect SQLContainer02
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
select * from sys.conversation_endpoints

:connect SQLNODE01
Use MultiplexInitiator
select * from sys.conversation_endpoints


:connect SQLContainer02
Use MultiplexTarget
exec usp_ReceiveEndDialog_CloseConversation
select * from sys.conversation_endpoints




:connect SQLNODE01
Use MultiplexInitiator
select * from InitiatorQueue


:connect SQLContainer02
Use MultiplexTarget
select * from targetqueue
