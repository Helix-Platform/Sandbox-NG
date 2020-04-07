#!/bin/bash
# This script installs the requirements for the Helix installation.
clear
sudo pkill Helix
sudo rm *.out

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

codename=xenial
mongodb=3.6

sudo apt-get install gnupg
wget -qO- https://www.mongodb.org/static/pgp/server-${mongodb}.asc | sudo apt-key add
sudo bash -c "echo deb http://repo.mongodb.org/apt/ubuntu ${codename}/mongodb-org/$mongodb multiverse > /etc/apt/sources.list.d/mongodb-org.list"
sudo apt-get update
sudo apt-get install -y mongodb-org=3.6.3 mongodb-org-server=3.6.3 mongodb-org-shell=3.6.3 mongodb-org-mongos=3.6.3 mongodb-org-tools=3.6.3

echo "mongodb-org hold" | sudo dpkg --set-selections
echo "mongodb-org-server hold" | sudo dpkg --set-selections
echo "mongodb-org-shell hold" | sudo dpkg --set-selections
echo "mongodb-org-mongos hold" | sudo dpkg --set-selections
echo "mongodb-org-tools hold" | sudo dpkg --set-selections

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
mkdir -p ~/data/helix

sudo docker-compose down

echo "Starting Helix Sandbox NG Modules"

sudo docker-compose up -d --build --force-recreate
nohup sudo ./Helix-Orchestrator &> Helix-Orchestrator.log&
nohup sudo ./Helix-Hardware-Monitor &> Helix-Hardware-Monitor.log&

echo "Registering Helix Modules on startup boot sequence"

echo "cd $(pwd)" >> helix-init.sh
echo "./start.sh &> /var/logs/helix.log" >> helix-init.sh
sudo cp ./helix-init.sh /etc/init.d/
sudo update-rc.d helix-init.sh defaults

git checkout .
