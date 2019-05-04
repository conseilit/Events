#==============================================================================
#
#  Summary:  SQLSaturday Paris #762 - 2018
#  Date:     07/2018
#
#  ----------------------------------------------------------------------------
#  Written by Christophe LAPORTE, SQL Server MVP / MCM
#	  Blog    : http://conseilit.wordpress.com
#	  Twitter : @ConseilIT
#  
#  You may alter this code for your own *non-commercial* purposes. You may
#  republish altered code as long as you give due credit.
#  
#  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
#  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
#  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
#  PARTICULAR PURPOSE.
#==============================================================================

# enable the container feature
Install-Module -Name DockerMsftProvider -Repository PSGallery -Force
Install-Module -Name DockerMsftProvider -Force

# install the latest version of Docker
Install-Package -Name docker -ProviderName DockerMsftProvider -Force

# check if reboot needed
(Install-WindowsFeature Containers).RestartNeeded

# If so restart Windows
Restart-Computer -Force

# /!\ Pulling Windows Core image takes a while (writting to disk / latency)
docker pull microsoft/windowsservercore
docker images

<#  # Need upgrade ?
    # Check the installed version 
    Get-Package -Name Docker -ProviderName DockerMsftProvider

    # Check the current version of Docker 
    Find-Package -Name Docker -ProviderName DockerMsftProvider

    # If needed, upgrade Docker package
    Install-Package -Name Docker -ProviderName DockerMsftProvider -Update -Force
    Start-Service Docker

  #>