# Rsyslog, Elasticsearch, Kibana
# Full apt-get install, no containers

*This build based mostly on [this article](https://sematext.com/blog/recipe-rsyslog-elasticsearch-kibana/), with some updates as the article is slightly outdated (published July, 2013). Elasticsearch and Kibana installed by following https://www.elastic.co/guide/en/elasticsearch/reference/current/deb.html.*

Server setup:

```
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo apt-get install apt-transport-https default-jdk
echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list
sudo apt-get update && sudo apt-get install elasticsearch kibana rsyslog rsyslog-elasticsearch
```

* Install Java
* Add Elastics GPG key
* Add Elastic repository to sources.list
* (apt-get) Install Elasticsearch, Kibana and Rsyslog (plus rsyslog-elasticsearch plugin)
* Configure components
  * Elasticsearch bound to localhost (not available to misuse)
  * Kibana bound to private IP (accessible remotely)
  * Rsyslog listening for logs on port 514
  * Rsyslog configured to reformat data in the Logstash-esque format
  * Rsyslog configured to forward data to localhost:9200 (Elasticsearch)
* Start Elasticsearch and Kibana, verify localhost:9200 and server_ip:5601


Client setup:
* Install Rsyslog
  * Configure Rsyslog to send all logs to `server_ip:514`
