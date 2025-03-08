# Docker basics

## Install docker

[Official Installation Guide](https://docs.docker.com/engine/install/ubuntu/)

Verify after installation:  

```bash
docker run hello-world
```

Check Docker version and system info:  

```bash
docker info  
docker version  
```

Start and Enable Docker:  

```bash
sudo systemctl start docker     # Start Docker daemon  
sudo systemctl enable docker    # Start Docker on system boot  
sudo systemctl status docker    # Check Docker status  
```

Avoid using `sudo` for every Docker command:

```bash
sudo groupadd docker          # Create 'docker' group  
sudo usermod -aG docker $USER # Add current user to 'docker' group  
newgrp docker                 # Refresh group membership  
```

### Using Docker in WSL

If using **WSL**, make sure **Docker Desktop** is running on Windows to access it from WSL.

## Basic Commands

### Images

```bash
docker pull ubuntu:23.10    # Pull an image from Docker Hub, tag 23.10 (default tag: latest)  
docker images               # List all images  
docker tag ubuntu:23.10 ubuntu:fti  # Creates a soft link `ubuntu:fti` to existing image `ubuntu:23.10`  
docker rmi ubuntu:23.10     # Remove the image  
```

### Containers

```bash
docker run [IMAGE] [COMMAND] # Create a container from the image, if the image does not exist locally, it first pulls it, then run the COMMAND inside that container and exit

docker run ubuntu [COMMAND] # Create a container from image `ubuntu:latest`, run the COMMAND inside that container and exit
docker run ubnuntu echo hello

docker run -it ubuntu bash  # Run in interactive mode, -i:  interactive, -t: allocates a pseudo-tty

docker ps          # List running containers  
docker ps -a       # List all (running + stopped) containers  

docker rm [CONTAINER_NAME]  # Remove a container by name  
docker rm [ID]    # Remove a container by ID  
docker ps -aq     # List only container IDs  

docker rm $(docker ps -qa)   # Remove all stopped containers  
docker stop $(docker ps -aq) # Stop all running containers  
```

Run multiple commands in a container

```bash
docker run ubuntu sh -c "echo hello; sleep 3; echo bye"
docker run -d ubuntu sh -c "echo hello; sleep 300; echo bye" # -d: detached mode
```

### Debugging containers

```bash
docker logs [CONTAINER_NAME]       # View container logs
docker logs -f [CONTAINER_NAME]    # Follow container logs live  
docker exec [CONTAINER_NAME] [COMMAND] # Run a new command in an existing container
docker exec -it [CONTAINER_NAME] bash  # Open shell inside a running container  
docker kill [CONTAINER_NAME]       # Kill a running container  
```

### System stats

```bash
docker system df            # Show disk usage by docker
docker system prune         # Clean up docker cache and dangling images  
docker system prune -af     # Remove all unused images  
docker stats                # Show real-time container stats  
```

## An example `Dockerfile`

```docker
FROM ubuntu:23.10
RUN apt-get update
RUN apt-get install unzip
```

Build and run:

```bash
docker build . -t demo   # Create an image `demo:latest` from `Dockerfile` present in the current directory
docker run --name my_container demo  # Run a container `my_container` from the image `demo`
```

### Copying files, setting working dirs, and running commands in a Dockerfile

`COPY [FROM_MY_COMPUTER] [TO_CONTAINER]`

`WORKDIR [PATH]` sets the working directory for any `RUN`, `CMD`, `COPY` that follow it.
If the WORKDIR doesn't exist, it will be created.

```docker
FROM ubuntu:23.10
RUN apt-get update && apt-get install -y unzip python3 python3-pip
RUN pip3 install pandas --break-system-packages
COPY hello.py /var/run/hello.py
WORKDIR /var/run
CMD ["python3", "/var/run/hello.py"]
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

Start a JupyterLab server

```bash
python3 -m jupyterlab --no-browser --ip=0.0.0.0 --port=5440 --allow-root --NotebookApp.token=''
```

- `--no-browser`: don't auto open web browser
- `--ip=0.0.0.0`: IP address that the JupyterLab server will listen on. Setting it to 0.0.0.0 allows it to listen on all IP addresses, which means it can accept connections from any IP address.
- `--port=5440`: run on port 5440
- `--allow-root`: allow jupyter lab to run as root
- `--NotebookApp.token=''`: no password

### Running JupyterLab in my local machine using Docker

```bash
docker build . -t demo  # Build the image with container-name demo
mkdir ./nb              # Create a volume for notebooks  
docker run -d -p 5441:5440 -v ./nb:/nb demo # Run the Container  
```

- `-d`: run the container in detached mode
- `-p 5441:5440`: map host port 5441 to container port 5440  
- `-v ./nb:/nb`: mount host (local) `./nb` directory into `/nb` inside container, any files in the `./nb` directory of the host machine can be accessed from the `/nb` directory inside the Docker container, and vice versa.

Verify JupyterLab is Running

```bash
docker ps   
docker exec -it [CONTAINER_NAME] bash  # Access the running container  
lsof -i  # list open files, -i: list only Internet network files. will show python3 running on port 5440 
```

Now, to access the JupyterLab running inside docker, open <http://localhost:5441/lab> in my browser.
