sudo pkill Helix
sudo rm *.out
sudo docker stop $(sudo docker ps -a -q)
