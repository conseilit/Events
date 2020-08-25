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

/*

Create a Route:

Once the Services are created on both the servers we need to create routes in each database and associate it with a remote service to which it is sending message to.


*/

 

 
:CONNECT all containers
-- fin broker guids
select service_broker_guid
 from sys.databases
 where name = 'MsCloudSummit2017'

/*
Server Name	service_broker_guid
192.168.1.136,40004	C9ABDB9C-71ED-407F-AC97-F695A408A838
192.168.1.136,40005	7CE60F60-DBF7-4671-9191-1CA4B37C3E7F
192.168.1.136,40001	B29C5A75-5422-410F-91B0-22DF74FC76C8
192.168.1.136,40002	2537CEC5-C966-499C-A5F9-644DDABD8B6F
192.168.1.136,40003	13DCCAD6-0FDF-4D67-8EFA-FBEDEA33EB83
*/

:CONNECT tcp:192.168.1.136,1433 -Usa -PPassword1!

USE MsCloudSummit2017

CREATE ROUTE [RouteToSQLContainer01]   WITH  SERVICE_NAME  = N'TargetServiceSQL01' ,  BROKER_INSTANCE  = N'B29C5A75-5422-410F-91B0-22DF74FC76C8' ,  ADDRESS  = N'TCP://192.168.1.136:47122' 
CREATE ROUTE [RouteToSQLContainer02]   WITH  SERVICE_NAME  = N'TargetServiceSQL02' ,  BROKER_INSTANCE  = N'2537CEC5-C966-499C-A5F9-644DDABD8B6F' ,  ADDRESS  = N'TCP://192.168.1.136:47222' 
CREATE ROUTE [RouteToSQLContainer03]   WITH  SERVICE_NAME  = N'TargetServiceSQL03' ,  BROKER_INSTANCE  = N'13DCCAD6-0FDF-4D67-8EFA-FBEDEA33EB83' ,  ADDRESS  = N'TCP://192.168.1.136:47322' 
CREATE ROUTE [RouteToSQLContainer04]   WITH  SERVICE_NAME  = N'TargetServiceSQL04' ,  BROKER_INSTANCE  = N'C9ABDB9C-71ED-407F-AC97-F695A408A838' ,  ADDRESS  = N'TCP://192.168.1.136:47422' 
CREATE ROUTE [RouteToSQLContainer05]   WITH  SERVICE_NAME  = N'TargetServiceSQL05' ,  BROKER_INSTANCE  = N'7CE60F60-DBF7-4671-9191-1CA4B37C3E7F' ,  ADDRESS  = N'TCP://192.168.1.136:47522' 

GO



 

 
 -- return route

:CONNECT tcp:192.168.1.136,1433 -Usa -PPassword1!

select service_broker_guid
 from sys.databases
 where name = 'MsCloudSummit2017'



:CONNECT allcontainers

USE MsCloudSummit2017

Create Route ReturnRouteToSQLMaster
WITH
  SERVICE_NAME = 'InitiatorService',
  BROKER_INSTANCE='D81B4E5A-F740-4737-BFCD-7279D1C1D2A7',
 ADDRESS = 'TCP://192.168.1.136:47022'
GO

 

 