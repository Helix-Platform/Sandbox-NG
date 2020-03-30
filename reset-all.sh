#!/bin/bash
# This script resets everything from Helix.
clear
sudo pkill Helix
sudo rm *.out

sudo docker rm -vf $(docker ps -a -q)
sudo docker rmi -f $(docker images -a -q)

sudo rm -rf /opt/secrets/ssl_crt
sudo rm -rf /opt/secrets/ssl_key

sudo rm -rf ~/data

./install.sh