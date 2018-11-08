# Setting up a centralized logging server with Salt
*This Salt build is based on the [RELK-physical-working build](https://github.com/jisosomppi/log-analysis/tree/master/builds/relk-physical-working), and aims to automate and centralize the settings for it.*
## Basic idea of the setup
The idea behind managing the setup is to make reduce the number of problems in the complete installation. By using a centralized system for the installation we can ensure that:
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
To start building the infrastructure we need to setup the logging server. This means making some modifications to a new computer, as well as downloading and installing packages, modifying setting files, changing firewall rules etc. to build the actual logging setup.
* Making local package repo for Elastic products
  * Download v. 6.4.2 of Logstash, Elasticsearch and Kibana
  * [Make repository](https://www.linux.com/learn/create-your-own-local-apt-repository-avoid-dependency-hell) and add to `/etc/apt/sources.list`

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
    * Install unverified (local) packages by adding `skip_verify: True` to their Salt states
* Modifying settings for installed packages
* Confirm all daemons updated and running
  * Monitor for changes in critical setting files
* Manually modify settings for log files
  * This step currently exists because we're having trouble getting Rsyslog's permission settings to work. In our current configuration Rsyslog refuses to give new folders the proper access permissions, resulting in Logstash being unable to read the files. This can be easily overridden with manually forcing the permissions, however:  
  **THIS IS NOT SUITABLE FOR A PRODUCTION ENVIRONMENT!!**. 
* Make sure all changes to setting files are reflected on clients

***Editing in progress!***
