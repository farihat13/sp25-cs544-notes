# Docker basics

## Install docker

[https://docs.docker.com/engine/install/ubuntu/](https://docs.docker.com/engine/install/ubuntu/)


`docker run hello-world` check if docker installed successfully or not

`sudo systemctl start docker` to run docker daemon

`sudo systemctl enable docker` to ensure Docker starts when your system boots

`sudo systemctl status docker` checked docker status

`docker info` or `docker version` to check if you get any response or if it shows any error messages.

**In wsl, I need to run windows docker desktop to access it from wsl.**

### To avoid needing to run every Docker command with root

`sudo groupadd docker`

`sudo usermod -aG docker $USER`

`newgrp docker`


## Basic Commands

### images 

`docker pull ubuntu:23.10` pulls a docker image from docker hub, 23.10 is the tag, the default tag is latest

Docker Hub [https://hub.docker.com/](https://hub.docker.com/)

`docker images` lists all the docker images

`docker tag ubuntu:23.10 ubuntu:fti` creates a soft link `ubuntu:fti` to existing image `ubuntu:23.10`

`docker rmi ubuntu:23.10` deletes the image ubuntu:23.10


### containers

`docker run ubuntu [COMMAND]` will create a container from this image `ubuntu:latest` and run the COMMAND inside that container and will exit
e.g. `docker run ubnuntu echo hello`

`docker run -it ubuntu bash`
-i means interactive
-t allocates a pseudo-tty

`docker ps` lists running containers

`docker ps -a` lists all containers running and stopped

`docker rm [NAME]` removes a container with the NAME

`docker rm [CONTAINER ID]` removes a container with the CONTAINER ID

`docker ps -aq` only shows container IDs

`docker rm $(docker ps -qa)` or `docker stop $(docker ps -aq)`

`rm` for containers, 
`rmi` for images

`docker run ubuntu sh -c "echo hello; sleep 3; echo bye"` how to run multiple commands inside a container; useful for debugging

`docker run -d ubuntu sh -c "echo hello; sleep 300; echo bye"` in detach mode; useful for debugging

`docker logs [NAME]` checks the status of the container with NAME; useful for debugging detached containers

`docker logs -f [NAME]` follow the log of detached container; useful for debugging

`docker run [IMAGE] [COMMAND]` runs a new command in a new container; if the image does not exist locally, it first pulls it

`docker exec [NAME] [COMMAND]` runs a new command in an existing container
e.g., 
    `docker exec -it optimistic_euler bash`
    inside it, run `ps ax`
; useful for debugging

`docker kill [NAME]` kills the given container


### system stats

`docker system df` lists the resouces used by docker

`docker system prune` cleans docker cache and dangling images

`docker system prune -af` cleans all images without a running container


`docker stats` shows details of the resources used by docker containers



## An example `Dockerfile`
 
```docker
FROM ubuntu:23.10
RUN apt-get update
RUN apt-get install unzip
```

`docker build . -t demo` creates an image demo:latest from the `Dockerfile` present in the current directory

`docker run --name my_container demo` runs a container `my_container    ` from the image `demo`


### `COPY`, `WORKDIR` and `CMD` 

`COPY [FROM_MY_COMPUTER] [TO_CONTAINER]`
[TO_CONTAINER] = absolute path inside docker

`WORKDIR [PATH]` sets the working directory for any `RUN`, `CMD`, `COPY` that follow it. If the WORKDIR doesn't exist, it will be created.

```docker
FROM ubuntu:23.10
RUN apt-get update && apt-get install -y unzip python3 python3-pip
RUN pip3 install pandas --break-system-packages
COPY hello.py /var/run/hello.py
WORKDIR /var/run
#CMD ["python3", "/var/run/hello.py"]
CMD python3 /var/run/hello.py
```

## Running jupyterlab inside docker


```docker
FROM ubuntu:23.10
RUN apt-get update && apt-get install -y unzip python3 python3-pip
RUN pip install pandas==2.1.0 jupyterlab==4.0.3 matplotlib --break-system-packages
RUN pip3 install torch==2.0.1 --index-url https://download.pytorch.org/whl/cpu --break-system-packages
RUN pip3 install tensorboard==2.14.0 --break-system-packages
CMD python3 -m jupyterlab --no-browser --ip=0.0.0.0 --port=5440 --allow-root --NotebookApp.token=''
```

$ `python3 -m jupyterlab --no-browser --ip=0.0.0.0 --port=5440 --allow-root --NotebookApp.token=''`
starts a JupyterLab server, 

- `--no-browser`: don't open web browser
- `--ip=0.0.0.0`: IP address that the JupyterLab server will listen on. Setting it to 0.0.0.0 allows it to listen on all IP addresses, which means it can accept connections from any IP address.
- `--port=5440`: port number that JupyterLab will listen on
- `--allow-root`: allow jupyter lab to run as the root user
- `--NotebookApp.token=''`: no password


### Run in my local machine

1. $ `docker build . -t demo`
2. $ `mkdir ./nb`

3. $ `docker run -d -p 5441:5440 -v ./nb:/nb demo`

    - `-d` run the container in detached mode

    - `-p 5441:5440` maps port 5441 of host machine to port 5440 of container

    - `-v ./nb:/nb` tells docker to create a volume that maps the `./nb` directory of my host machine to the `/nb` directory inside the Docker container. Any files in the `./nb` directory of the host machine can be accessed from the `/nb` directory inside the Docker container, and vice versa.

    - to verify JupyterLab is running inside the container
        - $ `docker ps`
        - $ `docker exec -it [NAME] bash` (go inside the container)
        - inside the container, 
            - $ `lsof -i` (list open files, `-i` means only list Internet network files) will show python3 running on port 5440 

4. If I go to http://localhost:5441/lab in my browser, I can access JupyterLab running inside the docker.

