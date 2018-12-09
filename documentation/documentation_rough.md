# Log-analysis final documentation

## File: Usage documentation
### Project description
Our aim with this project is to create a centralized logging solution, created with ease of use and data security in mind. Our solution relies on Saltstack for centralized management, and on encryption and SSL certificates for data security. We wrote scripts to help make the setup easy and consistent, so that each installation would lead to the same end result.

### Installation/setup instructions
For our testing, we used Xubuntu 16.04 as our base operating system. The setup works with a live USB as well as on an installed OS. For the client, we verified VM functionality with Vagrant/Virtualbox and the `bento/ubuntu-16.04` box.

#### Server install
```
wget https://raw.githubusercontent.com/jisosomppi/log-analysis/master/salt/serversetup.sh
chmod +x serversetup.sh
sudo ./serversetup.sh

```
Once the server setup script has completed its task, it will open a new firefox window (or tab) showing the Kibana dashboard at https://logserver.local. To make the page display without errors, add the `~/localCA.pem` file to the authorized certificates. 

#### Client install
```
wget https://raw.githubusercontent.com/jisosomppi/log-analysis/master/salt/clientsetup.sh
chmod +x clientsetup.sh
sudo ./clientsetup.sh

```
Once the script is completed, run the command `sudo salt-key -A -y && sudo salt '*' state.highstate` on your server. This makes sure that all (both) of the clients are in the correct state. After this you can run the command `logtest` on the client to generate test entries in the system log. These entries should be visible

### Script/module descriptions
#### serversetup.sh
* Installs all necessary programs (Git, OpenSSL, Salt master & minion)
* Gathers username and password for Elasticsearch/Kibana
* Clones this Git repository and places the files in the correct directories
* Creates the SSL certificates needed for the setup, with self-specified passphrase
* Runs the Salt highstate that takes care of most of the install process

#### clientsetup.sh
* Installs salt-minion
* Asks for salt master IP and a minion ID

#### Salt highstate
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
  * Installs the required components
    * Rsyslog
      * Pulls the latest version from the Adiscon repository to enable latest security features
  * Configures Rsyslog to forward log entries to the server 
    * Certificates created during server setup are used here, providing encryption and two-way authenticaton (thanks to using a Certificate Authority to sign both certificates)
    * The forwarded logs can be configured via the /etc/rsyslog.conf file
  * Configures /etc/hosts to redirect https://logserver.local to the logging server

## Project diary
* Initial assignment
* Plans for the project
* Weekly reports

## Reference materials
* Divided into files by component
* Master source list
