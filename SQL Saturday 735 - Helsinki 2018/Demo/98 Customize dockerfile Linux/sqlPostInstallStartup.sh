#wait for the SQL Server to come up
sleep 20s

#run the setup script to create the DB and the schema in the DB
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -PsaTemp0r@ryP@ssw0rd -d master -i sqlPostInstallScript.sql

# change the Temporary SA Password
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -PsaTemp0r@ryP@ssw0rd -d master -Q "sp_password NULL, '$1', 'sa'"
