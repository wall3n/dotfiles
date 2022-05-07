#!/bin/bash

searchParam=$1

function docker_hub {
    export DOCKER_USER='wall3n'
    passwd='masalfesio4'
    export DOCKER_PASSW=$passwd
    docker login -u $DOCKER_USER -p $DOCKER_PASSW
}

function github_registry {
    export GITHUB_USER='wall3n'
    export GITHUB_PASSWD=$(cat /home/wall3n/workspace/credentials/dockerkey.txt | head -1)
    docker login ghcr.io -u $GITHUB_USER -p $GITHUB_PASSWD
}

function command_not_found_handle {
    echo "Service not found: $searchParam"
    return 127
}

if [ $1 = 'docker' ]
then
    echo 'Loggin on Docker'
    docker_hub
elif [ $1 = 'github' ]
then
    echo 'Loggin on the Github Package Registry'
    github_registry
else
    command_not_found_handle
fi
