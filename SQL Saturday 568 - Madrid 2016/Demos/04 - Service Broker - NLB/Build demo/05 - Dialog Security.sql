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
Set up Dialog Security:

Note: All actions related to Dialog Security will be performed in MultiplexInitiator of Server A and MultiplexTarget of Server B, not in master databases.


*/



:connect SQLNODE01
Use InitiatorDB

Create Master Key Encryption BY Password = '<#InitiatorDBstrongpassword!#>'
GO
Create Certificate InitiatorUserCertificate
 WITH Subject = 'InitiatorUser',
    START_DATE = '01/01/2016',
    EXPIRY_DATE = '01/01/2099'
ACTIVE FOR BEGIN_DIALOG = ON;
GO
BACKUP CERTIFICATE InitiatorUserCertificate 
TO FILE='C:\Temp\InitiatorUserCertificate.cer';
GO
 

:connect SQLNODE02
Use TargetDB

Create Master Key Encryption BY Password = '<#TargetDBstrongpassword!#>';
GO
Create Certificate TargetUserCertificate
 WITH Subject = 'TargetUser',
    START_DATE = '01/01/2016',
    EXPIRY_DATE = '01/01/2099'
ACTIVE FOR BEGIN_DIALOG = ON;
GO
BACKUP CERTIFICATE TargetUserCertificate TO
FILE='C:\Temp\TargetUserCertificate.cer';
GO
BACKUP CERTIFICATE TargetUserCertificate
TO FILE = 'C:\Temp\TargetUserCertificateWithPrivateKey.cer'
WITH PRIVATE KEY (FILE='C:\Temp\TargetUserCertificateWithPrivateKey.pvk',
                  ENCRYPTION BY PASSWORD = '<#PrivateKeyStrongpassword!#>');
GO


--recopie des certificats
 
 
:connect SQLNODE03
Use TargetDB

Create Master Key Encryption BY Password = '<#TargetDBstrongpassword!#>';
GO
CREATE CERTIFICATE TargetUserCertificate
FROM FILE='C:\Temp\TargetUserCertificateWithPrivateKey.cer'
WITH PRIVATE KEY (FILE='C:\Temp\TargetUserCertificateWithPrivateKey.pvk',
                  DECRYPTION BY PASSWORD = '<#PrivateKeyStrongpassword!#>');
GO
Create User InitiatorUser WITHOUT LOGIN;
GO
CREATE CERTIFICATE InitiatorUserCertificate
 AUTHORIZATION InitiatorUser
FROM FILE = 'C:\Temp\InitiatorUserCertificate.cer';
GO
GRANT CONNECT TO InitiatorUser;
GO
GRANT SEND ON SERVICE::TargetService To InitiatorUser;
GO
CREATE REMOTE SERVICE BINDING ServiceBindingInitiatorService
 TO SERVICE 'InitiatorService'
 WITH USER = InitiatorUser;
GO
 
 
 
:connect SQLNODE02
USE TargetDB

Create User InitiatorUser WITHOUT LOGIN
GO
CREATE CERTIFICATE InitiatorUserCertificate
 AUTHORIZATION InitiatorUser
FROM FILE = 'C:\Temp\InitiatorUserCertificate.cer';
GO
GRANT CONNECT TO InitiatorUser;
GO
GRANT SEND ON SERVICE::TargetService To InitiatorUser;
GO 
CREATE REMOTE SERVICE BINDING ServiceBindingInitiatorService
 TO SERVICE 'InitiatorService'
 WITH USER = InitiatorUser;
GO 
 

				  


:connect SQLNODE01
USE InitiatorDB
Create User TargetUser WITHOUT LOGIN
GO
CREATE CERTIFICATE TargetUserCertificate
 AUTHORIZATION TargetUser
 FROM FILE = 'C:\Temp\TargetUserCertificate.cer';
GO
GRANT CONNECT TO TargetUser;
GO
GRANT SEND ON SERVICE::InitiatorService To TargetUser;
GO
CREATE REMOTE SERVICE BINDING ServiceBindingTargetService
 TO SERVICE 'TargetService'
 WITH USER = TargetUser;
GO
 


