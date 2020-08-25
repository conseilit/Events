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
	Set up Transport Security:

	Note: All actions related to Transport Security will be performed in the master database of the Servers.

	1) Create a master key for master database.
	2) Create certificate and End Point that support certificate based authentication. 

*/

-- server 1
:connect SQLNODE01
Use master
Create Master Key Encryption BY Password = '<#SQLNODE01strongpassword!#>'

Create Certificate EndPointCertificateSQLNode01
WITH Subject = 'SQLNODE01',
    START_DATE = '01/01/2016',
    EXPIRY_DATE = '01/01/2099'
ACTIVE FOR BEGIN_DIALOG = ON;
GO

CREATE ENDPOINT ServiceBrokerEndPoint
   STATE=STARTED
   AS TCP (LISTENER_PORT = 7022)
   FOR SERVICE_BROKER 
   (
     AUTHENTICATION = CERTIFICATE EndPointCertificateSQLNode01,
     ENCRYPTION = SUPPORTED
   );
GO

BACKUP CERTIFICATE EndPointCertificateSQLNode01 
 TO FILE = 'C:\Temp\EndPointCertificateSQLNode01.cer';
GO



-- server 2
:connect SQLNODE02
Use master
 
Create Master Key Encryption BY Password = '<#SQLNODE02strongpassword!#>';

Create Certificate EndPointCertificateSQLNode02
WITH Subject = 'SQLNODE02',
       START_DATE = '01/01/2016',
       EXPIRY_DATE = '01/01/2099'
ACTIVE FOR BEGIN_DIALOG = ON;
GO

CREATE ENDPOINT ServiceBrokerEndPoint
      STATE=STARTED
      AS TCP (LISTENER_PORT = 7022)
      FOR SERVICE_BROKER
      ( 
         AUTHENTICATION = CERTIFICATE EndPointCertificateSQLNode02,
         ENCRYPTION = SUPPORTED
      );
GO

BACKUP CERTIFICATE EndPointCertificateSQLNode02 
TO FILE= 'C:\temp\EndPointCertificateSQLNode02.cer';
GO
	  
--server3
:connect SQLNODE03
Use master
 
Create Master Key Encryption BY Password = '<#SQLNODE03strongpassword!#>';

Create Certificate EndPointCertificateSQLNode03
WITH Subject = 'SQLNODE03',
       START_DATE = '01/01/2016',
       EXPIRY_DATE = '01/01/2099'
ACTIVE FOR BEGIN_DIALOG = ON;
GO

CREATE ENDPOINT ServiceBrokerEndPoint
      STATE=STARTED
      AS TCP (LISTENER_PORT = 7022)
      FOR SERVICE_BROKER
      ( 
         AUTHENTICATION = CERTIFICATE EndPointCertificateSQLNode03,
         ENCRYPTION = SUPPORTED
      );
GO

BACKUP CERTIFICATE EndPointCertificateSQLNode03 
TO FILE= 'C:\temp\EndPointCertificateSQLNode03.cer';
GO


:connect SQLNODE01
!!ROBOCOPY C:\temp\EndPointCertificateSQLNode01.cer \\SQLNODE02\EndPointCertificateSQLNode01.cer


-- recopie des certificats

:connect SQLNODE01

Create Certificate EndPointCertificateSQLNode02
 From FILE = 'C:\Temp\EndPointCertificateSQLNode02.cer';
GO
Create Certificate EndPointCertificateSQLNode03
 From FILE = 'C:\Temp\EndPointCertificateSQLNode03.cer';
GO
CREATE LOGIN ServiceBrokerLoginSQLNode02
 FROM CERTIFICATE EndPointCertificateSQLNode02;
GO 
CREATE LOGIN ServiceBrokerLoginSQLNode03
 FROM CERTIFICATE EndPointCertificateSQLNode03;
GO
GRANT CONNECT ON ENDPOINT::ServiceBrokerEndPoint To ServiceBrokerLoginSQLNode02
GRANT CONNECT ON ENDPOINT::ServiceBrokerEndPoint To ServiceBrokerLoginSQLNode03
GO
 

:connect SQLNODE02

Create Certificate EndPointCertificateSQLNode01
 From FILE = 'C:\Temp\EndPointCertificateSQLNode01.cer';
GO
CREATE LOGIN ServiceBrokerLogin
 FROM CERTIFICATE EndPointCertificateSQLNode01;
GO 
GRANT CONNECT ON ENDPOINT::ServiceBrokerEndPoint To ServiceBrokerLogin
GO




:connect SQLNODE03

Create Certificate EndPointCertificateSQLNode01
 From FILE = 'C:\Temp\EndPointCertificateSQLNode01.cer';
GO
CREATE LOGIN ServiceBrokerLogin
 FROM CERTIFICATE EndPointCertificateSQLNode01;
GO
GRANT CONNECT ON ENDPOINT::ServiceBrokerEndPoint To ServiceBrokerLogin
GO
 