docker-compose up -d

nohup ./Helix-Orchestrator &> Helix-Orchestrator.out&
nohup ./Helix-Hardware-Monitor &> Helix-Hardware-Monitor.out&

sudo mkdir -p /opt/secrets/ssl_crt
sudo mkdir -p /opt/secrets/ssl_key

docker network create helix