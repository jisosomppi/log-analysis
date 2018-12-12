# Additional documentation

### Customization
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

## Known issues
* The current setup only works with a single client, as the client certificate is created during server setup
* The server network interface that is needed for Nginx is currently set to `eno1`. This will lead to errors on some setups, but can be changed by editing the file `/salt/srvsalt/nginx/init.sls`.

## Additional documentation
### Research documents
Over the course of the project, we did countless hours of research on logging solutions and topics related to our project. These files can be found in [their own folder](https://github.com/jisosomppi/log-analysis/tree/master/documentation).

### Old builds
We also built several versions of our logging system, using varying component setups and configurations, as well as wrote installation instructions for them. The old builds can be found [here](https://github.com/jisosomppi/log-analysis/tree/master/deprecated/builds).

### Project management
We kept a somewhat detailed project diary, working hour list, and some other documents required for the school course. These files can be found [here](https://github.com/jisosomppi/log-analysis/tree/master/project_management).
