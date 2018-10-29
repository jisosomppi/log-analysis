|Week |Jussi | Eino | Saku | Tasks |
|-----|------|-----|------|------|
|wk 34|12|12|12|Formed the group, decided subject|
|wk 35|6|10|10|Worked on project plan, tested ELK-stack|
|wk 36|18|18|18|Finalized project plan, got server running, looked into alternative open source modules, migrated all documentation to Github|
|wk 37|14|14|14|Removed Logstash and Beats. Started troubleshooting Rsyslog, presented projectplan. Troubleshot Rsyslog, but broke Elasticsearch. Reinstalled server and components seem to work. Still unable to pass data from Rsyslog to Elasticsearch properly|
|wk 38|17|17|17|Found out that Rsyslog has generated over 200Gb of data during the weekend, let the troubleshooting be joined. We couldn't get Rsyslog-elasticsearch-kibana setup to work properly. We started our individual setups with different components. Jussi took the original Elk-stack, Eino started working with Graylog and Saku took Rsyslog-logstash-Elasticsearch-Kibana|
|wk 39|8|5|8|Monday was a sickday all around, not much got done. On wednesday we had a meeting with Tero and continued our work. Jussi passed data to Kibana with and without Logstash! Eino got Graylog working to some degree and Saku got everything running, but Logstash didn't pass data to Elasticsearch. Trying to capture the proper JSON format used by Beats with Wireshark. We passed data from a client to Jussi's Kibana server with metricbeat.|
|wk 40|16|16|16|Continued our work on previous tasks on monday. On wednesday, Jussi passed data from rsyslog to Elasticsearch and Kibana. Saku and Eino continued working on their own builds. On friday, Saku got his stack with logstash working. Eino started working on setting up TSL. Jussi is removing containers from his build and refining the overall structure.|
|wk 41|13|15|15|We have working TLS-connection though anyone can start the secured connection, so need to set up ip-whitelist or make a system with certs and keys. Encrypted messaging with unsecure (public) keys and certs done, next step generating custom and secure. **RELK-stack build works! Data flow from logging client to Kibana working.**|
|wk 42|||||
|wk 43||9|8|Saku worked on setting up authentication for ElasticSearch, Eino continued working on his project|
|wk 44||||6|Saku got his elasticsearch authentication plugin readonlyREST up and running. 
|wk 45|||||
|wk 46|||||
|wk 47|||||
|wk 48|||||
|wk 49|||||
|wk 50|||||
|Sum  |||||
