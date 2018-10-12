# RELK-physical

![dataflow](https://github.com/jisosomppi/log-analysis/blob/master/builds/relk-physical-working/relk-dataflow.png)

Data flow:

Rsyslog client -`514/tcp(remote)`-> Rsyslog server -`write`->  
local log files on server  
<-`read`- Logstash -`9200/tcp(localhost)`-> Elasticsearch <-`9200/tcp(localhost)`- Kibana <-`5601/tcp(remote)`- Browser

This build is a second version of the physical stack, and attempts were made to make it work both with Logstash and without.
The configuration is non-functional, but stored for possible future use.

## Techniques, changes, etc
* rsyslog.conf
  * ~~actions rewritten into new syntax~~ *currently not in use*
  * all configuration consolidated into one file
* logstash.conf
  * elasticsearch output defined
  * input defined as file instead of tcp
    * THIS WORKS! Rsyslog never forwarded the log files, but saves and organises them perfectly. 
    * In order to allow Logstash to read the files, it needs permissions: `sudo usermod -a -G adm logstash`

## Known issues
* Giving Logstash admin permissions is probably not the most secure way of doing this
* Currently, the template for the logs is a bit off due to the config
  * hostname for all logs is shown as `logmaster`, the hostname of the server storing the logs
    * Solve by editing templates, foldername -> hostname
* Too much data is being logged
  * Sort out filters on client
* Log severity levels not implemented
