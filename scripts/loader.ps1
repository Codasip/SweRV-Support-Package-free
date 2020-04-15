$cfg_file = ".\loader.cfg"

# Check docker is installed by running version check.
docker --version > $null
if ($lastExitCode -ne 0) {
   Write-Output "`nDocker is not installed. Please follow official documentation @ https://www.docker.com/get-started"
   exit $lastExitCode 
}

# Check config file exists, if yes then get docker image url.
if ( Test-Path -Path $cfg_file) {
   $CONFIG_FILE_CONTENT = Get-Content -Path $CONFIG_FILE
   $CONFIG_FILE_CONTENT -match "image=(?<content>.*)"
   $IMAGE_NAME = $matches['content']
   Write-Output "`nImage URL: $($IMAGE_NAME)"
} else {
   Write-Output "Configuration file $($cfg_file) has not been found. Cannot continue."
   exit $lastExitCode
}

# Check user has access rights for docker.
docker info > $null
if ($lastExitCode -ne 0) {
   Write-Output "`nDocker is not properly configured. Either docker host is not properly set or you don't have required privileges. Please follow post-installation guide https://docs.docker.com/docker-for-windows/install/."
   exit $lastExitCode
}

# Pull docker image.
Write-Output "`nPulling $($IMAGE_NAME)"
(docker pull $IMAGE_NAME) -or (Write-Output "Could not pull image: $($IMAGE_NAME)")

# Run image with commands from args. For more info see README.md.
Write-Output "`nStarting $($IMAGE_NAME)"
docker run $args $IMAGE_NAME
