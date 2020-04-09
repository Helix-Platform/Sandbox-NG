sudo docker-compose up -d --build --force-recreate
nohup sudo ./Helix-Orchestrator &> Helix-Orchestrator.log&
nohup sudo ./Helix-Hardware-Monitor &> Helix-Hardware-Monitor.log&
