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
	Set up Transport Security:

	Note: All actions related to Transport Security will be performed in the master database of the Servers.

	1) Create a master key for master database.
	2) Create certificate and End Point that support certificate based authentication. 

*/


:CONNECT tcp:192.168.1.136,1433 -Usa -PPassword1!
Use master
Create Master Key Encryption BY Password = '<#StrongPassword!#>'

Create Certificate EndPointCertificateSQLMaster
WITH Subject = 'SQLMaster',
    START_DATE = '01/01/2016',
    EXPIRY_DATE = '01/01/2099'
ACTIVE FOR BEGIN_DIALOG = ON;


CREATE ENDPOINT ServiceBrokerEndPoint
   STATE=STARTED
   AS TCP (LISTENER_PORT = 7022)
   FOR SERVICE_BROKER 
   (
     AUTHENTICATION = CERTIFICATE EndPointCertificateSQLMaster,
     ENCRYPTION = SUPPORTED
   );

BACKUP CERTIFICATE EndPointCertificateSQLMaster 
 TO FILE = 'C:\data\EndPointCertificateSQLMaster.cer';
GO

-- Copy certificate to All Containers 
-- # Powershell
Copy-Item C:\MSSQL\sqlmaster\EndPointCertificateSQLMaster.cer C:\MSSQL\sqlexp01 -Force
Copy-Item C:\MSSQL\sqlmaster\EndPointCertificateSQLMaster.cer C:\MSSQL\sqlexp02 -Force
Copy-Item C:\MSSQL\sqlmaster\EndPointCertificateSQLMaster.cer C:\MSSQL\sqlexp03 -Force
Copy-Item C:\MSSQL\sqlmaster\EndPointCertificateSQLMaster.cer C:\MSSQL\sqlexp04 -Force
Copy-Item C:\MSSQL\sqlmaster\EndPointCertificateSQLMaster.cer C:\MSSQL\sqlexp05 -Force   


-- Container 1   
:CONNECT tcp:192.168.1.136,40001 -Usa -PPassword1!
Use master
 
Create Master Key Encryption BY Password = '<#StrongPassword!#>';

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
TO FILE= 'C:\data\EndPointCertificateSQLContainer01.cer';
GO	  

-- Create the certificate for SQLMaster
Create Certificate EndPointCertificateSQLMaster
 From FILE = 'C:\data\EndPointCertificateSQLMaster.cer';
GO

CREATE LOGIN ServiceBrokerLogin FROM CERTIFICATE EndPointCertificateSQLMaster;
GO
GRANT CONNECT ON ENDPOINT::ServiceBrokerEndPoint To ServiceBrokerLogin
GO

   
-- Container 2
:CONNECT tcp:192.168.1.136,40002 -Usa -PPassword1!
Use master
 
Create Master Key Encryption BY Password = '<#StrongPassword!#>';

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
TO FILE= 'C:\data\EndPointCertificateSQLContainer02.cer';
GO	  
	 
-- Create the certificate for SQLMaster
Create Certificate EndPointCertificateSQLMaster
 From FILE = 'C:\data\EndPointCertificateSQLMaster.cer';
GO

CREATE LOGIN ServiceBrokerLogin FROM CERTIFICATE EndPointCertificateSQLMaster;
GO
GRANT CONNECT ON ENDPOINT::ServiceBrokerEndPoint To ServiceBrokerLogin
GO

 
	  
-- Container 3
:CONNECT tcp:192.168.1.136,40003 -Usa -PPassword1!
Use master
 
Create Master Key Encryption BY Password = '<#StrongPassword!#>';

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

BACKUP CERTIFICATE EndPointCertificateSQLContainer03 
TO FILE= 'C:\data\EndPointCertificateSQLContainer03.cer';
GO	 
	  
-- Create the certificate for SQLMaster
Create Certificate EndPointCertificateSQLMaster
 From FILE = 'C:\data\EndPointCertificateSQLMaster.cer';
GO

CREATE LOGIN ServiceBrokerLogin FROM CERTIFICATE EndPointCertificateSQLMaster;
GO
GRANT CONNECT ON ENDPOINT::ServiceBrokerEndPoint To ServiceBrokerLogin
GO




-- Container 4	  
:CONNECT tcp:192.168.1.136,40004 -Usa -PPassword1!
Use master
 
Create Master Key Encryption BY Password = '<#StrongPassword!#>';

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


BACKUP CERTIFICATE EndPointCertificateSQLContainer04 
TO FILE= 'C:\data\EndPointCertificateSQLContainer04.cer';
GO	 

-- Create the certificate for SQLMaster
Create Certificate EndPointCertificateSQLMaster
 From FILE = 'C:\data\EndPointCertificateSQLMaster.cer';
GO

CREATE LOGIN ServiceBrokerLogin FROM CERTIFICATE EndPointCertificateSQLMaster;
GO
GRANT CONNECT ON ENDPOINT::ServiceBrokerEndPoint To ServiceBrokerLogin
GO



-- Container 5
:CONNECT tcp:192.168.1.136,40005 -Usa -PPassword1!
Use master
 
Create Master Key Encryption BY Password = '<#StrongPassword!#>';

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
	  
BACKUP CERTIFICATE EndPointCertificateSQLContainer05 
TO FILE= 'C:\data\EndPointCertificateSQLContainer05.cer';
GO

-- Create the certificate for SQLMaster
Create Certificate EndPointCertificateSQLMaster
 From FILE = 'C:\data\EndPointCertificateSQLMaster.cer';
GO

CREATE LOGIN ServiceBrokerLogin FROM CERTIFICATE EndPointCertificateSQLMaster;
GO
GRANT CONNECT ON ENDPOINT::ServiceBrokerEndPoint To ServiceBrokerLogin
GO





-- recopie des certificats des SQLContainers vers SQLMaster
Copy-Item C:\MSSQL\sqlexp01\EndPointCertificateSQLContainer01.cer C:\MSSQL\sqlmaster -Force
Copy-Item C:\MSSQL\sqlexp02\EndPointCertificateSQLContainer02.cer C:\MSSQL\sqlmaster -Force
Copy-Item C:\MSSQL\sqlexp03\EndPointCertificateSQLContainer03.cer C:\MSSQL\sqlmaster -Force
Copy-Item C:\MSSQL\sqlexp04\EndPointCertificateSQLContainer04.cer C:\MSSQL\sqlmaster -Force
Copy-Item C:\MSSQL\sqlexp05\EndPointCertificateSQLContainer05.cer C:\MSSQL\sqlmaster -Force


:CONNECT tcp:192.168.1.136,1433 -Usa -PPassword1!
Use Master
Go
Create Certificate EndPointCertificateSQLContainer01 From FILE = 'C:\data\EndPointCertificateSQLContainer01.cer';
Create Certificate EndPointCertificateSQLContainer02 From FILE = 'C:\data\EndPointCertificateSQLContainer02.cer';
Create Certificate EndPointCertificateSQLContainer03 From FILE = 'C:\data\EndPointCertificateSQLContainer03.cer';
Create Certificate EndPointCertificateSQLContainer04 From FILE = 'C:\data\EndPointCertificateSQLContainer04.cer';
Create Certificate EndPointCertificateSQLContainer05 From FILE = 'C:\data\EndPointCertificateSQLContainer05.cer';
GO
CREATE LOGIN ServiceBrokerLoginSQLContainer01 FROM CERTIFICATE EndPointCertificateSQLContainer01;
CREATE LOGIN ServiceBrokerLoginSQLContainer02 FROM CERTIFICATE EndPointCertificateSQLContainer02;
CREATE LOGIN ServiceBrokerLoginSQLContainer03 FROM CERTIFICATE EndPointCertificateSQLContainer03;
CREATE LOGIN ServiceBrokerLoginSQLContainer04 FROM CERTIFICATE EndPointCertificateSQLContainer04;
CREATE LOGIN ServiceBrokerLoginSQLContainer05 FROM CERTIFICATE EndPointCertificateSQLContainer05;
GO
GRANT CONNECT ON ENDPOINT::ServiceBrokerEndPoint To ServiceBrokerLoginSQLContainer01
GRANT CONNECT ON ENDPOINT::ServiceBrokerEndPoint To ServiceBrokerLoginSQLContainer02
GRANT CONNECT ON ENDPOINT::ServiceBrokerEndPoint To ServiceBrokerLoginSQLContainer03
GRANT CONNECT ON ENDPOINT::ServiceBrokerEndPoint To ServiceBrokerLoginSQLContainer04
GRANT CONNECT ON ENDPOINT::ServiceBrokerEndPoint To ServiceBrokerLoginSQLContainer05
GO

