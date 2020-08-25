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

 

 
:connect SQLContainer01..5
-- fin broker guids
select service_broker_guid
 from sys.databases
 where name = 'MultiplexTarget'

/*
Server Name	service_broker_guid
192.168.1.25,61435	1E1D2CC0-8E45-4ADF-80E5-C9E43B7238E6
192.168.1.25,61433	A0E95017-ADB5-4D5E-B542-4DEA1C4A0759
192.168.1.25,61431	9980B190-BE30-48CC-AEF4-0A30904495EA
192.168.1.25,61434	89ECD948-3933-497B-8B4A-B22A4783A5F5
192.168.1.25,61432	A3EC6EC2-5EE4-47BC-8F8C-35EAFA1673DD
*/

:connect SQLNODE01

USE MultiplexInitiator

CREATE ROUTE [MultiplexedRouteSQLContainer01]   WITH  SERVICE_NAME  = N'TargetServiceSQL01' ,  BROKER_INSTANCE  = N'9980B190-BE30-48CC-AEF4-0A30904495EA' ,  ADDRESS  = N'TCP://192.168.1.28:61771' 
CREATE ROUTE [MultiplexedRouteSQLContainer02]   WITH  SERVICE_NAME  = N'TargetServiceSQL02' ,  BROKER_INSTANCE  = N'A3EC6EC2-5EE4-47BC-8F8C-35EAFA1673DD' ,  ADDRESS  = N'TCP://192.168.1.28:61772' 
CREATE ROUTE [MultiplexedRouteSQLContainer03]   WITH  SERVICE_NAME  = N'TargetServiceSQL03' ,  BROKER_INSTANCE  = N'A0E95017-ADB5-4D5E-B542-4DEA1C4A0759' ,  ADDRESS  = N'TCP://192.168.1.28:61773' 
CREATE ROUTE [MultiplexedRouteSQLContainer04]   WITH  SERVICE_NAME  = N'TargetServiceSQL04' ,  BROKER_INSTANCE  = N'89ECD948-3933-497B-8B4A-B22A4783A5F5' ,  ADDRESS  = N'TCP://192.168.1.28:61774' 
CREATE ROUTE [MultiplexedRouteSQLContainer05]   WITH  SERVICE_NAME  = N'TargetServiceSQL05' ,  BROKER_INSTANCE  = N'1E1D2CC0-8E45-4ADF-80E5-C9E43B7238E6' ,  ADDRESS  = N'TCP://192.168.1.28:61775' 
GO



 

 
 -- return route

:connect SQLNODE01

select service_broker_guid
 from sys.databases
 where name = 'MultiplexInitiator'



:connect SQLContainer01..05

USE MultiplexTarget

Create Route ReturnRouteToSQLNode01
WITH
  SERVICE_NAME = 'InitiatorService',
  BROKER_INSTANCE='C3AEDA42-1453-4F2A-BDF1-AA72C71F4917',
 ADDRESS = 'TCP://192.168.1.211:7022'
GO

 

 