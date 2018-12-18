#!/bin/bash

# utlity function for pointing out success/failure
function finish {
   if [ "$done" = true ]; then
      echo "$(tput setaf 2)Teardown was successful!$(tput sgr 0)"
   else
      echo "$(tput setaf 1)Teardown failed!$(tput sgr 0)"
      exit 1
   fi
}

function info {
    echo "Usage:"
    echo "-m    mode [delete, drop, data]"
    echo "-c    container identifier [part of name, image etc]"
    echo "-i    image identifier [part of image name]"
    echo "-n    network identifier"
    echo "-p    path to dir to delete"
    echo "-d    sets empty val to every param"
    echo "Requirenments:"
    echo "-m delete    -c \"val\" -n \"val\" "
    echo "-m drop    -c \"val\" -i \"val\" -n \"val\" "
    echo "-m data    -c \"val\" -n \"val\" -p \"val\" "
    echo "-m [delete/drop/data]    -d"
    
}

function containers {
    # Remove tech docker containers
    dockerContainers=$(docker ps -a | grep -v 'CONTAINER' | grep "$1" | awk '{print $1}')
    if [ "$dockerContainers" != "" ]; then
       echo "Deleting existing docker \"$1\" containers ..."
       docker rm -f $dockerContainers > /dev/null
    fi
}

function images {
    # Remove images
    dockerImages=$(docker images | grep -v 'IMAGE' | grep "^$1/" | awk '{print $3}')
    if [ "$dockerImages" != "" ]; then
        echo "Deleting existing \"$1\" images..."
        docker rmi -f $dockerImages > /dev/null
    fi
}


function volumes {
    # Remove unused volumes
    volumes=$(docker volume ls -qf dangling=true)
    if [ "$volumes" != "" ]; then
        echo "Removing unused volumes ..."
        docker volume rm $volumes > /dev/null
    fi
}

function networks {
    # Remove networks
    networks=$(docker network ls | grep -v 'NETWORK\|bridge\|none\|host' | grep "$1" | awk '/ / { print $1 }')
    if [ "$networks" != "" ]; then
        echo "Deleting existing network \"$1\"..."
        docker network rm $networks > /dev/null
    fi
}

function directory {
    if [ -d $1 ]; then
       echo "Cleaning up the data directory from previous run at \"$1\"."
       rm -rf $1
    fi
}

function main {
    set -e
    trap finish EXIT
    done=false

    while getopts :m:c:i:n:p:d option; do
        case ${option} in
            m) _mode=${OPTARG};;
            c) _expr=${OPTARG};;
            i) _img=${OPTARG};;
            n) _net=${OPTARG};;
            p) _path=${OPTARG};;
            d)
                _expr=""
                _img=""
                _net=""
                _path=""
                ;;
            ?) 
                echo "$(tput setaf 1)Unknown flag: \"${OPTARG}\" Exiting!$(tput sgr 0)"
                info
                exit 1
                ;;
        esac
    done

    #run
    case "$_mode" in
        "delete") 
            containers $_expr
            volumes
            networks $_net
            ;;
        "drop")
            containers $_expr
            images $_img
            volumes
            networks $_net
            ;;
        "data")
            containers $_expr
            volumes
            networks $_net
            directory $_path
            ;;
        *)
            echo "$(tput setaf 1)Wrong mode \"$_mode\" configuration. Exiting!$(tput sgr 0)"
            info
            exit 1
            ;;
    esac
    done=true
}

"$@"


