# Beats, Logstash, ElasticSearch, Kibana
# "the easy way"

Build information:
* Logstash, ElasticSearch and Kibana running in their own Docker containers
* Containers managed through Portainer WebUI
* MetricBeat sending data from host computer to Logstash

I followed the [official instructions](https://www.elastic.co/guide/en/beats/metricbeat/current/metricbeat-installation.html) for MetricBeat configuration.



I started by running our setup script, `serversetup.sh`. After this I installed MetricBeat, for some simple logs to send to our server.


