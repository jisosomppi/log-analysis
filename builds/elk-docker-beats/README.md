# Beats, Logstash, ElasticSearch, Kibana
***Or how to do things "the easy way"***

Build information:
* Logstash, ElasticSearch and Kibana running in their own Docker containers (NOTE: we're not using Logstash, it's just a part of the prebuilt container stack)
* Containers managed through Portainer WebUI
* MetricBeat sending data from host computer to Elasticsearch

I followed the [official instructions](https://www.elastic.co/guide/en/beats/metricbeat/current/metricbeat-installation.html) for MetricBeat configuration.

## Thoughts on this build
Running the core services within containers has both positive and negative impacts on the solution. The services are easy to contain and restart, thanks to the Docker architecture. On the other hand, changing any configuration file requires rebuilding the container. The Docker version can be changed to output data to a separate location, but in this configuration the data is tied to the container, and thus lost upon rebuild. Portainer provides an easy way to control the containers over the internet, which is an obvious security threat but also a great help in remote maintenance.

## Setup process
I started by running our setup script, `serversetup.sh`. The script prepares the computer to act as a server, installing regular tools as well as setting up Docker and the ELK Stack containers. No changes were made to the Docker images, so the following ports are used:

Service|Port
-------|----
Kibana|5601
Portainer|9000
Elasticsearch|9200
*Elasticsearch*|*9300*
*Salt(unused)*|*4505*
*Salt(unused)*|*4506*

After this I added Elastics GPG and repository, and installed Metricbeat:  
```
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo apt-get install -y apt-transport-https default-jdk
echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list
sudo apt-get update && sudo apt-get install -y metricbeat
```

I edited the main configuration file `/etc/metricbeat/metricbeat.yml`, adding the correct address and port for my Kibana and Elasticsearch instances. Then I ran the Metricbeat setup `sudo metricbeat setup`, which adds preconfigured dashboards for different log sources to Kibana. I also did the same for Filebeat (`sudo apt-get install -y filebeat`, settings and `sudo filebeat setup`), which allowed me to send log data directly.

## Success!
This setup is working, albeit with suboptimal components. We're getting data from the client machine onto the server, and the data is completely readable, searchable and analyzable.

With the current setup, using Logstash is not necessary! This eliminates one step of the already complicated setup, and reduces resource use on the server.

## Refining the build
* We got Filebeat and Metricbeat working correctly on two different clients, both sending data to the same Dockerized ElasticSearch
* We got the dashboards from both Beats to work correctly, displaying data in real time
* We found the correct JSON syntax by studying Kibana and Beats, and by analyzing the traffic with Wireshark
* We enabled the Docker module in MetricBeat, gaining usage data for Docker containers

## Next steps
* Study the setup, copy working settings to full installs of Elasticsearch and Kibana, get rid of Docker
* Build a custom format to send info from Rsyslog to Elasticsearch
* Filter sent logs to reduce load on client, server and network
