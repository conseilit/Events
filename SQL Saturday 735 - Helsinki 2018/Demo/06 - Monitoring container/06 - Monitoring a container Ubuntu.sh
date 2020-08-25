#==============================================================================
#
#  Summary:  SQLSaturday Helsinki #735 - 2018
#  Date:     05/2018
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


# adding healthcheck at design time 

    # Create a monitoring folder and
    # Create a docker file
    # Insert code

    FROM microsoft/mssql-server-linux
    HEALTHCHECK --interval=5s CMD ["/opt/mssql-tools/bin/sqlcmd", "-Usa", "-PPassword1!", "-Q", "select 1"]

    # Then create the image 
    cd monitoring
    docker build -t sqlexpress-new-image .

    # and run the container
    docker run -d -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=Password1!'  -p14331:1433 sqlexpress-new-image

    # list running containers
    docker ps





# adding healthcheck at runtime
    docker run  --detach \
                --name sqlsaturday \
                --hostname sqlsaturday \
                --env 'MSSQL_PID=developer' \
                --env 'ACCEPT_EULA=Y' \
                --env 'SA_PASSWORD=Password1!' \
                --health-cmd '/opt/mssql-tools/bin/sqlcmd -Usa -PPassword1! -Q "select 1"' \
                --health-interval '5s' \
                --publish 14339:1433 microsoft/mssql-server-linux

    # list running containers
    docker ps

    docker inspect -f '{{json .State.Health.Status}}' sqlsaturday



# cleanup

# Stops and remove all containers
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)

# remove the image
docker rmi sqlexpress-new-image
