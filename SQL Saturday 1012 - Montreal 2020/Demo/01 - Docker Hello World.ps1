#==============================================================================
#
#  Event   : SQL Saturday #1012 - Montreal 2020
#  Session : From Docker to Big Data Clusters - a new era for SQL Server
#  Date    : 11/2020
#
#  ----------------------------------------------------------------------------
#  Written by : Christophe LAPORTE, SQL Server MVP / MCM
#  Blog       : http://conseilit.wordpress.com
#  Email      : conseilit@outlook.com
#  Twitter    : @ConseilIT
#  
#  You may alter this code for your own *non-commercial* purposes. You may
#  republish altered code as long as you give due credit.
#  
#  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
#  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
#  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
#  PARTICULAR PURPOSE.
#==============================================================================

# Connect to Docker host
ssh chris@192.168.1.140


# Survival kit : Docker commands
sudo docker

## Display Docker version
sudo docker version

## Docker images CLI commands
sudo docker image ls  # <=>  docker images

# Running my first container
sudo docker run hello-world

# Run interactively an ubuntu container
sudo docker run -it ubuntu bash

## Docker container CLI commands
sudo docker container ls       #  <=>  docker ps
sudo docker container ls --all #  <=>  docker ps -a




# cleanup
sudo docker stop $(sudo docker ps -a -q)
sudo docker rm $(sudo docker ps -a -q)
sudo docker rmi ubuntu
sudo docker rmi hello-world
