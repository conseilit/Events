sqlcmd -U sa -P thepassword2# -S 192.168.1.128,1433 -q "PRINT CONVERT(varchar(50),SERVERPROPERTY('MachineName'))"
exit
