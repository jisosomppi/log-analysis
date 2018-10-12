# RELK-physical

![dataflow](https://github.com/jisosomppi/log-analysis/blob/master/builds/relk-physical-working/relk-dataflow.png)

This build only needs rsyslog on the clients, and leaves the heavy work to the server. The logging server receives logs, stores them in folders divided by `/hostname/programname.log`, formats them to proper JSON and sends them to be processed by Elasticsearch. The data contained in Elasticsearch can be easily viewed and studied using Kibana.

Pros:
* Lightweight on clients
  * Only Rsyslog needed, mostly preinstalled
* Fast and easy setup on clients
  * The entire client configuration is:  
`echo "*.* @@[server_ip]:514" | sudo tee -a /etc/rsyslog.conf && sudo service rsyslog restart`
* Pretty well secured
  * Only entries into the server are Rsyslog intake (514/tcp) and Kibana access (5601/tcp)

Cons:
* Logstash is quite heavy on the server
* Origin of logs is not automatically inserted into Elasticsearch

## Techniques, changes, etc
* rsyslog.conf
  * ~~actions rewritten into new syntax~~ *currently not in use*
  * all configuration consolidated into one file
* logstash.conf
  * elasticsearch output defined
  * input defined as file instead of tcp
    * THIS WORKS! Rsyslog never forwarded the log files, but saves and organises them perfectly. 
    * In order to allow Logstash to read the files, it needs permissions: `sudo usermod -a -G adm logstash`
    * Defining the file path as `/var/log/client_logs/*/*.log` targets all the host folders and the all .log files in them

## Known issues
* Giving Logstash admin permissions is probably not the most secure way of doing this
* Currently, the template for the logs is a bit off due to the build configuration
  * hostname for all logs is shown as `logmaster`, the hostname of the server storing the logs
    * Solve by editing templates, foldername -> hostname
* Too much data is being logged
  * Sort out filters on client
* Log severity levels not implemented
* Rotated/archived log files (syslog.1, auth.log.1 etc) are re-ingested upon creation, causing doubles in the logs
