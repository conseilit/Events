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

Use MultiplexInitiator

Create Master Key Encryption BY Password = '<#MultiplexInitiatorstrongpassword!#>'
GO
Create Certificate InitiatorUserCertificate
 WITH Subject = 'InitiatorUser',
    START_DATE = '01/01/2016',
    EXPIRY_DATE = '01/01/2099'
ACTIVE FOR BEGIN_DIALOG = ON;
GO

BACKUP CERTIFICATE InitiatorUserCertificate 
TO FILE='C:\sql\backup\InitiatorUserCertificate.cer';
GO

-- copy initiator certification on sqlcontainer1..5 

:connect SQLContainer01..05

Use MultiplexTarget

Create Master Key Encryption BY Password = '<#MultiplexTargetstrongpassword!#>';
GO

 
 



 

:connect SQLContainer01
USE MultiplexTarget

Create Certificate TargetUserCertificate
 WITH Subject = 'TargetUser',
    START_DATE = '01/01/2016',
    EXPIRY_DATE = '01/01/2099'
ACTIVE FOR BEGIN_DIALOG = ON;
GO
BACKUP CERTIFICATE TargetUserCertificate
TO FILE = 'C:\sql\backup\TargetUserCertificateWithPrivateKey.cer'
WITH PRIVATE KEY (FILE='C:\sql\backup\TargetUserCertificateWithPrivateKey.pvk',
                  ENCRYPTION BY PASSWORD = '<#PrivateKeyStrongpassword!#>');
GO     
BACKUP CERTIFICATE TargetUserCertificate
TO FILE = 'C:\sql\backup\TargetUserCertificate.cer';
     



--recopie des certificats sur 02..05


:connect SQLContainer02..05
USE MultiplexTarget

CREATE CERTIFICATE TargetUserCertificate
FROM FILE='C:\sql\backup\TargetUserCertificateWithPrivateKey.cer'
WITH PRIVATE KEY (FILE='C:\sql\backup\TargetUserCertificateWithPrivateKey.pvk',
                  DECRYPTION BY PASSWORD = '<#PrivateKeyStrongpassword!#>');
				  


:connect SQLNODE01
USE MultiplexInitiator
Create User TargetUser WITHOUT LOGIN
GO
CREATE CERTIFICATE TargetUserCertificate
 AUTHORIZATION TargetUser
 FROM FILE = 'C:\sql\backup\TargetUserCertificate.cer';
GO
GRANT CONNECT TO TargetUser;
GO
GRANT SEND ON SERVICE::InitiatorService To TargetUser;
GO
CREATE REMOTE SERVICE BINDING ServiceBindingTargetServiceSQL01 TO SERVICE 'TargetServiceSQL01' WITH USER = TargetUser;
CREATE REMOTE SERVICE BINDING ServiceBindingTargetServiceSQL02 TO SERVICE 'TargetServiceSQL02' WITH USER = TargetUser;
CREATE REMOTE SERVICE BINDING ServiceBindingTargetServiceSQL03 TO SERVICE 'TargetServiceSQL03' WITH USER = TargetUser;
CREATE REMOTE SERVICE BINDING ServiceBindingTargetServiceSQL04 TO SERVICE 'TargetServiceSQL04' WITH USER = TargetUser;
CREATE REMOTE SERVICE BINDING ServiceBindingTargetServiceSQL05 TO SERVICE 'TargetServiceSQL05' WITH USER = TargetUser;
GO


:connect SQLContainer01..05
USE MultiplexTarget
Create User InitiatorUser WITHOUT LOGIN
GO
CREATE CERTIFICATE InitiatorUserCertificate
 AUTHORIZATION InitiatorUser
FROM FILE = 'C:\sql\backup\InitiatorUserCertificate.cer';
GO
GRANT CONNECT TO InitiatorUser;
GO
 
-- 1 by 1
GRANT SEND ON SERVICE::TargetServiceSQL01 To InitiatorUser;
GRANT SEND ON SERVICE::TargetServiceSQL02 To InitiatorUser;
GRANT SEND ON SERVICE::TargetServiceSQL03 To InitiatorUser;
GRANT SEND ON SERVICE::TargetServiceSQL04 To InitiatorUser;
GRANT SEND ON SERVICE::TargetServiceSQL05 To InitiatorUser;
GO


CREATE REMOTE SERVICE BINDING ServiceBindingInitiatorService
 TO SERVICE 'InitiatorService'
 WITH USER = InitiatorUser

 
 

