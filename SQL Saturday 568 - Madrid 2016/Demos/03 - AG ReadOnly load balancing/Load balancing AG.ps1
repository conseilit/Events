<#============================================================================
  File: Load balancing on read_only routing list between workgroup secondaries     
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
============================================================================#>

cls


SQLCMD.exe -S VNN_DemoAG.SQLServer.workgroup -dDemoDB -USQLLogin -Ppwd  -K ReadOnly -Q 'SELECT @@servername'

cd "C:\Users\administrator.CONSEILIT\Desktop\Demos SQL Saturday 510\03 - AG ReadOnly load balancing"


.\50Clients.cmd

