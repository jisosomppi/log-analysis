**I got this stack working and passed log data to Kibana successfully in my last [build](https://github.com/jisosomppi/log-analysis/blob/master/builds/rsyslog-logstash-es-kibana/configuring.md). I would still image that document is a pain to read for me and everyone else, so let's clean it up.**

**This is a working solution on ubuntu 18.04. I doupt it would work on a live-usb. This documents becomes partially invalid once I add a proper client and server structure.**

1) [Install](https://github.com/jisosomppi/log-analysis/blob/master/builds/rsyslog-logstash-es-kibana/Installations.md) Java, Logstash, Elasticsearch and Kibana  
2) Uncomment lines regarding IP and port in *elasticsearch.yml*. Also replace "localhost" with your proper IP.  
3) Activate TCP and UDP modules in rsyslog.conf  
4) Tell Rsyslog to send data to Logstash in /etc/rsyslog.d/60-output.conf by adding line with `*.* @Your_IP:10514;json-template`.    
5) Prepare JSON template and add it to Rsyslog.d (I named it 01-json-template.conf)  
6) Add logstash.conf to /etc/logstash/conf.d/  
```
input {
  udp {
    host  => "172.28.171.230"
    port  => 10514
    codec => "json"
    type  => "rsyslog"
  }
}

filter { }

output {
  elasticsearch { hosts => "http://172.28.171.230:9200" }
  stdout {
    codec    => "json"
  }
}
```
7) Run logstash from /usr/share/logstash/bin and use the configuration file we just made.
8) Ensure logstash is running properly in the right port. `netstat -na | grep 10514` or `sudo netstat -ntlpu` should do the trick.  
9) Configure Kibana with proper IP addresses and ports for itself and connecting to Elasticsearch.
