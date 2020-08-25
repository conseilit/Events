ALTER EVENT SESSION [system_health] 
ON SERVER STATE = STOP
GO
ALTER EVENT SESSION [system_health] ON SERVER 
DROP TARGET package0.event_file;
GO 
ALTER EVENT SESSION [system_health] ON SERVER 
ADD TARGET package0.event_file 
	(SET FILENAME=N'system_health.xel',
		max_file_size=(25), 
		max_rollover_files=(20)
	) 
GO
ALTER EVENT SESSION [system_health] 
ON SERVER STATE = START
GO

Alter database msdb modify file (name=MSDBData, size=512MB, filegrowth=64MB);
GO
Alter database msdb modify file (name=MSDBLog,	 size=64MB,	 filegrowth=64MB);
GO


CREATE SERVER ROLE dba;
GO
CREATE LOGIN dba1
WITH PASSWORD = 'dba1',
CHECK_POLICY = OFF;
GO
ALTER SERVER ROLE dba ADD MEMBER dba1;
GO
GRANT CONTROL SERVER TO dba;
GO

CREATE LOGIN DockerHealthCheck With Password = 'DockerHealthCheck', CHECK_POLICY=OFF;
GO
GRANT VIEW SERVER STATE TO [DockerHealthCheck];
GO


