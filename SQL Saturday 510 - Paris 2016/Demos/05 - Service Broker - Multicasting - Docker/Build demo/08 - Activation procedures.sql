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
 
:connect SQLContainer02
Use MultiplexTarget

ALTER QUEUE TargetQueue
    WITH ACTIVATION
    ( STATUS = ON,
      PROCEDURE_NAME = usp_ProcessRequestSendReply,
      MAX_QUEUE_READERS = 10,
      EXECUTE AS SELF
    );
GO


:connect SQLContainer03
Use MultiplexTarget

ALTER QUEUE TargetQueue
    WITH ACTIVATION
    ( STATUS = ON,
      PROCEDURE_NAME = usp_ProcessRequestSendReply,
      MAX_QUEUE_READERS = 10,
      EXECUTE AS SELF
    );
GO




:connect SQLNODE01
Use MultiplexInitiator

ALTER QUEUE InitiatorQueue
    WITH ACTIVATION
    ( STATUS = ON,
      PROCEDURE_NAME = usp_ReceiveReplyEnDialog,
      MAX_QUEUE_READERS = 10,
      EXECUTE AS SELF
    );
GO

