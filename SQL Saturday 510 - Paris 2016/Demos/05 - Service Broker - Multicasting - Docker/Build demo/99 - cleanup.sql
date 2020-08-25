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
 
-- cleanup
use master
go

select 'drop database ['+name+'];' from sys.databases
drop database [MultiplexInitiator];
drop database [MultiplexTarget];

select 'drop login ['+name+'];' from sys.server_principals;
drop login [ServiceBrokerLogin];

select 'drop endpoint ['+name+'];' from sys.endpoints
drop endpoint [ServiceBrokerEndPoint];

select 'drop certificate ['+name+'];' from sys.certificates

drop certificate [EndPointCertificateSQLNode01];
drop certificate [EndPointCertificateSQLContainer02];
drop certificate [EndPointCertificateSQLContainer03];

drop certificate [InitiatorUserCertificate];
drop certificate [TargetUserCertificate];




DROP MASTER KEY
