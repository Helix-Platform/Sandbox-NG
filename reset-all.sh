#!/bin/bash
# This script resets everything from Helix.
clear

mongo -u helix -p H3l1xNG --port 27000 --authenticationDatabase admin main --eval "db.getCollectionNames().forEach(function(n){db[n].drop()});"
mongo -u helix -p H3l1xNG --port 27000 --authenticationDatabase admin orion --eval "db.getCollectionNames().forEach(function(n){db[n].drop()});"
mongo -u helix -p H3l1xNG --port 27000 --authenticationDatabase admin orion-helixiot --eval "db.getCollectionNames().forEach(function(n){db[n].drop()});"
mongo --port 28018 iotagentul --eval "db.getCollectionNames().forEach(function(n){db[n].drop()});"

sudo pkill Helix
sudo rm *.out

sudo docker stop $(sudo docker ps -a -q)
sudo docker rm -vf $(sudo docker ps -a -q)
sudo docker rmi -f $(sudo docker images -a -q)

sudo rm -rf /opt/secrets/ssl_crt
sudo rm -rf /opt/secrets/ssl_key

sudo rm -rf ~/data
sudo rm -rf /home/root/data/helix

./install.sh
