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

use InitiatorDB
GO


EXEC usp_SendRequestToTarget
GO 20


-- view data
SELECT *, Substring(TargetServer,11,9) As Server 
FROM LogActivity
GO
SELECT Substring(TargetServer,11,9), COUNT(*) As MessagesCount
FROM LogActivity
GROUP BY Substring(TargetServer,11,9)

/*
TRUNCATE TABLE LogActivity
*/