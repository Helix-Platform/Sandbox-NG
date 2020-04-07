sudo docker-compose up -d --build --force-recreate
nohup sudo ./Helix-Orchestrator &> Helix-Orchestrator.out&
nohup sudo ./Helix-Hardware-Monitor &> Helix-Hardware-Monitor.out&
