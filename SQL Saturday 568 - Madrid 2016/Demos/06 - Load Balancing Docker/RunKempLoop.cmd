sqlcmd -U sa -P thepassword2# -S 192.168.1.128,1433 -Q "SET NOCOUNT ON SELECT CONVERT(varchar(50),SERVERPROPERTY('MachineName')) As MachineName,* FROM [MultiplexTarget].[dbo].[TargetTable]" -h -1
exit
