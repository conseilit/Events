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

Use InitiatorDB

DROP TABLE LogActivity
GO
CREATE TABLE LogActivity
(
	ID int identity(1,1) primary key,
	InitiatorSendDT    datetime2 default SYSDATETIME(),
	InitiatorReceiveDT datetime2 ,
	ConversationHandle UNIQUEIDENTIFIER,
	MessageSent        varchar(100),
	TargetServer       varchar(50)
);
GO



:connect SQLNODE02

Use TargetDB

DROP TABLE TargetTable
CREATE TABLE TargetTable
(
	ID int identity(1,1) primary key,
	MessageReceived      varchar(100),
	ConversationHandle   UNIQUEIDENTIFIER,
	TargetReceiveDT      datetime2 default SYSDATETIME(),
);
GO




:connect SQLNODE03

Use TargetDB

DROP TABLE TargetTable
CREATE TABLE TargetTable
(
	ID int identity(1,1) primary key,
	MessageReceived      varchar(100),
	ConversationHandle   UNIQUEIDENTIFIER,
	TargetReceiveDT      datetime2 default SYSDATETIME(),
);
GO





:connect SQLNODE01

Use InitiatorDB

-- Step 1
IF OBJECT_ID('usp_SendRequestToTarget') IS NOT NULL
BEGIN
	DROP PROCEDURE usp_SendRequestToTarget;
END
GO

CREATE PROCEDURE usp_SendRequestToTarget
AS
BEGIN

	-- Begin a conversation and send a request message
	DECLARE @InitDlgHandle UNIQUEIDENTIFIER;
	DECLARE @RequestMsg NVARCHAR(100);

	BEGIN TRANSACTION;

	BEGIN DIALOG @InitDlgHandle
		 FROM SERVICE InitiatorService
		 TO SERVICE   N'TargetService'
		 ON CONTRACT  SampleContract
		 WITH ENCRYPTION = OFF;

		SELECT @RequestMsg =
			   N'<RequestMsg>Message for Target service.</RequestMsg>';


		INSERT INTO LogActivity (MessageSent,ConversationHandle)
		SELECT @RequestMsg,conversation_id 
		FROM sys.conversation_endpoints
		WHERE conversation_handle = @InitDlgHandle;

		SEND ON CONVERSATION @InitDlgHandle
			 MESSAGE TYPE RequestMessage (@RequestMsg);

		SELECT @RequestMsg AS SentRequestMsg;

	COMMIT TRANSACTION;

END;
GO


:connect SQLNODE01

Use InitiatorDB
GO
-- Step 3
IF OBJECT_ID('usp_ReceiveReplyEnDialog') IS NOT NULL
BEGIN
	DROP PROCEDURE usp_ReceiveReplyEnDialog;
END
GO
CREATE PROCEDURE usp_ReceiveReplyEnDialog
AS
BEGIN
	-- Receive the reply and end the conversation
	DECLARE @RecvReplyMsg NVARCHAR(100);
	DECLARE @RecvReplyDlgHandle UNIQUEIDENTIFIER;
	DECLARE @RecvReplyMsgName sysname;

	BEGIN TRANSACTION;

	WAITFOR
	( RECEIVE TOP(1)
		@RecvReplyDlgHandle = conversation_handle,
		@RecvReplyMsg = message_body,
		@RecvReplyMsgName = message_type_name
	  FROM InitiatorQueue
	), TIMEOUT 1000;

	IF @RecvReplyMsgName =  N'ReplyMessage'
	BEGIN
		UPDATE LogActivity
		SET TargetServer = @RecvReplyMsg,
		    InitiatorReceiveDT = SYSDATETIME()
		WHERE ConversationHandle = (SELECT conversation_id 
									FROM sys.conversation_endpoints
									WHERE conversation_handle = @RecvReplyDlgHandle ) 

		END CONVERSATION @RecvReplyDlgHandle;
	END
	
	IF @RecvReplyMsgName = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
       END CONVERSATION @RecvReplyDlgHandle;
    END

	SELECT @RecvReplyMsg AS ReceivedReplyMsg;

	COMMIT TRANSACTION;
END
GO




:connect SQLNODE02

Use TargetDB
-- Step 2
IF OBJECT_ID('usp_ProcessRequestSendReply') IS NOT NULL
BEGIN
	DROP PROCEDURE usp_ProcessRequestSendReply;
END
GO
CREATE PROCEDURE usp_ProcessRequestSendReply
AS
BEGIN
	-- Receive the request and send a reply
	DECLARE @RecvReqDlgHandle UNIQUEIDENTIFIER;
	DECLARE @RecvReqMsg NVARCHAR(100);
	DECLARE @RecvReqMsgName sysname;

	BEGIN TRANSACTION;

		WAITFOR
		( RECEIVE TOP(1)
			@RecvReqDlgHandle = conversation_handle,
			@RecvReqMsg = message_body,
			@RecvReqMsgName = message_type_name
		  FROM TargetQueue
		), TIMEOUT 1000;

		SELECT @RecvReqMsg AS ReceivedRequestMsg;

		IF @RecvReqMsgName = N'RequestMessage'
		BEGIN
			 
			INSERT INTO TargetTable (MessageReceived,ConversationHandle)
			SELECT @RecvReqMsg,conversation_id 
			FROM sys.conversation_endpoints
			WHERE conversation_handle = @RecvReqDlgHandle;
			 
			 DECLARE @ReplyMsg NVARCHAR(100);
			 SELECT @ReplyMsg = 
			 N'<ReplyMsg>'+@@servername+'</ReplyMsg>';
 
			 SEND ON CONVERSATION @RecvReqDlgHandle
				  MESSAGE TYPE ReplyMessage
				  (@ReplyMsg);
		END


	COMMIT TRANSACTION;
END;
GO



:connect SQLNODE02

Use TargetDB
GO
-- Step 4
IF OBJECT_ID('usp_ReceiveEndDialog_CloseConversation') IS NOT NULL
BEGIN
	DROP PROCEDURE usp_ReceiveEndDialog_CloseConversation;
END
GO
CREATE PROCEDURE usp_ReceiveEndDialog_CloseConversation
AS
BEGIN
	-- Receive the End Dialog and clean up
	DECLARE @RecvEndDialogDlgHandle UNIQUEIDENTIFIER;
	DECLARE @RecvEndDialogMsg NVARCHAR(100);
	DECLARE @RecvEndDialogMsgName sysname;

	BEGIN TRANSACTION;

		WAITFOR
		( RECEIVE TOP(1)
			@RecvEndDialogDlgHandle = conversation_handle,
			@RecvEndDialogMsg = message_body,
			@RecvEndDialogMsgName = message_type_name
		  FROM TargetQueue
		), TIMEOUT 1000;


		IF @RecvEndDialogMsgName = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
		BEGIN
			 END CONVERSATION @RecvEndDialogDlgHandle;
		END

	COMMIT TRANSACTION;
END









:connect SQLNODE03

Use TargetDB
-- Step 2
IF OBJECT_ID('usp_ProcessRequestSendReply') IS NOT NULL
BEGIN
	DROP PROCEDURE usp_ProcessRequestSendReply;
END
GO
CREATE PROCEDURE usp_ProcessRequestSendReply
AS
BEGIN
	-- Receive the request and send a reply
	DECLARE @RecvReqDlgHandle UNIQUEIDENTIFIER;
	DECLARE @RecvReqMsg NVARCHAR(100);
	DECLARE @RecvReqMsgName sysname;

	BEGIN TRANSACTION;

		WAITFOR
		( RECEIVE TOP(1)
			@RecvReqDlgHandle = conversation_handle,
			@RecvReqMsg = message_body,
			@RecvReqMsgName = message_type_name
		  FROM TargetQueue
		), TIMEOUT 1000;

		SELECT @RecvReqMsg AS ReceivedRequestMsg;

		IF @RecvReqMsgName = N'RequestMessage'
		BEGIN
			 
			INSERT INTO TargetTable (MessageReceived,ConversationHandle)
			SELECT @RecvReqMsg,conversation_id 
			FROM sys.conversation_endpoints
			WHERE conversation_handle = @RecvReqDlgHandle;
			 
			 DECLARE @ReplyMsg NVARCHAR(100);
			 SELECT @ReplyMsg = 
			 N'<ReplyMsg>'+@@servername+'</ReplyMsg>';
 
			 SEND ON CONVERSATION @RecvReqDlgHandle
				  MESSAGE TYPE ReplyMessage
				  (@ReplyMsg);
		END


	COMMIT TRANSACTION;
END;
GO



:connect SQLNODE03

Use TargetDB
GO
-- Step 4
IF OBJECT_ID('usp_ReceiveEndDialog_CloseConversation') IS NOT NULL
BEGIN
	DROP PROCEDURE usp_ReceiveEndDialog_CloseConversation;
END
GO
CREATE PROCEDURE usp_ReceiveEndDialog_CloseConversation
AS
BEGIN
	-- Receive the End Dialog and clean up
	DECLARE @RecvEndDialogDlgHandle UNIQUEIDENTIFIER;
	DECLARE @RecvEndDialogMsg NVARCHAR(100);
	DECLARE @RecvEndDialogMsgName sysname;

	BEGIN TRANSACTION;

		WAITFOR
		( RECEIVE TOP(1)
			@RecvEndDialogDlgHandle = conversation_handle,
			@RecvEndDialogMsg = message_body,
			@RecvEndDialogMsgName = message_type_name
		  FROM TargetQueue
		), TIMEOUT 1000;


		IF @RecvEndDialogMsgName = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
		BEGIN
			 END CONVERSATION @RecvEndDialogDlgHandle;
		END

	COMMIT TRANSACTION;
END




