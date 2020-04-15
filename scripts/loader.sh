#!/bin/sh
CONFIG_FILE="loader.cfg"

# Check docker is installed by running version check.
docker --version 2>&1 1>/dev/null
if [ $? -ne 0 ]; then
   echo -e "\n\e[91m[ERROR]\033[0m Docker is not installed. Please follow official documentation @ https://www.docker.com/get-started"
   exit 1 
fi

# Check config file exists, if yes then get docker image url.
if [ -f $CONFIG_FILE ]; then
   IMAGE_NAME=$(sed -n 's/image=\(.*\)/\1/p' < $CONFIG_FILE)
else
   echo -e "\n\e[91m[ERROR]Configuration file $CONFIG_FILE has not been found. Cannot continue.\033[0m"
   exit 1
fi

# Check user has access rights for docker.
docker info 1>/dev/null
if [ $? -ne 0 ]; then
   echo -e "\n\e\e[33m[INFO]\033[0m[91mDocker is not properly configured. Either docker host is not properly set or you don't have required privileges. Please follow post-installation guide https://docs.docker.com/install/linux/linux-postinstall/.\033[0m"
   exit 1
fi

# Pull docker image.
echo -e "\n\e[33m[INFO]\033[0mPulling \e[92m$IMAGE_NAME\033[0m"
docker pull $IMAGE_NAME || ( echo -e "\e[91m[ERROR]Could not pull image:\033[0m ${IMAGE_NAME}" && exit 1 )

# Run image with commands from args. For more info see README.md.
echo -e "\n\e[33m[INFO]\033[0mStarting \e[92m$IMAGE_NAME\033[0m"
docker run $@ $IMAGE_NAME
