# SweRV Support Package

## Introduction

### What is SweRV core

**SweRV EH1** Is a high-performance embedded RISC-V processor core (RV32IMC),
developed by [Western Digital](https://www.westerndigital.com/) and open-sourced
through [CHIPS Alliance](https://chipsalliance.org/). The RTL code of
SweRV EH1 is available free of charge on [GitHub](https://github.com/chipsalliance/Cores-SweRV).

### What is SweRV Support Package (SSP)

SweRV Support Package (SSP) is a collection of RTL code, software, tools, documentation
and other resources that are needed to implement designs for SweRV-based SoCs,
test them and write software that will run on such SoCs.

SSP is developed by Codasip GmbH, and its basic version is available for download and use free of charge. 

SSP is delivered in the form of a Docker image to ensure portability across various platforms and reliable execution of the provided tools. The initial download of
the SSP Docker image is accomplished through so called "loader script", available
in this repository.

There is a [Forum](https://forum.codasip.com/) to support SSP and SweRV core family users.

### What is Docker

"Docker is a set of platform as a service products that uses OS-level virtualization to deliver software in packages called containers. Containers are isolated from one another and bundle their own software, libraries and configuration files; they can communicate with each other through well-defined channels" (official Docker description).

In short, Docker is a containerization tool that allows to execute programs in isolated environments.

The main terms related to Docker are:

* _Docker container_ - An isolated Docker environment that can be regarded as lightweight "virtual machine". It is a running instance of Docker image. It has its own file system and processes executed in container that run in isolation from the rest of the host operating system.
* _Docker image_ - A snapshot (template) used to create a Docker container.

SSP is distributed as a Docker image.

Further introduction on Docker can be found in [Docker overview].

### What is SSP loader

SSP loader is a script that allows you to download SSP Docker image onto your
workstation and create a SSP Docker container from that image.

Note: SSP is currently supported on **Linux only**.

## Installing Docker

As SSP is distributed as a Docker image, please install Docker on your workstation,
if not installed already.

A recommended way to install Docker is to follow official guidelines - [Docker installation guide].

Alternatively, you can install Docker through the package manager of your Linux distribution.
However, this is not recommended as it may install an outdated version of Docker.  

On Debian Jessie/Debian Stretch/Ubuntu:

`$ sudo apt install docker`

On Debian Buster:

`$ sudo apt install docker.io`

On Fedora:

`$ sudo dnf install docker`

On CentOS/RHEL OS:

`$ sudo yum install docker`

If you intend to run SSP Docker directly on your own workstation, no further
configuration is needed. If it is required to run Docker containers on
a different host machine over the network, please refer to the "FAQ" section below -
[Configuring Docker Host](#configuring-docker-host).

### Running Docker as non-root

To run the Docker commands as a non-root, on some systems, it may be necessary for user to be a member of
a system group called `docker`. This can be done using these commands:

```bash
$ sudo groupadd docker
$ sudo usermod -aG docker <username>
```

After this operation, it is necessary to log-out this user and log back in
for the changes to take effect.

## Downloading SSP via loader.sh

Clone this repository and change to the directory with the cloned repository contents.

```bash
$ git clone https://github.com/Codasip/SweRV-Support-Package-free
$ cd SweRV-Support-Package-free
```

Run the loader script. Any arguments passed to loader script are forwarded to Docker engine, more specifically to the `docker run` command. If you wish to view all available options, refer to the help using `docker run --help` command.

To create and start SSP Docker container, run the loader with the following arguments:

`$ ./loader.sh -i -t --name <container_name> -p <host_port>:22`

`-i` and `-t` arguments ensure that the container will be started in interactive mode. This is the usual mode user runs the docker in, as opoosed to running docker in the background.  
`--name` defines the identifier which can be later used to reference the started container. Note that the name must be unique for each container.  

If you wish to start the Docker container in the background, run the loader script as follows:

`$ ./loader.sh -d -t --name <container_name>`

After running the loader, the SSP container will be created and started for you. The SSP environment is based on CentOS 7 Linux distribution.
You will be logged in as user with name `sspuser`. Note that `sspuser` can install software or perform privileged operations via `sudo`.

Note that loader script is supposed to be used only for the first time you run spp. In the following uses, user should be using common docker commands, described more in the detail [here](#example).

### User accounts in SSP Docker image

| Username | Password |
| :------: | :------: |
| sspuser  | sspuser  |
|   root   |   root   |

### Updating SSP image

SSP loader image reads the version of the SSP Docker image from the `loader.cfg` file which is located in the same directory as the loader script.  
To use different image than the default one, please update the image reference in `loader.cfg`. However, in typical cases when the latest relese of
the SSP image is required, `loader.cfg` needs not be edited.

To display all available versions of the SSP, please view our Codasip Docker registry. Visit [Explore Codasip public docker registry](https://ssp-docker-registry.codasip.com/explore) and enter the name of SSP docker image.
For free distribution, the SSP image name is `distrib-ssp-seh1-free`.

Then you can click on the version you want to use, which will copy `docker pull` command into your clipboard.
In order to use that SSP Docker image, paste the image reference from your clipboard to `loader.cfg` file (without the `docker pull`. )    

## Interaction with Docker container

### Connect via SSH

To execute graphical applications (GUI programs) from SSP, you need to be connected to SSP via SSH with X11 forwarding enabled.

The SSP container automatically starts SSH daemon on startup. In order to connect to the SSP container via SSH,
forward TCP port 22 from your Docker a certain port of the host system. This can be done when running the loader script.

`$ ./loader.sh -p <host_port>:22 [...]`

You can also enable the port forwarding anytime later, when starting new container created from saved Docker image.

SSP contains preinstalled X-Server, therefore you are able to run graphical applications via SSH.
To connect to server with X-server support, run the ssh client with argument `-X`:

`$ ssh -X -p <host_port> sspuser@<host_ip>`

### Mounting of volumes

Docker supports mounting a volume directly from host into the Docker container. This is very convenient when you want to share the workspace between host machine and any container.
You can specify as many volumes as you desire.

`$ ./loader.sh -v <host_path>:<container_path> [...]`

### Copy files between host and running container

There are three ways how to get files into running a container:

1. Network copying - To copy over network over a SSH connection, you can use `scp` command. Note that Docker container must be already started with forwarded SSH port (22).
2. Host to container copying - Docker allows to copy files directly from Docker host into the container and vice versa. To do this, use the command [docker cp]. Note that to reference the container you must use the `container_name` specified by `--name` argument which can be passed to loader script.
3. Mount external disk drive which can be used to share data between your host and the docker container.

### Restarting container

When the container exits, its persistent data are kept stored in the stopped container. The container can be started again using command `docker start <container_name>`.

To attach the terminal to a running container, use this command:

`$ docker exec -i -t <container_name> bash`

## Using container
 First step is to start the docker container. Before you proceed you have to consider following issues:
1. do I need shared project data ?
2. do I need to work with the FPGA board attached via USB to my host ?
3. do I need my favourite shell environment setup inside the container ?

Standard sspuser has got UID:GID 1000:1000. This can introduce some permissions problem or collisions in case you want to use mounted disk drive from your host or from the NAS. It is an advantage to create specific user with the desired UID:GID inside the container to avoid this problem.

Read/Write acces to the FPGA board attached to your host via USB is  granted to root:root by default. It means container default user `sspuser` will not be able to write (program) your FPGA. Note that the container does not support hot plug. Therefore you have to write rule file allowing user access for the UDEV daemon and then start your docker container to see the desired effect.

To get your favourite shell environment you have to source your prefered setup file(s) inside the container.

As can be seen, you may need to start container several times. Therefore it is desired to automate container initialization as much as possible. This can be achieved e.g. by uploading and executing your shell scripts.

### Example
You want to use container distrib-ssp-seh1-free:1.0.0
* allowing tunneling of ssh port 22 over your host to be able to connect to the container from the hosts inside your network
* with container access to the host USB to work with the FPGA board
* to mount network or host disk drive

docker run -it --rm --privileged -p 22 ssp-docker-registry.codasip.com/distrib-ssp-seh1-free:1.0.0

## SSP - first steps

This section helps you with the first steps with the SSP.

### SSP initialization

After you have started the SSP container and connected to this container (either through direct terminal access
or via SSH `ssh -X sspuser@<container IP>`), please run Codasip package manager to finalize installation:

`$ cpm init`

This commands creates the directory structure of SSP and unpacks all software and resources.

You may be asked for the path to your GNU toolchain and Vivado installation directories and their versions.
This information is used to generate appropriate environment modules properly. If you are not going to use environment modules,
just press Return to continue. When `cpm init` command completes, SSP is ready to be used.

### SSP Documentation

For further steps with SSP, please refer to documents located in `/prj/ssp/doc`.
The number of documents may vary depending of the packages sets you have installed.
Evince PDF viewer included in the container which may be used to read the documentation
shipped with SSP:

`$ evince path/to/seh1.pdf`

### Overview of SSP documentation

#### seh1.pdf

This document is a modified version of original SweRV EH1 Core TM documentation
from release 1.5. It contains base description of SEH1 directory tree with
quick-start examples how to configure SweRV EH1 and how to run simple
"Hello world" using Verilator simulator.

#### seh1_RISC-V_SweRV_EH1_PRM.pdf

This document is a comprehensive Programmer's Reference Manual prepared by Western Digital.
It contains SweRV EH1 core overview, memory maps, register description, power management
debug control, ICache control, Interrupts etc.

#### seh1_SweRV_CoreMark_Benchmarking.pdf

This document by Western Digital contains description and setup that can be
used to run benchmarks for SweRV EH1 core.

#### swervolf.pdf

This document is modified version of original SweRVolf documentation from release 0.6.
It describes SweRVolf SoC structure, memory map and used peripherals as well as step by step example
how to run simulation in `verilator` and how to run Zephyr sw application on Digilent Nexys A7
(or Nexys 4 DDR) FPGA boards.

#### swervolf-demo-leds-uart.pdf

In this document a step-by-step description is provided how to run simple application
program written in C on SweRVolf. This example project can either be compiled in
command-line or in Eclipse IDE, shipped with SSP.

#### swervolf-demo-freertos.pdf

Similarly to the previous document, this PDF contains description of another
software demo that shows how to run FreeRTOS-based appliations on SweRVolf.
Step-by-step instructions for compilation and use are also included.

#### openocd.pdf

This document provides deeper introduction to OpenOCD for advanced users.
  suitable version of OpenOCD with an up-to-date RISC-V support is shipped with SSP.

#### eclipse-mcu-ide.pdf

This document describes Eclipse CDT IDE (C/C++ Development Tooling) as well as
a custom Codasip add-on (Codasip SweRV plugin) shipped with SSP.
Via the Codasip SweRV plugin, users can comfortably create new C projects
in Eclipse IDE, configured directly for SweRV EH1 or SweRVolf.

####  whisper-iss.pdf

This document describes how to configure and use Whisper instruction set simulator (ISS)
developed by Western Digital. Whisper ISS is typically used as a golden reference
for verification of SweRV EH1. This document also shows how to run a simple in Whisper ISS
in a standalone mode.

#### infra-tools-doc_cpm_user_guide.pdf

This document describes Codasip Package Manager (cpm) commands and also the directory tree of SSP.
It is intended for SSP users and administrators who will do the SSP installation and maintenance.

#### infra-tools-doc_mgen.pdf

This document describes modulefile generator utility, which is used by cpm init to generate user specific environment modulefiles.
The concept of environment modules is presented in this document, along with details how to configure them and how to adjust your
working environment in the shell. This document is intended for SSP users and administrators who will do the SSP installation
and maintenance.

#### infra-tools-doc_cpm_developer_guide.pdf

This document contains comprehensive description of Codasip package manager (cpm) administration files.
It is intended for those who are going to develop their own packages which can then be integrated into SSP.


## Frequently asked questions

### How to configure Docker host and client for operation over network

In case you will be running SSP on your local computer and `root` permissions are available, no further configuration of Docker is necessary.

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

### I cannot run any graphical (GUI) applications, for instance Eclipse IDE, in the SSP. What should I do?

Running GUI applications directly in the SSP terminal is not possible as Docker container does not have any display attached. However, GUI applications can be run using the combination of SSH and X Server. To enable X Server within SSH connection, you need to pass argument `-X` to the `ssh` command:

`$ ssh -X -p <forwarded_port> sspuser@localhost`

After connecting to SSP this way, you can open any graphical application and it will use the Window System of your host.

### I cannot connect to SSP via SSH, what might be the cause?

There might be multiple reasons why the SSH connection does not work properly:

1. Your firewall is blocking the connection. Try to check your firewall settings.
1. SSP container does not have the TCP port 22 forwarded port from the container to the host. To forward the port, please see the `Connect via SSH` section in this README.
1. The port you used for the forwarding on the host may already be used by another service. Use `nmap`, `ss` or similar utilities to see the ports that are already in use.
1. There is another SSP container running on your host with the same port specified.
2. SSH daemon is not running in the SSP container. Run command `ps aux | grep sshd` to check if daemon is running. If you cannot see the daemon running, you can start it manually by running command `$ /usr/sbin/sshd -D &`. The reason why it is not started may be that you have overridden the startup command of the SSP container.

### How to share your changes in SSP with other people

Yes! Docker is prepared for these situations. There are three options how to share your SSP workspace with other people.

First option is to connect to the SSP container via SSH, so all the changes you make will be immediately available to other people connected to the same container. This option is best for sharing you workspace with colleagues.

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

### How to mount network drive in the SSP

To mount the network drive you will need to install drivers for the filesystem which is used on your network drive. SSP docker already supports NFS network drives. However, to be able to mount these drives, you will need to leverage the Docker privileges as by default the SSP container is well isolated from the outer environment. To leverage the privileges, you need to start the SSP container by adding
`--privileged` argument to loader script.

### I am unable to run services (daemons) in the SSP. What can I do?

Unfortunately SSP Docker cannot run services as it does not have access to D-Bus. All daemons you want to have running in the SSP must be started manually.

[Docker overview]: https://docs.docker.com/engine/docker-overview/
[Docker installation guide]: https://docs.docker.com/install/
[docker cp]: https://docs.docker.com/engine/reference/commandline/cp/
