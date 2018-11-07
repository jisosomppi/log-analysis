# Setting up a centralized logging server with Salt
## Basic idea of the setup
The idea behind managing the setup is to make reduce the number of problems in the complete installation. By using a centralized system for the installatin we can ensure that:
* IP addresses and port numbers are correct
* Client systems are setup with correct logging rules
* All non-public data remains hidden from unauthorized machines
* All setting files in the network can have a single source of truth, enalbing us to change ports, addresses, certificate files etc. easily
  * Bonus perk: Because changes are fetched from the Salt server, we can use randomly chosen port numbers for services, hindering attack attempts.

## Salt state structure
In order to make a complete working environment we need to have two different sets of instructions:
* The initial setup
* The ongoing setup

In a perfect world these two would be one and the same (idempotency), but since we're using some plain commands in the salt states, this isn't currently possible.

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
