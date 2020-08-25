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
 
:CONNECT tcp:192.168.1.136,1433 -Usa -PPassword1!
use MsCloudSummit2017
exec usp_SendRequestToMultipleTarget



-- view data
:CONNECT tcp:192.168.1.136,1433 -Usa -PPassword1!
Use MsCloudSummit2017
select * from LogActivity
GO

:CONNECT tcp:192.168.1.136,40001 -Usa -PPassword1!
Use MsCloudSummit2017
select * from TargetTable
GO
:CONNECT tcp:192.168.1.136,40002 -Usa -PPassword1!
Use MsCloudSummit2017
select * from TargetTable
GO
:CONNECT tcp:192.168.1.136,40003 -Usa -PPassword1!
Use MsCloudSummit2017
select * from TargetTable
GO
:CONNECT tcp:192.168.1.136,40004 -Usa -PPassword1!
Use MsCloudSummit2017
select * from TargetTable
GO
:CONNECT tcp:192.168.1.136,40005 -Usa -PPassword1!
Use MsCloudSummit2017
select * from TargetTable
GO













/*


:CONNECT tcp:192.168.1.136,1433 -Usa -PPassword1!
use MsCloudSummit2017
DELETE from LogActivity
GO

:CONNECT tcp:192.168.1.136,40002 -Usa -PPassword1!
Use MsCloudSummit2017
delete  from TargetTable
go


:CONNECT tcp:192.168.1.136,40003 -Usa -PPassword1!
Use MsCloudSummit2017
delete  from TargetTable
go

*/






:CONNECT tcp:192.168.1.136,40002 -Usa -PPassword1!
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
select * from sys.conversation_endpoints

:CONNECT tcp:192.168.1.136,1433 -Usa -PPassword1!
Use MsCloudSummit2017
select * from sys.conversation_endpoints


:CONNECT tcp:192.168.1.136,40002 -Usa -PPassword1!
Use MsCloudSummit2017
exec usp_ReceiveEndDialog_CloseConversation
select * from sys.conversation_endpoints




:CONNECT tcp:192.168.1.136,1433 -Usa -PPassword1!
Use MsCloudSummit2017
select * from InitiatorQueue


:CONNECT tcp:192.168.1.136,40002 -Usa -PPassword1!
Use MsCloudSummit2017
select * from targetqueue
