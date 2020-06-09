#==============================================================================
#
#  Summary:  PowerSaturday Online 2020
#  Date:     06/2020
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


ssh Christophe@52.184.221.44 

# Survival kit : Docker commands
docker

## Display Docker version and info
sudo docker version
sudo docker info

## Docker images CLI commands
sudo docker image --help
sudo docker image ls  # <=>  docker images

## Docker container CLI commands
sudo docker container --help
sudo docker container ls       #  <=>  docker ps
sudo docker container ls --all #  <=>  docker ps -a

# Running my first container
sudo docker run hello-world

sudo docker ps -a

sudo docker stop $(sudo docker ps -a -q)
sudo docker rm $(sudo docker ps -a -q)

sudo docker images
sudo docker rmi hello-world

exit