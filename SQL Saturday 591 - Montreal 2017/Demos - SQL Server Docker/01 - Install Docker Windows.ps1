<#============================================================================
  File:     
  Summary:  sqlsATURDAY 591 - Montreal 2017
  Date:     03/2017
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

Install-Module -Name DockerMsftProvider -Repository PSGallery -Force

Install-Package -Name docker -ProviderName DockerMsftProvider

Restart-Computer -Force


