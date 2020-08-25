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


 

:connect SQLNODE02

Use TargetDB

Create Master Key Encryption BY Password = '<#TargetDBstrongpassword!#>';


 
 
:connect SQLNODE03

Use TargetDB

Create Master Key Encryption BY Password = '<#TargetDBstrongpassword!#>';


 
 
 
 
 

:connect SQLNODE01
Use InitiatorDB

Create Certificate InitiatorUserCertificate
 WITH Subject = 'InitiatorUser',
    START_DATE = '01/01/2016',
    EXPIRY_DATE = '01/01/2099'
ACTIVE FOR BEGIN_DIALOG = ON;


 

:connect SQLNODE02
USE TargetDB

Create Certificate TargetUserCertificate
 WITH Subject = 'TargetUser',
    START_DATE = '01/01/2016',
    EXPIRY_DATE = '01/01/2099'
ACTIVE FOR BEGIN_DIALOG = ON;


 
/*
:connect SQLNODE03
USE TargetDB

Create Certificate TargetUserSQLNode03Certificate
 WITH Subject = 'TargetUser',
    START_DATE = '01/01/2016',
    EXPIRY_DATE = '01/01/2099'
ACTIVE FOR BEGIN_DIALOG = ON;
*/




:connect SQLNODE01
Use InitiatorDB

BACKUP CERTIFICATE InitiatorUserCertificate 
TO FILE='C:\Temp\InitiatorUserCertificate.cer';
GO
 
:connect SQLNODE02
USE TargetDB

BACKUP CERTIFICATE TargetUserCertificate TO
FILE='C:\Temp\TargetUserCertificate.cer';
GO


:connect SQLNODE02
USE TargetDB

BACKUP CERTIFICATE TargetUserCertificate
TO FILE = 'C:\Temp\TargetUserCertificateWithPrivateKey.cer'
WITH PRIVATE KEY (FILE='C:\Temp\TargetUserCertificateWithPrivateKey.pvk',
                  ENCRYPTION BY PASSWORD = '<#PrivateKeyStrongpassword!#>');
     

/*
:connect SQLNODE03
USE TargetDB

BACKUP CERTIFICATE TargetUserSQLNode03Certificate TO
FILE='C:\Temp\TargetUserSQLNode03Certificate.cer';
GO
*/




--recopie des certificats

:connect SQLNODE03
USE TargetDB

CREATE CERTIFICATE TargetUserCertificate
FROM FILE='C:\Temp\TargetUserCertificateWithPrivateKey.cer'
WITH PRIVATE KEY (FILE='C:\Temp\TargetUserCertificateWithPrivateKey.pvk',
                  DECRYPTION BY PASSWORD = '<#PrivateKeyStrongpassword!#>');
				  


:connect SQLNODE01
USE InitiatorDB
Create User TargetUser WITHOUT LOGIN
GO

/*
:connect SQLNODE01
USE InitiatorDB
Create User TargetUserSQLNode03 WITHOUT LOGIN
GO
*/

:connect SQLNODE02
USE TargetDB
Create User InitiatorUser WITHOUT LOGIN
GO
 
:connect SQLNODE03
USE TargetDB
Create User InitiatorUser WITHOUT LOGIN
GO
 

:connect SQLNODE01
USE InitiatorDB
CREATE CERTIFICATE TargetUserCertificate
 AUTHORIZATION TargetUser
 FROM FILE = 'C:\Temp\TargetUserCertificate.cer';
GO

/*
:connect SQLNODE01
USE InitiatorDB
CREATE CERTIFICATE TargetUserSQLNode03Certificate
 AUTHORIZATION TargetUserSQLNode03
 FROM FILE = 'C:\Temp\TargetUserSQLNode03Certificate.cer';
GO
*/
 

:connect SQLNODE02
USE TargetDB
CREATE CERTIFICATE InitiatorUserCertificate
 AUTHORIZATION InitiatorUser
FROM FILE = 'C:\Temp\InitiatorUserCertificate.cer';
GO
 

:connect SQLNODE03
USE TargetDB
CREATE CERTIFICATE InitiatorUserCertificate
 AUTHORIZATION InitiatorUser
FROM FILE = 'C:\Temp\InitiatorUserCertificate.cer';
GO
 
 
 




:connect SQLNODE01
USE InitiatorDB
GRANT CONNECT TO TargetUser;

/*
:connect SQLNODE01
USE InitiatorDB
GRANT CONNECT TO TargetUserSQLNode03;
*/ 

:connect SQLNODE02
USE TargetDB
GRANT CONNECT TO InitiatorUser;

:connect SQLNODE03
USE TargetDB
GRANT CONNECT TO InitiatorUser;
 
 

:connect SQLNODE01
USE InitiatorDB

GRANT SEND ON SERVICE::InitiatorService To TargetUser;
GO

/*
:connect SQLNODE01
USE InitiatorDB

GRANT SEND ON SERVICE::InitiatorService To TargetUserSQLNode03;
GO
*/ 
 

:connect SQLNODE02
USE TargetDB

GRANT SEND ON SERVICE::TargetService To InitiatorUser;
GO

:connect SQLNODE03
USE TargetDB

GRANT SEND ON SERVICE::TargetService To InitiatorUser;
GO

 

:connect SQLNODE01
USE InitiatorDB

CREATE REMOTE SERVICE BINDING ServiceBindingTargetService
 TO SERVICE 'TargetService'
 WITH USER = TargetUser

 
 
/*
:connect SQLNODE01
USE InitiatorDB

CREATE REMOTE SERVICE BINDING ServiceBindingB
 TO SERVICE 'TargetService'
 WITH USER = TargetUserSQLNode03
*/
 
 

:connect SQLNODE02
USE TargetDB
CREATE REMOTE SERVICE BINDING ServiceBindingInitiatorService
 TO SERVICE 'InitiatorService'
 WITH USER = InitiatorUser

 
 
:connect SQLNODE03
USE TargetDB
CREATE REMOTE SERVICE BINDING ServiceBindingInitiatorService
 TO SERVICE 'InitiatorService'
 WITH USER = InitiatorUser

 

