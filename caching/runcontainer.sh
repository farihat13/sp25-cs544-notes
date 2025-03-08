#!/bin/bash

image_name="demo"
container_name="demo"
# docker build -t $image_name .

# Run a Docker container 
# detached mode
# memory limit of 500 megabytes
# Map port 5440 of the container to port 5440 of the host
# Mount the host dir ./nb to the container dir /nb
# Name the container
# docker run -d -m 500m -p 5440:5440 -v ./nb:/nb --name $container_name $image_name               
docker run -d -p 5440:5440 -v ./nb:/nb --name $container_name $image_name               
