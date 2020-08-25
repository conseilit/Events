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


:connect SQLContainer01..5
CREATE DATABASE MultiplexTarget
GO
ALTER DATABASE [MultiplexTarget] SET AUTO_CLOSE OFF WITH NO_WAIT
GO

USE MultiplexTarget
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
 

 
 
 
 -- 1 target service par target
USE MultiplexTarget
GO
Create Service TargetServiceSQL01 ON QUEUE TargetQueue (SampleContract)
USE MultiplexTarget
GO 
Create Service TargetServiceSQL02 ON QUEUE TargetQueue (SampleContract)
USE MultiplexTarget
GO
 Create Service TargetServiceSQL03 ON QUEUE TargetQueue (SampleContract)
USE MultiplexTarget
GO
 Create Service TargetServiceSQL04 ON QUEUE TargetQueue (SampleContract)
USE MultiplexTarget
GO
 Create Service TargetServiceSQL05 ON QUEUE TargetQueue (SampleContract)