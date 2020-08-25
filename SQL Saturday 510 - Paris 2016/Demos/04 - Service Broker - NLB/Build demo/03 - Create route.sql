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

/*

Create a Route:

Once the Services are created on both the servers we need to create routes in each database and associate it with a remote service to which it is sending message to.


*/

:connect SQLNODE02

select service_broker_guid
 from sys.databases
 where name = 'TargetDB'



:connect SQLNODE01

USE InitiatorDB

Create Route LoadBalancingRouteSQLNode02
WITH
  SERVICE_NAME = 'TargetService',
  BROKER_INSTANCE = '6E7B09CF-897E-4593-9031-9959FEB9B325',
  ADDRESS = 'TCP://SQLNODE02:7022'
GO

 

 
:connect SQLNODE03

select service_broker_guid
 from sys.databases
 where name = 'TargetDB'



:connect SQLNODE01

USE InitiatorDB

Create Route LoadBalancingRouteSQLNode03
WITH
  SERVICE_NAME = 'TargetService',
  BROKER_INSTANCE = 'A28094A4-B464-4198-8718-CFCCA8CCFA23',
  ADDRESS = 'TCP://SQLNODE03:7022'
GO

 

 

 
 


:connect SQLNODE01

select service_broker_guid
 from sys.databases
 where name = 'InitiatorDB'



:connect SQLNODE02

USE TargetDB

Create Route ReturnRouteToSQLNode01
WITH
  SERVICE_NAME = 'InitiatorService',
  BROKER_INSTANCE='EB8460FF-1C54-48F1-806D-56FB77266AE6',
 ADDRESS = 'TCP://SQLNODE01:7022'
GO

 

 
:connect SQLNODE03

USE TargetDB

Create Route ReturnRouteToSQLNode01
WITH
  SERVICE_NAME = 'InitiatorService',
  BROKER_INSTANCE='EB8460FF-1C54-48F1-806D-56FB77266AE6',
 ADDRESS = 'TCP://SQLNODE01:7022'
GO

 

 
 