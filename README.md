# Logging and analysis of security data in a network
***ICT Infrastructure Project, fall 2018***  
***Haaga-Helia University of Applied Sciences***  
*[Jussi Isosomppi](https://github.com/jisosomppi), [Eino Kupias](https://github.com/einokupias), [Saku Kähäri](https://github.com/nauskis)*

## Project description
Our aim with this project is to create a centralized logging solution, created with ease of use and data security in mind. Our solution relies on Saltstack for centralized management, and on encryption and SSL certificates for data security. We wrote scripts to make the setup process easy and consistent, so that each installation would lead to the same end result.

## Installation/setup instructions
For our testing, we used Xubuntu 16.04 as our base operating system. The setup works with a live USB as well as on an installed OS. For the client, we verified VM functionality with Vagrant/Virtualbox and the `bento/ubuntu-16.04` box.

### Server install
```
wget https://raw.githubusercontent.com/jisosomppi/log-analysis/master/salt/serversetup.sh
chmod +x serversetup.sh
sudo ./serversetup.sh

```
Once the server setup script has completed its task, it will open a new firefox window (or tab) showing the Kibana dashboard at https://logserver.local. To make the page display without errors, add the `~/localCA.pem` file to the authorized certificates (On Firefox: Preferences -> Privacy and Security -> View Certificates -> Import...). 

### Client install
*If you want to use Vagrant as your test client, you can use [this script](https://raw.githubusercontent.com/jisosomppi/log-analysis/master/salt/vagrantup.sh) to set up your client, then run the commands below.*  
```
wget https://raw.githubusercontent.com/jisosomppi/log-analysis/master/salt/clientsetup.sh
chmod +x clientsetup.sh
sudo ./clientsetup.sh

```
Enter your master's IP address (displayed at the end of the master setup script) and choose a name for your minion. 

### Testing
After both the minion and master are set up properly, run the command `sudo salt-key -A -y && sudo salt '*' state.highstate` on your master. This makes sure that all of the salt minions (including the server) are in the correct state. 

To generate log data for Kibana to display, run the command `logtest` on the minion. You can leave the script running and access Kibana with the username and password you chose during the server setup. 

To view all collected log data, enter `*` as your index pattern, click next and choose `@timestamp` as the Time Filter. After this your data will be visible in the Discover tab.

## Customization
We've tried to build the Salt states in a way that allows for easy customization. In practice, this means that many settings such as port numbers, IP addresses and network information is gathered from the Salt pillar. To customize the setup, look at the files under `salt/srvpillar`. 

## Script/module descriptions
### serversetup.sh
* Installs all necessary programs (Git, OpenSSL, Salt master & minion)
* Gathers username and password for Elasticsearch/Kibana
* Clones this Git repository and places the files in the correct directories
* Creates the SSL certificates needed for the setup, with self-specified passphrase
* Runs the Salt highstate that takes care of most of the install process

### clientsetup.sh
* Installs salt-minion
* Asks for salt master IP and a minion ID

### Salt highstate
* **Sets up the server**
  * Adds the required package repositories
    * Adiscon repository for Rsyslog
    * Elastic-OSS repository for the Apache 2.0 -licensed versions of Elasticsearch, Logstash and Kibana
  * Installs all the required components
    * Elasticsearch 6.5.1
      * Including the ReadonlyREST plugin for authentication
    * Logstash 6.5.1
    * Kibana 6.5.1
    * Rsyslog
      * Pulls the latest version from the Adiscon repository to enable latest security features
    * Nginx
      * Used to provide SSL encryption for Kibana and to serve it at the default port to avoid entering port numbers to access it
  * Configures all of the above-mentioned components 
  * Configures Firewall settings
    * Elasticsearch is only accessible locally, to Kibana
    * Kibana is only accessible locally, for the Nginx redirect
    * All other services are restricted to the 172.28.0.0/16 network (The lab network at Haaga-Helia)
  * Sets the correct file permissions for the client logs, and schedules a task to update the permissions for new logs every minute
  * Configures /etc/hosts to redirect https://logserver.local to the logging server
* **Sets up the client**
  * Adds the required package repositories
    * Adiscon repository for Rsyslog
  * Installs the required components
    * Rsyslog
    * (`logtest`, a script for testing logging functionality is also added)
  * Configures Rsyslog to forward log entries to the server 
    * Certificates created during server setup are used here, providing encryption and two-way authenticaton (thanks to using a Certificate Authority to sign both certificates)
    * The /etc/rsyslog.conf file can be modified to change which logs are forwarded
  * Configures /etc/hosts to redirect https://logserver.local to the logging server

### Known issues
* The current setup only works with a single client, as the client certificate is created during server setup
* The server network interface that is needed for Nginx is currently set to `eno1`. This will lead to errors on some setups, but can be changed by editing the file `/salt/srvsalt/nginx/init.sls`.
