# Rsyslog, Elasticsearch, Kibana
# Full apt-get install, no containers

![REK_dataflow.jpg](https://github.com/jisosomppi/log-analysis/blob/master/Builds/rek-physical/REK_dataflow.jpg)

	This build is based on the following articles:
	https://www.rsyslog.com/rsyslog-and-elasticsearch/
	https://sematext.com/blog/recipe-rsyslog-elasticsearch-kibana/
	https://sematext.com/blog/recipe-apache-logs-rsyslog-parsing-elasticsearch/
	https://www.tecmint.com/create-centralized-log-server-with-rsyslog-in-centos-7/
	https://www.howtoforge.com/tutorial/rsyslog-centralized-log-server-in-debian-9/
	https://launchpad.net/~adiscon/+archive/ubuntu/v8-stable


Server setup:

```
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo apt-get install -y apt-transport-https default-jdk
echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list
sudo apt-get update && sudo apt-get install -y elasticsearch kibana rsyslog rsyslog-elasticsearch
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
