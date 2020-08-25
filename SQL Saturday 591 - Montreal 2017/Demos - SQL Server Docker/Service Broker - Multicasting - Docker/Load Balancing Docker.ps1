<#============================================================================
  File:     Load Balancing on Docker containers
  Summary:  MsCloudSummit 2017 - Paris
  Date:     01/2017
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


cd "C:\Users\administrator.CONSEILIT\Desktop\Demos MsCloudSummit 2017\Docker SQL Server\Service Broker - Multicasting - Docker"


.\50ClientsPfSense.cmd

.\50ClientsKemp.cmd


$i=1
while ($i -le 20) {
    .\50ClientsKempLoop.cmd
    $i++
}








$ie = New-Object -comObject InternetExplorer.Application
$ie.visible = $true
$ie.navigate('http://192.168.1.253/haproxy_listeners.php')
$ie
$ie.Document
$ie.Document.getElementById(“usernamefld”).value="admin" 
$ie.Document.getElementByID(“passwordfld”).value="pfsense" 
$ie.Document.getElementById(“login”).Click()


# http://192.168.1.253/haproxy_listeners.php
# admin / pfsense



$ie = New-Object -comObject InternetExplorer.Application
$ie.visible = $true
$ie.navigate('https://192.168.1.127/')
$ie
$ie.Document

# https://192.168.1.127/
# bal / Password1

