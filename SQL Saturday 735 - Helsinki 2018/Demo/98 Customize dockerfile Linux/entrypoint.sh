
#start the postinstall script then start the sqlserver
./sqlPostInstallStartup.sh "$1" & /opt/mssql/bin/sqlservr
