sqlcmd -U sa -P Password1! -S 192.168.1.128,1433 -q "SET NOCOUNT ON SELECT CONVERT(varchar(50),SERVERPROPERTY('MachineName')) As MachineName,* FROM [MsCloudSummit2017].[dbo].[TargetTable]" -h -1
exit
