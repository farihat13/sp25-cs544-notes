#!/bin/bash
set -ex

# stop all running containers
docker stop $(docker ps -q)
# remove all containers
docker rm -f $(docker ps -aq)
# remove all images
docker rmi -f $(docker images -aq)
# remove all unused volumes
docker volume prune -f
# remove all networks
docker network prune -f
# remove all build caches
docker builder prune -a -f
# remove all unused system resource
docker system prune -a -f --volumes
