sudo pkill Helix
sudo rm *.log
sudo docker stop $(sudo docker ps -a -q)
