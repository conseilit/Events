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

	AlwaysOn Availability Groups domainless
	Windows 2016 / SQL Server 2016
*/




-- Step 1
-- Install Windows
-- Configure the same DNS Server on all nodes 
-- Create the DNS Suffix (sqlserver.workgroup)
-- Rename the node and add DNS Suffix



-- Step 2 Setup SQL Server 


-- Build cluster with powershell command
New-Cluster –Name CLUSTSQLWRK -Node SQL2K16W01,SQL2K16W02,SQL2K16W03 -AdministrativeAccessPoint DNS

Enable-SqlAlwaysOn -Path SQLSERVER:\SQL\SQL2K16W01\DEFAULT -force
Enable-SqlAlwaysOn -Path SQLSERVER:\SQL\SQL2K16W02\DEFAULT -force
Enable-SqlAlwaysOn -Path SQLSERVER:\SQL\SQL2K16W03\DEFAULT -force

-- Step 3 transport security : certificates

:connect SQL2K16W01
Use master
Create Master Key Encryption BY Password = '<#SQL2K16W01strongpassword!#>';

Create Certificate EndPointHADRCertificateSQL2K16W01
WITH Subject = 'EndPointHADR SQL2K16W01',
    START_DATE = '01/01/2016',
    EXPIRY_DATE = '01/01/2099';


CREATE ENDPOINT hadr_EndPoint
   STATE=STARTED
   AS TCP (LISTENER_PORT = 5022,LISTENER_IP = ALL)
   FOR DATA_MIRRORING 
   (
	 ROLE = ALL,
     AUTHENTICATION = CERTIFICATE EndPointHADRCertificateSQL2K16W01,
     ENCRYPTION = REQUIRED ALGORITHM AES
   );


BACKUP CERTIFICATE EndPointHADRCertificateSQL2K16W01 
 TO FILE = 'C:\Temp\EndPointCertificateSQL2K16W01.cer';
GO


:connect SQL2K16W02
Use master
Create Master Key Encryption BY Password = '<#SQL2K16W02strongpassword!#>';

Create Certificate EndPointHADRCertificateSQL2K16W02
WITH Subject = 'EndPointHADR SQL2K16W02',
       START_DATE = '01/01/2016',
       EXPIRY_DATE = '01/01/2099';


CREATE ENDPOINT hadr_EndPoint
      STATE=STARTED
      AS TCP (LISTENER_PORT = 5022,LISTENER_IP = ALL)
      FOR DATA_MIRRORING
      ( 
		 ROLE = ALL,
         AUTHENTICATION = CERTIFICATE EndPointHADRCertificateSQL2K16W02,
         ENCRYPTION = REQUIRED ALGORITHM AES
      );


BACKUP CERTIFICATE EndPointHADRCertificateSQL2K16W02 
TO FILE= 'C:\temp\EndPointCertificateSQL2K16W02.cer';
GO


	  
:connect SQL2K16W03
Use master
Create Master Key Encryption BY Password = '<#SQL2K16W03strongpassword!#>';

Create Certificate EndPointHADRCertificateSQL2K16W03
WITH Subject = 'EndPointHADR SQL2K16W03',
       START_DATE = '01/01/2016',
       EXPIRY_DATE = '01/01/2099';


CREATE ENDPOINT hadr_EndPoint
      STATE=STARTED
      AS TCP (LISTENER_PORT = 5022,LISTENER_IP = ALL)
      FOR DATA_MIRRORING
      ( 
		 ROLE = ALL,
         AUTHENTICATION = CERTIFICATE EndPointHADRCertificateSQL2K16W03,
         ENCRYPTION = REQUIRED ALGORITHM AES
      );
	  
	  

BACKUP CERTIFICATE EndPointHADRCertificateSQL2K16W03 
TO FILE= 'C:\temp\EndPointCertificateSQL2K16W03.cer';
GO

-- copy certificates backup files on other nodes
-- and create certificates from files

:connect SQL2K16W01
Use master
Create Certificate EndPointHADRCertificateSQL2K16W02
 From FILE = 'C:\Temp\EndPointCertificateSQL2K16W02.cer';
Create Certificate EndPointHADRCertificateSQL2K16W03
 From FILE = 'C:\Temp\EndPointCertificateSQL2K16W03.cer';
GO
  
 
:connect SQL2K16W02
Use master
Create Certificate EndPointHADRCertificateSQL2K16W01
 From FILE = 'C:\Temp\EndPointCertificateSQL2K16W01.cer';
Create Certificate EndPointHADRCertificateSQL2K16W03
 From FILE = 'C:\Temp\EndPointCertificateSQL2K16W03.cer';
GO 

:connect SQL2K16W03
Use master
Create Certificate EndPointHADRCertificateSQL2K16W01
 From FILE = 'C:\Temp\EndPointCertificateSQL2K16W01.cer';
Create Certificate EndPointHADRCertificateSQL2K16W02
 From FILE = 'C:\Temp\EndPointCertificateSQL2K16W02.cer';
GO
 

 -- Step 4 authentication : logins from certificates

:connect SQL2K16W01
Use master
CREATE LOGIN hadrLoginSQL2K16W02
 FROM CERTIFICATE EndPointHADRCertificateSQL2K16W02;
CREATE LOGIN hadrLoginSQL2K16W03
 FROM CERTIFICATE EndPointHADRCertificateSQL2K16W03;
GO



:connect SQL2K16W02
Use master
CREATE LOGIN hadrLoginSQL2K16W01
 FROM CERTIFICATE EndPointHADRCertificateSQL2K16W01;
CREATE LOGIN hadrLoginSQL2K16W03
 FROM CERTIFICATE EndPointHADRCertificateSQL2K16W03;
GO


:connect SQL2K16W03
Use master
CREATE LOGIN hadrLoginSQL2K16W01
 FROM CERTIFICATE EndPointHADRCertificateSQL2K16W01;
CREATE LOGIN hadrLoginSQL2K16W02
 FROM CERTIFICATE EndPointHADRCertificateSQL2K16W02;
GO



:connect SQL2K16W01
Use master
GRANT CONNECT ON ENDPOINT::hadr_EndPoint To hadrLoginSQL2K16W02
GRANT CONNECT ON ENDPOINT::hadr_EndPoint To hadrLoginSQL2K16W03
GO

 

:connect SQL2K16W02
Use master
GRANT CONNECT ON ENDPOINT::hadr_EndPoint To hadrLoginSQL2K16W03
GRANT CONNECT ON ENDPOINT::hadr_EndPoint To hadrLoginSQL2K16W01
GO
 

:connect SQL2K16W03
Use master
GRANT CONNECT ON ENDPOINT::hadr_EndPoint To hadrLoginSQL2K16W01
GRANT CONNECT ON ENDPOINT::hadr_EndPoint To hadrLoginSQL2K16W02
GO	  




-- Step 5  create a test database on primary replica
--         backup on primary and restore on secondary

:connect SQL2K16W01
Use Master
GO
CREATE Database DemoDB
GO

BACKUP DATABASE DemoDB
TO DISK = 'C:\temp\DemoDB.bak'
WITH INIT, COMPRESSION, STATS=10;
GO
BACKUP LOG DemoDB
TO DISK = 'C:\temp\DemoDB.trn'
WITH INIT, COMPRESSION, STATS=10;
GO

-- Copy backup files on secondary or use UNC path

:connect SQL2K16W02
Use Master
GO
RESTORE DATABASE [DemoDB] 
FROM  DISK = N'C:\temp\DemoDB.bak' 
WITH  NORECOVERY,  STATS = 5, REPLACE;
GO
RESTORE LOG [DemoDB] 
FROM  DISK = N'C:\temp\DemoDB.trn' 
WITH  NORECOVERY,  STATS = 5;
GO

:connect SQL2K16W03
Use Master
GO
RESTORE DATABASE [DemoDB] 
FROM  DISK = N'C:\temp\DemoDB.bak' 
WITH  NORECOVERY,  STATS = 5, REPLACE;
GO
RESTORE LOG [DemoDB] 
FROM  DISK = N'C:\temp\DemoDB.trn' 
WITH  NORECOVERY,  STATS = 5;
GO


-- Step 5  Create the availability group

:Connect SQL2K16W01
USE [master]
GO
CREATE AVAILABILITY GROUP [DemoAG]
WITH (	AUTOMATED_BACKUP_PREFERENCE = SECONDARY,
		DB_FAILOVER = OFF,
		DTC_SUPPORT = NONE)
FOR DATABASE [DemoDB]
REPLICA ON	N'SQL2K16W01' WITH (ENDPOINT_URL = N'TCP://SQL2K16W01.SQLServer.workgroup:5022', FAILOVER_MODE = AUTOMATIC, AVAILABILITY_MODE = SYNCHRONOUS_COMMIT, BACKUP_PRIORITY = 50, SECONDARY_ROLE(ALLOW_CONNECTIONS = READ_ONLY)),
			N'SQL2K16W02' WITH (ENDPOINT_URL = N'TCP://SQL2K16W02.SQLServer.workgroup:5022', FAILOVER_MODE = AUTOMATIC, AVAILABILITY_MODE = SYNCHRONOUS_COMMIT, BACKUP_PRIORITY = 50, SECONDARY_ROLE(ALLOW_CONNECTIONS = READ_ONLY)),
			N'SQL2K16W03' WITH (ENDPOINT_URL = N'TCP://SQL2K16W03.SQLServer.workgroup:5022', FAILOVER_MODE = AUTOMATIC, AVAILABILITY_MODE = SYNCHRONOUS_COMMIT, BACKUP_PRIORITY = 50, SECONDARY_ROLE(ALLOW_CONNECTIONS = READ_ONLY));
GO

:Connect SQL2K16W01
USE [master]
GO
ALTER AVAILABILITY GROUP [DemoAG]
ADD LISTENER N'VNN_DemoAG' (
WITH IP ( (N'192.168.1.165', N'255.255.255.0') ), 
	PORT=1433);
GO

:Connect SQL2K16W02
ALTER AVAILABILITY GROUP [DemoAG] JOIN;
GO

:Connect SQL2K16W03
ALTER AVAILABILITY GROUP [DemoAG] JOIN;
GO

:Connect SQL2K16W02
-- Wait for the replica to start communicating and then
ALTER DATABASE [DemoDB] SET HADR AVAILABILITY GROUP = [DemoAG];

GO

:Connect SQL2K16W03
-- Wait for the replica to start communicating and then
ALTER DATABASE [DemoDB] SET HADR AVAILABILITY GROUP = [DemoAG];
GO


-- Step 6  adding the routing URLs

ALTER AVAILABILITY GROUP [DemoAG]
 MODIFY REPLICA ON N'SQL2K16W01' 
 WITH (SECONDARY_ROLE (ALLOW_CONNECTIONS = READ_ONLY));

ALTER AVAILABILITY GROUP [DemoAG]
 MODIFY REPLICA ON N'SQL2K16W01' 
 WITH (SECONDARY_ROLE (READ_ONLY_ROUTING_URL = N'TCP://SQL2K16W01.SQLServer.workgroup:1433'));
GO

ALTER AVAILABILITY GROUP [DemoAG]
 MODIFY REPLICA ON N'SQL2K16W02' 
 WITH (SECONDARY_ROLE (ALLOW_CONNECTIONS = READ_ONLY));

ALTER AVAILABILITY GROUP [DemoAG]
 MODIFY REPLICA ON N'SQL2K16W02' 
 WITH (SECONDARY_ROLE (READ_ONLY_ROUTING_URL = N'TCP://SQL2K16W02.SQLServer.workgroup:1433'));
GO


ALTER AVAILABILITY GROUP [DemoAG]
 MODIFY REPLICA ON N'SQL2K16W03' 
 WITH (SECONDARY_ROLE (ALLOW_CONNECTIONS = READ_ONLY));

ALTER AVAILABILITY GROUP [DemoAG]
 MODIFY REPLICA ON N'SQL2K16W03' 
 WITH (SECONDARY_ROLE (READ_ONLY_ROUTING_URL = N'TCP://SQL2K16W03.SQLServer.workgroup:1433'));
 GO


-- Step 7  adding the load balancing routing list 

ALTER AVAILABILITY GROUP [DemoAG] 
MODIFY REPLICA ON N'SQL2K16W01'
WITH (PRIMARY_ROLE (READ_ONLY_ROUTING_LIST=(('SQL2K16W02','SQL2K16W03'),'SQL2K16W01')));
GO

ALTER AVAILABILITY GROUP [DemoAG] 
MODIFY REPLICA ON N'SQL2K16W02' 
WITH (PRIMARY_ROLE (READ_ONLY_ROUTING_LIST=(('SQL2K16W01','SQL2K16W03'),'SQL2K16W02')));
GO

ALTER AVAILABILITY GROUP [DemoAG] 
MODIFY REPLICA ON N'SQL2K16W03' 
WITH (PRIMARY_ROLE (READ_ONLY_ROUTING_LIST=(('SQL2K16W01','SQL2K16W02'),'SQL2K16W03')));
GO


-- Step 7 : test from PowershellISE
--          run multiple times
SQLCMD.exe -S VNN_DemoAG.SQLServer.workgroup -dDemoDB -Usa -PPassword1  -K ReadOnly -Q 'SELECT @@servername'










/*
references :
https://blogs.msdn.microsoft.com/clustering/2015/08/17/workgroup-and-multi-domain-clusters-in-windows-server-2016/

*/