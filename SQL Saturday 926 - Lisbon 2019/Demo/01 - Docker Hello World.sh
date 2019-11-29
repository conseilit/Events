#==============================================================================
#
#  Summary:  SQLSaturday Lisbon #926 - 2019
#  Date:     11/2019
#
#  ----------------------------------------------------------------------------
#  Written by Christophe LAPORTE, SQL Server MVP / MCM
#	Blog    : http://conseilit.wordpress.com
#	Twitter : @ConseilIT
#  
#  You may alter this code for your own *non-commercial* purposes. You may
#  republish altered code as long as you give due credit.
#  
#  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
#  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
#  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
#  PARTICULAR PURPOSE.
#==============================================================================


# Survival kit : Docker commands
docker

## Display Docker version and info
docker version
docker info

## Docker images CLI commands
docker image --help
docker image ls  # <=>  docker images

## Docker container CLI commands
docker container --help
docker container ls       #  <=>  docker ps
docker container ls --all #  <=>  docker ps -a

# Running my first container
docker run hello-world

