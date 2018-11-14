# Setting up a centralized logging server with Salt
>*This Salt build is based on the [RELK-physical-working build](https://github.com/jisosomppi/log-analysis/tree/master/builds/relk-physical-working), and aims to automate and centralize the settings for it.*

# Table of Contents

- [Currently missing from the Salt version](#currently-missing-from-the-salt-version)
- [Installation](#installation)
  * [Server install](#server-install)
  * [Client install](#client-install)
  * [Setup & testing](#https://github.com/jisosomppi/log-analysis/blob/master/salt/README.md#setup--testing)
- [Basic idea of the setup](#basic-idea-of-the-setup)
- [Salt state structure](#salt-state-structure)
  * [Single-run setup](#single-run-setup)
  * [Ongoing setup (highstate)](#ongoing-setup-(highstate))
  * [Pillar structure](#pillar-structure)

## Currently missing from the Salt version
* Encryption of log traffic
* User authentication for Nginx/Kibana
* Automatic log analysis/filtering

## Installation
### Server install
```
wget https://raw.githubusercontent.com/jisosomppi/log-analysis/master/salt/serversetup.sh
chmod +x serversetup.sh
sudo ./serversetup.sh

```
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

## Salt state structure
In order to make a complete working environment we need to have two different sets of instructions:
* The initial setup
* The ongoing setup

We have two options for allowing Salt to install the Elastic packages:
* [Use a script to make a local repository with the packages](https://www.linux.com/learn/create-your-own-local-apt-repository-avoid-dependency-hell)
* Use a script to add Elastics GPG key and repository to the system and Target specific versions with [state parameters](https://docs.saltstack.com/en/latest/ref/states/all/salt.states.pkg.html#salt.states.pkg.installed)
  ```
  wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
  echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list:
  ```

### Single-run setup
~~To start building the infrastructure we need to setup the logging server. This means making some modifications to a new computer, as well as downloading and installing packages, modifying setting files, changing firewall rules etc. to build the actual logging setup.~~
* ~~Making local package repo for Elastic products~~
  * ~~Download v. 6.4.2 of Logstash, Elasticsearch and Kibana~~
  * ~~[Make repository](https://www.linux.com/learn/create-your-own-local-apt-repository-avoid-dependency-hell) and add to `/etc/apt/sources.list`~~

**Replaced by a Salt state!**

### Ongoing setup (highstate)
* Basic settings
  * User accounts
  * Firewall rules
  * SSH rules
  * Locale settings
* Package installation
  * Java
  * Nginx proxy
  * Rsyslog
  * Elasticsearch
  * Kibana
  * Logstash
    * ~~Install unverified (local) packages by adding `skip_verify: True` to their Salt states~~
    * Require `elastic-pkg` Salt state, which verifies the Elastic package repository is present
* Modifying settings for installed packages
* Confirm all daemons updated and running
  * Monitor for changes in critical setting files
* Manually modify settings for log files
  * This step currently exists because we're having trouble getting Rsyslog's permission settings to work. In our current configuration Rsyslog refuses to give new folders the proper access permissions, resulting in Logstash being unable to read the files. This can be easily overridden with manually forcing the permissions, however:  
  **THIS IS NOT SUITABLE FOR A PRODUCTION ENVIRONMENT!!**. 
* Make sure all changes to setting files are reflected on clients

### Pillar structure
Using Salt pillars to store data is a great way to keep a single source of truth. Having salt minions read the information from the pillar allows segmenting the network, and giving different server information to computers depending on their id (department, usecase, etc.).
