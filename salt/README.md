# Setting up a centralized logging server with Salt
***ICT Infrastructure Project, fall 2018***  
***Haaga-Helia University of Applied Sciences***  
*[Jussi Isosomppi](https://github.com/jisosomppi), [Eino Kupias](https://github.com/einokupias), [Saku Kähäri](https://github.com/nauskis)*

![RELK_dataflow](https://github.com/jisosomppi/log-analysis/blob/master/images/RELK_dataflow_final.png?raw=true)

The aim of this project is to create a centralized logging solution, where all workstations on a network send their log data to a central logging server. Our solution consists of fully open source components (and the Apache 2.0 -licensed versions of Elastic Co.'s products), and uses the popular and often preinstalled Rsyslog for log reporting. By doing this, we can keep the resource draw from logging very low on client systems.

*Updated on 14/11/18: Added SSL certificate generation to Nginx and HTTP authentication to Kibana/Elasticsearch*
*Updated on 21/11/18: The SSL certificate generation is automated, just needs manual adding of CA cert to Firefox*

## Table of Contents

* [Installation](#installation)
  * [Server install](#server-install)
  * [Client install](#client-install)
  * [Setup & testing](#setup--testing)
* [Basic idea of the setup](#basic-idea-of-the-setup)
  * [Server highstate](#server-highstate)
  * [Client highstate](#client-highstate)
  * [Pillar structure](#pillar-structure)
  * [Upcoming features](#upcoming-features)
  * [Known issues](#known-issues)

## Installation
### Server install
```
wget https://raw.githubusercontent.com/jisosomppi/log-analysis/einoscript/salt/serversetup.sh
chmod +x serversetup.sh
sudo ./serversetup.sh

```
Once the server setup script has completed it's task, it will open a firefox window (if you have a browser window active when the installation completes, an error message will be prompted and no new browser window will be opened).  

If a new window is opened after the script completes, you will be directed to your localhost page. There, you will:  
 - Add security exceptions to firefox for your new self-signed cert.  
 - Fill your username and password for the readonlyREST basic authentication.  
 
 If your firefox was already running once the script completed, you can test that everything works by browsing `localhost`, `logserver.local` or your IP.
 
 *To get rid of the security warning, add the certificate `~/localCA.pem` to your Firefox certificates (automation is under research).* 

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
* Package installation & configuration
  * Rsyslog
  * Salt-minion
* Adding the DNS redirect for log server

The client highstate is kept minimal, as we're only defining logging rules, not an imaginary workflow 
  

### Pillar structure
* Workstation
  * Only gets the Rsyslog receive port
  * (Will get Rsyslog authentication details in a future build)
* Server
  * Reads the same rsyslog.sls pillar file to allow for single source of truth
  * Contains all IP address, port, user authentication details

## Upcoming features
* Encryption of log traffic
* Automatic log analysis/filtering

## Known issues
* Jinja can't render nordic characters (öåä), so they can't be used (even in pillars -> passwords). Entering nordics into the pillar causes a Jinja ascii render error. [There is a workaround for this](https://github.com/saltstack/salt/issues/40486#issuecomment-291147689) (adding `.decode('utf-8')` to `pillar.get`), but it prevents `salt-call --local` from working, and thus makes no difference in our case.
* With the current configuration, we're not logging events from the log server. This is due to a previous configuration error that resulted in ~450Gb (a full disk) of log data being generated from a single system within an hour. We're going to address this issue at a later time.
