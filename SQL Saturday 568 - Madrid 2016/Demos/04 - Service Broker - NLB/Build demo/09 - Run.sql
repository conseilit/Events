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
use InitiatorDB
exec usp_SendRequestToTarget



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



/*


:connect SQLNODE01
use InitiatorDB
DELETE from LogActivity
GO

:connect SQLNODE02
Use TargetDB
delete  from TargetTable
go


:connect SQLNODE03
Use TargetDB
delete  from TargetTable
go

*/






:connect SQLNODE02
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
select * from sys.conversation_endpoints

:connect SQLNODE01
Use InitiatorDB
select * from sys.conversation_endpoints


:connect SQLNODE02
Use TargetDB
exec usp_ReceiveEndDialog_CloseConversation
select * from sys.conversation_endpoints




:connect SQLNODE01
Use InitiatorDB
select * from InitiatorQueue


:connect SQLNODE02
Use TargetDB
select * from targetqueue
