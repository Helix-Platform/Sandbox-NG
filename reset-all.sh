#!/bin/bash
# This script resets everything from Helix.
clear

sudo pkill Helix
sudo rm *.out

sudo docker stop $(sudo docker ps -a -q)
sudo docker rm -vf $(sudo docker ps -a -q)
sudo docker rmi -f $(sudo docker images -a -q)
sudo docker network rm helix

sudo rm -rf /opt/secrets/ssl_crt
sudo rm -rf /opt/secrets/ssl_key

sudo rm -rf ~/data
sudo rm -rf /home/root/data/helix

./install.sh
