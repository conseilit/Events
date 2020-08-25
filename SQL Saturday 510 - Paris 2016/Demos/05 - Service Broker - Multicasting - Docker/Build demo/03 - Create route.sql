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

:connect SQLContainer02

Create Route LoadBalancingRouteSQLContainer02
WITH
  SERVICE_NAME = 'TargetService',
  BROKER_INSTANCE = '09FF4A22-2A92-42F9-A7A6-E50DEC2DC7F4',
  ADDRESS = 'TCP://192.168.1.20:61431'
GO



:connect SQLNODE01

USE MultiplexInitiator

Create Route LoadBalancingRouteSQLContainer02
WITH
  SERVICE_NAME = 'TargetService',
  BROKER_INSTANCE = '6E7B09CF-897E-4593-9031-9959FEB9B325',
  ADDRESS = 'TCP://SQLContainer02:7022'
GO

 

 
:connect SQLContainer03

select service_broker_guid
 from sys.databases
 where name = 'MultiplexTarget'



:connect SQLNODE01

USE MultiplexInitiator

Create Route LoadBalancingRouteSQLContainer03
WITH
  SERVICE_NAME = 'TargetService',
  BROKER_INSTANCE = 'A28094A4-B464-4198-8718-CFCCA8CCFA23',
  ADDRESS = 'TCP://SQLContainer03:7022'
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
  BROKER_INSTANCE='0FDA0B05-E9F8-4EAB-A648-BA25C608B68F',
 ADDRESS = 'TCP://192.168.1.34:7022'
GO

 

 





/****** Object:  ServiceRoute [LoadBalancingMultiplexedRouteSQLContainer01]    Script Date: 11/06/2016 11:48:53 ******/
CREATE ROUTE [MultiplexedRouteSQLContainer01]   WITH  SERVICE_NAME  = N'TargetServiceSQL01' ,  BROKER_INSTANCE  = N'09FF4A22-2A92-42F9-A7A6-E50DEC2DC7F4' ,  ADDRESS  = N'TCP://192.168.1.20:61431' 
GO

/****** Object:  ServiceRoute [LoadBalancingMultiplexedRouteSQLContainer02]    Script Date: 11/06/2016 11:48:53 ******/
CREATE ROUTE [MultiplexedRouteSQLContainer02]   WITH  SERVICE_NAME  = N'TargetServiceSQL02' ,  BROKER_INSTANCE  = N'02B71315-69CE-44E0-9C02-3B0A6D4DA64C' ,  ADDRESS  = N'TCP://192.168.1.20:61432' 
GO

/****** Object:  ServiceRoute [LoadBalancingMultiplexedRouteSQLContainer03]    Script Date: 11/06/2016 11:48:53 ******/
CREATE ROUTE [MultiplexedRouteSQLContainer03]   WITH  SERVICE_NAME  = N'TargetServiceSQL03' ,  BROKER_INSTANCE  = N'4F1DBB3D-BCE3-4B83-85BE-5486F77E565A' ,  ADDRESS  = N'TCP://192.168.1.20:61433' 
GO

/****** Object:  ServiceRoute [LoadBalancingMultiplexedRouteSQLContainer04]    Script Date: 11/06/2016 11:48:53 ******/
CREATE ROUTE [MultiplexedRouteSQLContainer04]   WITH  SERVICE_NAME  = N'TargetServiceSQL04' ,  BROKER_INSTANCE  = N'DB9453F6-F418-4EAD-A037-B4C35875C9DD' ,  ADDRESS  = N'TCP://192.168.1.20:61434' 
GO

/****** Object:  ServiceRoute [LoadBalancingMultiplexedRouteSQLContainer05]    Script Date: 11/06/2016 11:48:53 ******/
CREATE ROUTE [MultiplexedRouteSQLContainer05]   WITH  SERVICE_NAME  = N'TargetServiceSQL05' ,  BROKER_INSTANCE  = N'A6C247B0-4B04-434A-A3D7-2B52CE71FCB4' ,  ADDRESS  = N'TCP://192.168.1.20:61435' 
GO



 

 
 