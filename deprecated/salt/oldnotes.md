
### Single-run setup
~~To start building the infrastructure we need to setup the logging server. This means making some modifications to a new computer, as well as downloading and installing packages, modifying setting files, changing firewall rules etc. to build the actual logging setup.~~
* ~~Making local package repo for Elastic products~~
  * ~~Download v. 6.4.2 of Logstash, Elasticsearch and Kibana~~
  * ~~[Make repository](https://www.linux.com/learn/create-your-own-local-apt-repository-avoid-dependency-hell) and add to `/etc/apt/sources.list`~~

**Replaced by a Salt state!**

    * ~~Install unverified (local) packages by adding `skip_verify: True` to their Salt states~~
    * Require `elastic-pkg` Salt state, which verifies the Elastic package repository is present
    
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
  
  
  Using Salt pillars to store data is a great way to keep a single source of truth. Having salt minions read the information from the pillar allows segmenting the network, and giving different server information to computers depending on their id (department, usecase, etc.).
