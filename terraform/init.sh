#!/bin/bash
set -e

sudo apt-get update && apt-get upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
rm get-docker.sh

# Create Jenkins data directory
sudo mkdir -p /var/lib/jenkins
sudo chown 1000:1000 /var/lib/jenkins

# Wait for Docker daemon to start
sleep 5

# Start Jenkins container with host network mode
sudo docker run -d \
  --name jenkins \
  --restart unless-stopped \
  --network host \
  -v /etc/localtime:/etc/localtime:ro \
  -v /etc/timezone:/etc/timezone:ro \
  -v /var/lib/jenkins:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  ${jenkins_image}

echo "Jenkins container started successfully on host network"
