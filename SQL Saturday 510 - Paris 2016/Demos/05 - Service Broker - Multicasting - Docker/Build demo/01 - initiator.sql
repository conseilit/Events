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
CREATE DATABASE MultiplexInitiator
GO


Use MultiplexInitiator
GO


Create Message Type RequestMessage validation=WELL_FORMED_XML 
Create Message Type ReplyMessage   validation=WELL_FORMED_XML
GO 

Create Contract SampleContract
(
  RequestMessage     SENT BY INITIATOR,
  ReplyMessage       SENT BY TARGET
)
GO
 
 Create Queue InitiatorQueue WITH status = ON 
 GO

Create Service InitiatorService ON QUEUE InitiatorQueue  (SampleContract)

 
