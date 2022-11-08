## Requirements before Helix Sandbox NG installation

Use any local hypervisor like Virtual Box, VMware and KVM or if you need a global Internet access we suggest any Cloud Service Provider (CSP) like AWS, Azure or Google. 

Minimum server configuration: 1 vCPU, 1GB RAM and 16GB HDD or SSD.

Compatible with most Linux distribution, but Ubuntu Server 18.04.6 LTS has been validated exhaustively for us.

You need to open all ports below in firewall settings on your CSP and iptables (ufw) using "sudo ufw allow port":

```
Port         Transport             Protocol 

5000            TCP            Helix Web Interface
3030            TCP            Helix Orchestrator
22443           TCP            Helix Hardware Monitor
1026            TCP            CEF Context Broker 
27000           TCP            MongoDB 
5050            TCP            Cygnus
1883            TCP            Eclipse-Mosquitto
4041            TCP            IoT Agent MQTT 
```

### Automated installation (Let us help you with that!)

Connect to the server via SSH and follow the instructions below

```
git clone https://github.com/Helix-Platform/Sandbox-NG.git
cd Sandbox-NG
./install.sh
```
