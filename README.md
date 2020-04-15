Loader is a script which pulls Docker image for SweRV Support Package (SSP), creates the Docker container which contains built SSP packages and creates an interactive terminal connected to the Docker container.

# Docker introduction

Docker is a platform which enables its users to create isolated environments. The main components of Docker are:

* Docker image - template containing instructions for creation of Docker container. Typically, Docker image is based on another Docker image, and modifies the base image with set of instructions.
* Docker container - running instance of Docker image. Docker containers can be created, started, stopped, moved or deleted. Docker containers are defined by its image and configuration options used when creating the container.

More on Docker basics can be read on [Docker overview].

# Getting started

## Install Docker

On Fedora/CentOS/RHEL OS:

`$ sudo yum install docker`

On Debian/Ubuntu:

`$ sudo apt install docker`

Alternatively you can install Docker manually using [Docker installation guide].

## Configuring Docker Host

Before running loader script, Docker Host must be configured properly first. Docker Host is a machine, physical or virtual, which runs the Docker Daemon and accepts requests from Docker clients (users). All docker operations, including container start, are executed on this machine.
In case you will be running SSP on your local computer and you have root permission, then everything is already configured and you can start using SSP without any further Docker configuration

However if you want to make your Docker host available on your network, you will need to modify the Docker Daemon service configuration:

1. Open service configuration file `/lib/systemd/system/docker.service`
1. Find the key `ExecStart`
1. Add argument:
    * `--host 0.0.0.0:2376` for encrypted communication using TLS, or
    * `--host 0.0.0.0:2375` for un-encrypted communication - not recommended.
1. Save the configuration file and restart the docker service.
   
Now, all clients which would like to use this machine as a Docker Host, must define the environmental variable `DOCKER_HOST` so Docker will connect to the specified host.
For example, if the host's hostname is `dockerhost`, and it was configured to use TLS communication, the clients would need to run:

`$ export DOCKER_HOST=dockerhost:2376`

One can also specify host's IP address instead of hostname.


## Running Docker as non-root

To run the Docker commands as a non-root, the user must be added to a system group called `docker`. This can be done with command:

```bash
$ sudo groupadd docker
$ sudo usermod -aG docker <username>
```

After that the specified user must logout and login again for these actions to take effect.

## Starting SSP

Clone the repository and change directory to the repository root.
```
$ git clone git@github.com/Codasip/ssp-free.git
$ cd sspfree
```

Run the loader script. Any arguments passed to loader script are forwarded to Docker engine, more specifically to the `docker run` command. If you wish to view all available options, refer to the help using `docker run --help` command. 
To create and start SSP Docker container, run the loader with the following arguments:

`$ ./loader.sh -i -t --name <container_name>`

`-i` and `-t` arguments ensure that the container will be started in interactive mode. `--name` defines the identifier which can be later used to reference the started container. Note that the name must be unique for each container.

If you want to start the Docker container in the background, run the loader script as follows:

`$ ./loader.sh -d -t --name <container_name>`

After running the loader, you will be logged in as user `sspuser`. This user is added to sudoers, so you can simply install any new software or perform most of the operations with leveraged privileges.

### SSP users and credentials

| Username   | Password |
| ---------- |:--------:| 
| sspuser    | sspuser  |
| root       | root     |

### Updating SSP image

Loader takes SSP Docker image from the `loader.cfg` file which is in the same directory as loader script. To use different image than the default one, update the image reference in `loader.cfg`. To display all available versions of the SSP, you can use our Docker registry at https://ssp-docker-registry.codasip.com.

To see available versions, go to https://ssp-docker-registry.codasip.com/explore and enter the name of SSP docker image. For free distribution, the SSP image name is `distrib-ssp-seh1-free`.

Then you can click on the version you want to use, which will copy `docker pull` command into your clipboard. In order to use that SSP Docker image, paste the image reference from your clipboard to `loader.cfg` file.

# Docker container interaction

## Connect via SSH

SSP container starts SSH daemon on startup. In order to connect to container via SSH, you need to forward a port from your Docker host to the container. This can be done when running loader script.

`$ ./loader.sh -p <host_port>:22 [...]`

Then you can connect to the container with command:

`$ ssh -p <host_port> sspuser@<host_ip>`

SSP has even preinstalled the X-Server, therefore you are able to run window applications via SSH. To connect to server with X-server support, run:

`$ ssh -X -p <host_port> sspuser@<host_ip>`

## Mounting drives

Docker supports mounting a drive directly from host into the Docker container. This is very convenient when you want to share the workspace between host machine and any container.
You can specify as many drives as you desire.

`$ ./loader.sh -v <host_path>:<container_path> [...]`

## Copy files between host and running container

There are two ways how to copy files into running container:

1. Network copying - To copy over network, you can use `scp` command. Note that Docker container must be already started with forwarded SSH port (22).
2. Host to container copying - Docker allows to copy files directly from Docker host into the container and vice versa. To do this, use the command [docker cp]. Note that to reference the container you must use the `container_name` specified by `--name` argument which can be passed to loader script.

## Restarting container

On container exit, its persistent data are kept in the stopped container. The container can be started again using command `docker start <container_name>`.

To attach the terminal to started container, run the command:

`$ docker exec -i -t <container_name> bash`

# Frequently asked questions

## I cannot run any window applications, for instance Eclipse IDE, in the SSP. What should I do?

Running windows applications directly in the SSP terminal is not possible as Docker container does not have any display attached. However, window applications can be ran using the combination of SSH and X Server. To enable X Server within SSH connection, you need to pass argument `-X` to the SSH command, for instance.

`$ ssh -X -p <forwarded_port> sspuser@localhost`

Then you can open any window application and it will use the Window System of your host.

## I cannot connect to SSP via SSH, what might cause it?

There might be multiple reasons why the SSH connection does not work properly:

1. Your firewall is blocking the connection establishment. Try to check your firewall settings.
1. SSP container does not have forwarded port from host to container. To forward the port, please see the `Connect via SSH` section.
1. The port you forwarded to container is already used by another service. You can use `nmap` or `netstat` utilities to see the ports that are already in use.
1. There is another SSP container running on your host with the same port specified.
2. SSH daemon is not running in the SSP container. Run command `$ ps aux | grep sshd` to check if daemon is running. If you cannot see the daemon running, you can start it manually by running command `$ /usr/sbin/sshd -D &`. The reason why it is not started may be that you have overridden the startup command of the SSP container.

## Is there a way how to share my changes in SSP with other people?

Yes! Docker is prepared for these situations. There are three options how to share your SSP workspace with other people.

First, they can connect to the SSP container via SSH, so all the changes you make will be immediately available to other people connected to the same container. This option is best to share you workspace between colleagues.

Second way is to connect to the running container via `docker` command. However this is possible only if other people have access to the host where the docker container is running. You will need to tell them the name of running the container which you would like to share with them. How to specify Docker container name is described in `Starting SSP` section. Then all they need to do is to run command:

`$ docker exec -it <container_name> /bin/bash`

Third option is to export your SSP container and send it to people you want and they will import it on their side, however by using this approach, they will only see the changes you made to SSP before the export. To export the container, run the following commands:

```bash
# Save container as an image which can be exported, pick the <image_name> of your choice
$ docker commit <container_name> <image_name>
$ docker save --output <destination> <image_name>
```
This exports the SSP container to `<destination>` you specify. Now you can send the generated file to anyone you want to share the SSP content with and all they need to do on their side is:

`$ docker load --input <destination>`

## How can I mount network drive in the SSP?

To mount the network drive you will need to install drivers for the filesystem which is used on your network drive. SSP docker already supports NFS network drives. However, to be able to mount these drives, you will need to leverage the Docker privileges as by default the SSP container is well isolated from the outer environment. To leverage the privileges, you need to start the SSP container by adding 
`--privileged` argument to loader script.

## I am unable to run services in the SSP. What can I do?

Unfortunately SSP Docker cannot run services as it does not have access to D-Bus. All daemons you want to have running in the SSP must be started manually.

[Docker overview]: https://docs.docker.com/engine/docker-overview/
[Docker installation guide]: https://docs.docker.com/install/
[docker cp]: https://docs.docker.com/engine/reference/commandline/cp/
