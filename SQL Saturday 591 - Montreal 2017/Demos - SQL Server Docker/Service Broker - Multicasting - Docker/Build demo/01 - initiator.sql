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
CREATE DATABASE MsCloudSummit2017
GO
ALTER DATABASE [MsCloudSummit2017] SET AUTO_CLOSE OFF WITH NO_WAIT

Use MsCloudSummit2017
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

 
