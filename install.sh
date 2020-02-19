#!/bin/bash
# This script installs the requirements for the Helix installation.
clear

killall ./Helix-Hardware-Monitor
killall ./Helix-Orchestrator

echo "Welcome to Helix Sandbox Intallation"
echo "Updating Ubuntu"

sudo apt -y update
sudo apt -y upgrade

echo "Ubuntu is updated!"

echo "Installing Docker Engine and Docker compose."

# Install prerequisites
sudo apt-get -y update
sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common
sudo apt-get -y install sed

# Add docker's package signing key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add repository
sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Install latest stable docker stable version
sudo apt-get -y update
sudo apt-get -y install docker-ce

# Install docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod a+x /usr/local/bin/docker-compose

# Enable & start docker
sudo systemctl enable docker
sudo systemctl start docker

# Enable nonroot docker usage
sudo usermod -aG docker $USER

echo "Docker Engine and Docker compose installed with success."

sudo mkdir -p /opt/secrets/ssl_crt
sudo mkdir -p /opt/secrets/ssl_key

sudo openssl req -newkey rsa:2048 -x509 -nodes -keyout /opt/secrets/ssl_key/server.key -new -out /opt/secrets/ssl_crt/server.crt -config ./openssl-custom.cnf -sha256 -days 365

sudo docker-compose down
sudo docker-compose up -d --build --force-recreate
nohup sudo ./Helix-Orchestrator &> Helix-Orchestrator.out&
nohup sudo ./Helix-Hardware-Monitor &> Helix-Hardware-Monitor.out&
