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
Set up Dialog Security:

Note: All actions related to Dialog Security will be performed in MsCloudSummit2017 of Server A and MulticastTarget of Server B, not in master databases.


*/




:CONNECT tcp:192.168.1.136,1433 -Usa -PPassword1!

Use MsCloudSummit2017

Create Master Key Encryption BY Password = '<#StrongPassword!#>'
GO
Create Certificate InitiatorUserCertificate
 WITH Subject = 'InitiatorUser',
    START_DATE = '01/01/2016',
    EXPIRY_DATE = '01/01/2099'
ACTIVE FOR BEGIN_DIALOG = ON;
GO

BACKUP CERTIFICATE InitiatorUserCertificate 
TO FILE='C:\data\InitiatorUserCertificate.cer';
GO

-- copy initiator certificate on sqlcontainer1..5 
Copy-Item C:\MSSQL\sqlmaster\InitiatorUserCertificate.cer C:\MSSQL\sqlexp01 -Force
Copy-Item C:\MSSQL\sqlmaster\InitiatorUserCertificate.cer C:\MSSQL\sqlexp02 -Force
Copy-Item C:\MSSQL\sqlmaster\InitiatorUserCertificate.cer C:\MSSQL\sqlexp03 -Force
Copy-Item C:\MSSQL\sqlmaster\InitiatorUserCertificate.cer C:\MSSQL\sqlexp04 -Force
Copy-Item C:\MSSQL\sqlmaster\InitiatorUserCertificate.cer C:\MSSQL\sqlexp05 -Force


:CONNECT AllContainers

Use MsCloudSummit2017

Create Master Key Encryption BY Password = '<#StrongPassword!#>';
GO

 
 



 

:CONNECT tcp:192.168.1.136,40001 -Usa -PPassword1!
Use MsCloudSummit2017

Create Certificate TargetUserCertificate
 WITH Subject = 'TargetUser',
    START_DATE = '01/01/2016',
    EXPIRY_DATE = '01/01/2099'
ACTIVE FOR BEGIN_DIALOG = ON;
GO
BACKUP CERTIFICATE TargetUserCertificate
TO FILE = 'C:\data\TargetUserCertificateWithPrivateKey.cer'
WITH PRIVATE KEY (FILE='C:\data\TargetUserCertificateWithPrivateKey.pvk',
                  ENCRYPTION BY PASSWORD = '<#PrivateKeyStrongpassword!#>');
GO     
BACKUP CERTIFICATE TargetUserCertificate
TO FILE = 'C:\data\TargetUserCertificate.cer';
GO     



--recopie des certificats
copy-item C:\MSSQL\sqlexp01\TargetUserCertificate.cer C:\MSSQL\sqlmaster -Force
copy-item C:\MSSQL\sqlexp01\TargetUserCertificateWithPrivateKey.* C:\MSSQL\sqlexp02 -Force
copy-item C:\MSSQL\sqlexp01\TargetUserCertificateWithPrivateKey.* C:\MSSQL\sqlexp03 -Force
copy-item C:\MSSQL\sqlexp01\TargetUserCertificateWithPrivateKey.* C:\MSSQL\sqlexp04 -Force
copy-item C:\MSSQL\sqlexp01\TargetUserCertificateWithPrivateKey.* C:\MSSQL\sqlexp05 -Force



:CONNECT tcp:192.168.1.136,40002 -Usa -PPassword1!
Use MsCloudSummit2017

CREATE CERTIFICATE TargetUserCertificate
FROM FILE='C:\data\TargetUserCertificateWithPrivateKey.cer'
WITH PRIVATE KEY (FILE='C:\data\TargetUserCertificateWithPrivateKey.pvk',
                  DECRYPTION BY PASSWORD = '<#PrivateKeyStrongpassword!#>');
GO				  

:CONNECT tcp:192.168.1.136,40003 -Usa -PPassword1!
Use MsCloudSummit2017

CREATE CERTIFICATE TargetUserCertificate
FROM FILE='C:\data\TargetUserCertificateWithPrivateKey.cer'
WITH PRIVATE KEY (FILE='C:\data\TargetUserCertificateWithPrivateKey.pvk',
                  DECRYPTION BY PASSWORD = '<#PrivateKeyStrongpassword!#>');
GO
				  
:CONNECT tcp:192.168.1.136,40004 -Usa -PPassword1!
Use MsCloudSummit2017

CREATE CERTIFICATE TargetUserCertificate
FROM FILE='C:\data\TargetUserCertificateWithPrivateKey.cer'
WITH PRIVATE KEY (FILE='C:\data\TargetUserCertificateWithPrivateKey.pvk',
                  DECRYPTION BY PASSWORD = '<#PrivateKeyStrongpassword!#>');
GO				  				  
			
:CONNECT tcp:192.168.1.136,40005 -Usa -PPassword1!
Use MsCloudSummit2017

CREATE CERTIFICATE TargetUserCertificate
FROM FILE='C:\data\TargetUserCertificateWithPrivateKey.cer'
WITH PRIVATE KEY (FILE='C:\data\TargetUserCertificateWithPrivateKey.pvk',
                  DECRYPTION BY PASSWORD = '<#PrivateKeyStrongpassword!#>');
GO				  			
				  
			



			

:CONNECT tcp:192.168.1.136,1433 -Usa -PPassword1!
USE MsCloudSummit2017
Create User TargetUser WITHOUT LOGIN
GO
CREATE CERTIFICATE TargetUserCertificate
 AUTHORIZATION TargetUser
 FROM FILE = 'C:\data\TargetUserCertificate.cer';
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


 
:CONNECT tcp:192.168.1.136,40001 -Usa -PPassword1!
Use MsCloudSummit2017 
GRANT SEND ON SERVICE::TargetServiceSQL01 To InitiatorUser;
GO


:CONNECT tcp:192.168.1.136,40002 -Usa -PPassword1!
Use MsCloudSummit2017 
GRANT SEND ON SERVICE::TargetServiceSQL02 To InitiatorUser;
GO


:CONNECT tcp:192.168.1.136,40003 -Usa -PPassword1!
Use MsCloudSummit2017 
GRANT SEND ON SERVICE::TargetServiceSQL03 To InitiatorUser;
GO


:CONNECT tcp:192.168.1.136,40004 -Usa -PPassword1!
Use MsCloudSummit2017 
GRANT SEND ON SERVICE::TargetServiceSQL04 To InitiatorUser;
GO


:CONNECT tcp:192.168.1.136,40005 -Usa -PPassword1!
Use MsCloudSummit2017 
GRANT SEND ON SERVICE::TargetServiceSQL05 To InitiatorUser;
GO



:CONNECT AllCOntainers
Use MsCloudSummit2017
Create User InitiatorUser WITHOUT LOGIN
GO
CREATE CERTIFICATE InitiatorUserCertificate
 AUTHORIZATION InitiatorUser
FROM FILE = 'C:\data\InitiatorUserCertificate.cer';
GO
GRANT CONNECT TO InitiatorUser;
GO
CREATE REMOTE SERVICE BINDING ServiceBindingInitiatorService
 TO SERVICE 'InitiatorService'
 WITH USER = InitiatorUser
GO
 