sqlcmd -U sa -P Password1! -S 192.168.1.253,1433 -q "SELECT CONVERT(varchar(50),SERVERPROPERTY('MachineName')),* FROM [MsCloudSummit2017].[dbo].[TargetTable]"
exit
