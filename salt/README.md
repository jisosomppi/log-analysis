# Setting up a centralized logging server with Salt

*Updated on 14/11/18: Added SSL certificates to Nginx and HTTP authentication to Kibana/Elasticsearch*
## Table of Contents

* [Installation](#installation)
  * [Server install](#server-install)
  * [Client install](#client-install)
  * [Setup & testing](#setup--testing)
* [Basic idea of the setup](#basic-idea-of-the-setup)
* [Salt state structure](#salt-state-structure)
  * [Single-run setup](#single-run-setup)
  * [Ongoing setup (highstate)](https://github.com/jisosomppi/log-analysis/blob/master/salt/README.md#ongoing-setup-highstate)
  * [Pillar structure](#pillar-structure)
  * [Currently missing from the Salt version](#currently-missing-from-the-salt-version)

## Installation
### Server install
```
wget https://raw.githubusercontent.com/jisosomppi/log-analysis/master/salt/serversetup.sh
chmod +x serversetup.sh
sudo ./serversetup.sh

```
Once the server setup script has completed it's task, it will open a firefox window (if you have a browser window active when the installation completes, an error message will be prompted and no new browser window will be opened).  

If a new window is opened after the script completes, you will be directed to your localhost page. There, you will:  
 - Add security exceptions to firefox for your new self-signed cert.  
 - Fill your username and password for the readonlyREST basic authentication.  
 
 If your firefox was already running once the script completed, you can test that everything works by browsing `localhost`, `logserver.local` or your IP.

![default_kibana](https://raw.githubusercontent.com/jisosomppi/log-analysis/master/images/default_kibana.png)

### Client install
```
wget https://raw.githubusercontent.com/jisosomppi/log-analysis/master/salt/clientsetup.sh
chmod +x clientsetup.sh
sudo ./clientsetup.sh

```
### Setup & testing
The above commands should be run on two different (X)Ubuntu machines (preferably fresh, empty machines; tested on live installs and Ubuntu 16.04 vagrant boxes). After running both installation scripts, run the command `sudo salt-key -A` on the master to accept all pending keys. After this run `sudo salt '*' state.highstate --state-output terse` on the master to set all machines (server+clients) to the desired state.

You can generate log data for testing by typing `logger -s testmessage` on the client (-s to print the message to the terminal as well). 

The logs will be saved on the master at `/var/log/client_logs`, but won't be visible in Kibana before running `sudo salt 'srv*' state.highstate` or `sudo salt 'srv*' state.apply fixperms` on the server to give the log files proper permissions (this part is still under work). 

The logging frontend is Kibana, which is automatically set up and started on the master. The interface can be accessed either locally on the server (http://localhost) or from any salt minion (http://logserver.local). Kibana requires minimal setup after the initial scripts:
* Go to the Discover tab
* Create new index (to show all stored log data enter " \* "), choose @timestamp as the time filter
* Go to the Discover tab to see log entries

## Basic idea of the setup
The idea behind managing the setup is to reduce the number of problems in the complete installation. By using a centralized system for the installation we can ensure that:
* IP addresses and port numbers are correct
* Client systems are setup with correct logging rules
* All non-public data remains hidden from unauthorized machines
* All setting files in the network can have a single source of truth, enabling us to change ports, addresses, certificate files etc. easily
  * Bonus perk: Because changes are fetched from the Salt server, we can use randomly chosen port numbers for services, hindering attack attempts.

### Server highstate
* Repository addition
  * Elastic repository
    * required for Elastic components
* Package installation
  * Java
    * required for Elastic components
  * Nginx proxy
    * presents Kibana at port 80 (no port number needed when browsing to)
    * allows Nginx to be the only open service (apart from Rsyslog receive)
    * allows easier control of http settings
    * provides SSL
  * Rsyslog
  * Elasticsearch
    * Also installs the ReadonlyREST plugin, allowing for HTTP authentication
  * Kibana
  * Logstash
  * Salt-master
  * Salt-minion
* Manually modify settings for log files
  * This step currently exists because we're having trouble getting Rsyslog's permission settings to work. In our current configuration Rsyslog refuses to give new folders the proper access permissions, resulting in Logstash being unable to read the files. This can be easily overridden with manually forcing the permissions, however:  
  **NOTE THAT THIS IS NOT SUITABLE FOR A PRODUCTION ENVIRONMENT!!**. 

### Client highstate
* Package installation
  * Rsyslog
  * Salt-minion

### Pillar structure
* Workstation
  * Only gets the Rsyslog receive port
  * (Will get Rsyslog authentication details in a future build)
* Server
  * Reads the same rsyslog.sls pillar file to allow for single source of truth
  * Contains all IP address, port, user authentication details

## Currently missing from the Salt version
* Encryption of log traffic
* ~~User authentication for Nginx/Kibana~~
* Automatic log analysis/filtering
* Jinja can't render nordic characters (öåä), so they can't be used (even in pillars -> passwords). Entering nordics into the pillar causes a Jinja ascii render error
