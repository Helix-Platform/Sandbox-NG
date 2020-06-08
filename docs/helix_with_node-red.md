## Running Node-Red on Ubuntu Server

This guide takes you through the steps to get Node-RED running on an Ubuntu Server 18.04.4 LTS Machine instance.

### Create the base image

   Log in to your Cloud Service Provider (CSP)

   Click to add a New … Virtual Machine

   In the list of Virtual Machines, select Ubuntu Server, then click ‘Create’

   Give your machine a name, the username you want to use and the authentication details you want to use to access
   the instance.
   Choose the Size of your instance. Remember that node.js is single-threaded so there’s no benefit to picking a size with
   multiple cores for a simple node-red instance.
   Add a new ‘Inbound rule’ with the options set as:
       Name: node-red
       Protocol: TCP
       Destination port range: 1880

### Setup Node-RED

The next task is to log into the instance then install node.js and Node-RED.

Log into your instance using the authentication details you specified in the previous stage.

Once logged in you need to install node.js and Node-RED

```
   curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
   sudo apt-get install -y nodejs build-essential
   sudo npm install -g --unsafe-perm node-red
```

At this point you can test your instance by running node-red. Note: you may get some errors regarding the Serial node - that’s to be expected and can be ignored.

Once started, you can access the editor at http://<your-instance-ip>:1880/.

To get Node-RED to start automatically whenever your instance is restarted, you can use pm2:
```
   sudo npm install -g --unsafe-perm pm2
   pm2 start `which node-red` -- -v
   pm2 save
   pm2 startup
```
Note: this final command will prompt you to run a further command - make sure you do as it says.
