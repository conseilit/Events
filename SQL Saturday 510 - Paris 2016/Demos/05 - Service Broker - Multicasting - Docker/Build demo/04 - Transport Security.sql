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


CREATE ENDPOINT ServiceBrokerEndPoint
   STATE=STARTED
   AS TCP (LISTENER_PORT = 7022)
   FOR SERVICE_BROKER 
   (
     AUTHENTICATION = CERTIFICATE EndPointCertificateSQLNode01,
     ENCRYPTION = SUPPORTED
   );


   
   
:connect SQLContainer02
Use master
 
Create Master Key Encryption BY Password = '<#SQLContainer01strongpassword!#>';

Create Certificate EndPointCertificateSQLContainer01
WITH Subject = 'SQLContainer01',
       START_DATE = '01/01/2016',
       EXPIRY_DATE = '01/01/2099'
ACTIVE FOR BEGIN_DIALOG = ON;


CREATE ENDPOINT ServiceBrokerEndPoint
      STATE=STARTED
      AS TCP (LISTENER_PORT = 7022)
      FOR SERVICE_BROKER
      ( 
         AUTHENTICATION = CERTIFICATE EndPointCertificateSQLContainer01,
         ENCRYPTION = SUPPORTED
      );



BACKUP CERTIFICATE EndPointCertificateSQLContainer01 
TO FILE= 'C:\sql\backup\EndPointCertificateSQLContainer01.cer';
GO	  
   
   
-- server 2
:connect SQLContainer02
Use master
 
Create Master Key Encryption BY Password = '<#SQLContainer02strongpassword!#>';

Create Certificate EndPointCertificateSQLContainer02
WITH Subject = 'SQLContainer02',
       START_DATE = '01/01/2016',
       EXPIRY_DATE = '01/01/2099'
ACTIVE FOR BEGIN_DIALOG = ON;


CREATE ENDPOINT ServiceBrokerEndPoint
      STATE=STARTED
      AS TCP (LISTENER_PORT = 7022)
      FOR SERVICE_BROKER
      ( 
         AUTHENTICATION = CERTIFICATE EndPointCertificateSQLContainer02,
         ENCRYPTION = SUPPORTED
      );



BACKUP CERTIFICATE EndPointCertificateSQLContainer02 
TO FILE= 'C:\sql\backup\EndPointCertificateSQLContainer02.cer';
GO	  
	  
	  
--server3
:connect SQLContainer03
Use master
 
Create Master Key Encryption BY Password = '<#SQLContainer03strongpassword!#>';

Create Certificate EndPointCertificateSQLContainer03
WITH Subject = 'SQLContainer03',
       START_DATE = '01/01/2016',
       EXPIRY_DATE = '01/01/2099'
ACTIVE FOR BEGIN_DIALOG = ON;


CREATE ENDPOINT ServiceBrokerEndPoint
      STATE=STARTED
      AS TCP (LISTENER_PORT = 7022)
      FOR SERVICE_BROKER
      ( 
         AUTHENTICATION = CERTIFICATE EndPointCertificateSQLContainer03,
         ENCRYPTION = SUPPORTED
      );
	  
	  
:connect SQLContainer04
Use master
 
Create Master Key Encryption BY Password = '<#SQLContainer04strongpassword!#>';

Create Certificate EndPointCertificateSQLContainer04
WITH Subject = 'SQLContainer04',
       START_DATE = '01/01/2016',
       EXPIRY_DATE = '01/01/2099'
ACTIVE FOR BEGIN_DIALOG = ON;


CREATE ENDPOINT ServiceBrokerEndPoint
      STATE=STARTED
      AS TCP (LISTENER_PORT = 7022)
      FOR SERVICE_BROKER
      ( 
         AUTHENTICATION = CERTIFICATE EndPointCertificateSQLContainer04,
         ENCRYPTION = SUPPORTED
      );



:connect SQLContainer05
Use master
 
Create Master Key Encryption BY Password = '<#SQLContainer05strongpassword!#>';

Create Certificate EndPointCertificateSQLContainer05
WITH Subject = 'SQLContainer05',
       START_DATE = '01/01/2016',
       EXPIRY_DATE = '01/01/2099'
ACTIVE FOR BEGIN_DIALOG = ON;


CREATE ENDPOINT ServiceBrokerEndPoint
      STATE=STARTED
      AS TCP (LISTENER_PORT = 7022)
      FOR SERVICE_BROKER
      ( 
         AUTHENTICATION = CERTIFICATE EndPointCertificateSQLContainer05,
         ENCRYPTION = SUPPORTED
      );
	  
	  

:connect SQLNODE01
BACKUP CERTIFICATE EndPointCertificateSQLNode01 
 TO FILE = 'C:\sql\backup\EndPointCertificateSQLNode01.cer';
GO



:connect SQLContainer03
BACKUP CERTIFICATE EndPointCertificateSQLContainer03 
TO FILE= 'C:\sql\backup\EndPointCertificateSQLContainer03.cer';
GO


:connect SQLNODE01
!!ROBOCOPY C:\sql\backup\EndPointCertificateSQLNode01.cer \\SQLContainer02\EndPointCertificateSQLNode01.cer


-- recopie des certificats

:connect SQLNODE01


Create Certificate EndPointCertificateSQLContainer01 From FILE = 'C:\temp\EndPointCertificateSQLContainer01.cer';
Create Certificate EndPointCertificateSQLContainer02 From FILE = 'C:\temp\EndPointCertificateSQLContainer02.cer';
Create Certificate EndPointCertificateSQLContainer03 From FILE = 'C:\temp\EndPointCertificateSQLContainer03.cer';
Create Certificate EndPointCertificateSQLContainer04 From FILE = 'C:\temp\EndPointCertificateSQLContainer04.cer';
Create Certificate EndPointCertificateSQLContainer05 From FILE = 'C:\temp\EndPointCertificateSQLContainer05.cer';



 
 

:connect SQLContainer02..05

Create Certificate EndPointCertificateSQLNode01
 From FILE = 'C:\sql\backup\EndPointCertificateSQLNode01.cer';
GO
 




:connect SQLNODE01

CREATE LOGIN ServiceBrokerLoginSQLContainer01 FROM CERTIFICATE EndPointCertificateSQLContainer01;
CREATE LOGIN ServiceBrokerLoginSQLContainer02 FROM CERTIFICATE EndPointCertificateSQLContainer02;
CREATE LOGIN ServiceBrokerLoginSQLContainer03 FROM CERTIFICATE EndPointCertificateSQLContainer03;
CREATE LOGIN ServiceBrokerLoginSQLContainer04 FROM CERTIFICATE EndPointCertificateSQLContainer04;
CREATE LOGIN ServiceBrokerLoginSQLContainer05 FROM CERTIFICATE EndPointCertificateSQLContainer05;
GO



:connect SQLContainer01..05

CREATE LOGIN ServiceBrokerLogin FROM CERTIFICATE EndPointCertificateSQLNode01;
GO


:connect SQLNODE01
GRANT CONNECT ON ENDPOINT::ServiceBrokerEndPoint To ServiceBrokerLoginSQLContainer01
GRANT CONNECT ON ENDPOINT::ServiceBrokerEndPoint To ServiceBrokerLoginSQLContainer02
GRANT CONNECT ON ENDPOINT::ServiceBrokerEndPoint To ServiceBrokerLoginSQLContainer03
GRANT CONNECT ON ENDPOINT::ServiceBrokerEndPoint To ServiceBrokerLoginSQLContainer04
GRANT CONNECT ON ENDPOINT::ServiceBrokerEndPoint To ServiceBrokerLoginSQLContainer05
GO

 

:connect SQLContainer01..05

GRANT CONNECT ON ENDPOINT::ServiceBrokerEndPoint To ServiceBrokerLogin
GO
 
