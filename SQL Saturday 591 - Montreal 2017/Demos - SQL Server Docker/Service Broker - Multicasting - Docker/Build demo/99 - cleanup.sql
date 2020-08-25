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
 
-- cleanup
use master
go

select 'drop database ['+name+'];' from sys.databases
drop database [MsCloudSummit2017];
drop database [MulticastTarget];

select 'drop login ['+name+'];' from sys.server_principals;
drop login [ServiceBrokerLogin];
drop login [ServiceBrokerLoginSQLContainer01];
drop login [ServiceBrokerLoginSQLContainer02];
drop login [ServiceBrokerLoginSQLContainer03];
drop login [ServiceBrokerLoginSQLContainer04];
drop login [ServiceBrokerLoginSQLContainer05];

select 'drop endpoint ['+name+'];' from sys.endpoints
drop endpoint [ServiceBrokerEndPoint];

select 'drop certificate ['+name+'];' from sys.certificates
drop certificate [EndPointCertificateSQLMaster];
drop certificate [EndPointCertificateSQLContainer01];
drop certificate [EndPointCertificateSQLContainer02];
drop certificate [EndPointCertificateSQLContainer03];
drop certificate [EndPointCertificateSQLContainer04];
drop certificate [EndPointCertificateSQLContainer05];

drop certificate [MsCloudSummit2017UserCertificate];
drop certificate [MulticastTargetUserCertificate];




DROP MASTER KEY
