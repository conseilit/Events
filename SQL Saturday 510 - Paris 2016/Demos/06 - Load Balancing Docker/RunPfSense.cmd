sqlcmd -U sa -P thepassword2# -S 192.168.1.253,1433 -q "SELECT CONVERT(varchar(50),SERVERPROPERTY('MachineName')),* FROM [MultiplexTarget].[dbo].[TargetTable]"
exit
