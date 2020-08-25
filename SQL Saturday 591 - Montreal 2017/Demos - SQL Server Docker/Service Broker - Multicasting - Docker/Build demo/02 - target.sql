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


:CONNECT tcp:192.168.1.136,40001 -Usa -PPassword1!
CREATE DATABASE MsCloudSummit2017
GO
ALTER DATABASE [MsCloudSummit2017] SET AUTO_CLOSE OFF WITH NO_WAIT
GO
USE MsCloudSummit2017
GO
Create Message Type RequestMessage validation=WELL_FORMED_XML;
Create Message Type ReplyMessage   validation=WELL_FORMED_XML;
GO
Create Contract SampleContract
(
  RequestMessage     SENT BY INITIATOR,
  ReplyMessage       SENT BY TARGET
)
GO
Create Queue TargetQueue WITH status= ON
GO
Create Service TargetServiceSQL01 ON QUEUE TargetQueue (SampleContract)
GO



:CONNECT tcp:192.168.1.136,40002 -Usa -PPassword1!
CREATE DATABASE MsCloudSummit2017
GO
ALTER DATABASE [MsCloudSummit2017] SET AUTO_CLOSE OFF WITH NO_WAIT
GO
USE MsCloudSummit2017
GO
Create Message Type RequestMessage validation=WELL_FORMED_XML;
Create Message Type ReplyMessage   validation=WELL_FORMED_XML;
GO
Create Contract SampleContract
(
  RequestMessage     SENT BY INITIATOR,
  ReplyMessage       SENT BY TARGET
)
GO
Create Queue TargetQueue WITH status= ON
GO
Create Service TargetServiceSQL02 ON QUEUE TargetQueue (SampleContract)
GO

:CONNECT tcp:192.168.1.136,40003 -Usa -PPassword1!
CREATE DATABASE MsCloudSummit2017
GO
ALTER DATABASE [MsCloudSummit2017] SET AUTO_CLOSE OFF WITH NO_WAIT
GO
USE MsCloudSummit2017
GO
Create Message Type RequestMessage validation=WELL_FORMED_XML;
Create Message Type ReplyMessage   validation=WELL_FORMED_XML;
GO
Create Contract SampleContract
(
  RequestMessage     SENT BY INITIATOR,
  ReplyMessage       SENT BY TARGET
)
GO
Create Queue TargetQueue WITH status= ON
GO
Create Service TargetServiceSQL03 ON QUEUE TargetQueue (SampleContract)
GO

:CONNECT tcp:192.168.1.136,40004 -Usa -PPassword1!
CREATE DATABASE MsCloudSummit2017
GO
ALTER DATABASE [MsCloudSummit2017] SET AUTO_CLOSE OFF WITH NO_WAIT
GO
USE MsCloudSummit2017
GO
Create Message Type RequestMessage validation=WELL_FORMED_XML;
Create Message Type ReplyMessage   validation=WELL_FORMED_XML;
GO
Create Contract SampleContract
(
  RequestMessage     SENT BY INITIATOR,
  ReplyMessage       SENT BY TARGET
)
GO
Create Queue TargetQueue WITH status= ON
GO
Create Service TargetServiceSQL04 ON QUEUE TargetQueue (SampleContract)
GO


:CONNECT tcp:192.168.1.136,40005 -Usa -PPassword1!
CREATE DATABASE MsCloudSummit2017
GO
ALTER DATABASE [MsCloudSummit2017] SET AUTO_CLOSE OFF WITH NO_WAIT
GO
USE MsCloudSummit2017
GO
Create Message Type RequestMessage validation=WELL_FORMED_XML;
Create Message Type ReplyMessage   validation=WELL_FORMED_XML;
GO
Create Contract SampleContract
(
  RequestMessage     SENT BY INITIATOR,
  ReplyMessage       SENT BY TARGET
)
GO
Create Queue TargetQueue WITH status= ON
GO
Create Service TargetServiceSQL05 ON QUEUE TargetQueue (SampleContract)
GO

