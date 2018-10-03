

# 1) Bind Elasticsearch to IP address #

Open *elasticsearch.yml* configuration file  
`sudoedit /etc/elasticsearch/elasticsearch.yml`

Find lines with: `network.host:` and `http.port:`. Remove commentation.  
Add IP address and port number to the lines.

Restart elasticsearch:  
`sudo service elasticsearch restart`

Testing elasticsearch with *curl*:  
```
sudo apt-get install -y curl
curl -X GET "your_ip:9200"
```
Output should look something similar:
```
{
  "name" : "2uR_tHN",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "-PI4WBvhRTCHFy4f1WeE8Q",
  "version" : {
    "number" : "6.4.1",
    "build_flavor" : "default",
    "build_type" : "deb",
    "build_hash" : "e36acdb",
    "build_date" : "2018-09-13T22:18:07.696808Z",
    "build_snapshot" : false,
    "lucene_version" : "7.4.0",
    "minimum_wire_compatibility_version" : "5.6.0",
    "minimum_index_compatibility_version" : "5.0.0"
  },
  "tagline" : "You Know, for Search"
}

```

# 2) Configure server to receive data #  

---------------------------
**Huom!**
At a later stage of the stack configuration, we found out that */var/log/syslog* had filled our entire system and took some 450Gb space. By searching information about the problem, I came upon a post that suggested this is caused by `stdout` output somewhere in the configuration files.

The current fix we have, is to disable the following modules in the next step, as you enable *imudp* and *imtcp* modules: *imuxsock* and *imklog*

--------------------------

We load *imudp* and *imtcp* modules in rsyslog.conf -file, which is located under */etc*. These modules are `Input module UDP` and `Input module TCP`. These modules are used for syslog reception.

`sudoedit /etc/rsyslog.conf`  
Delete the commentation about "imtcp" and "imudp" to bring the modules online. 
`sudo service rsyslog restart`


# 3) Configuring Rsyslog to send data #

`sudoedit /etc/rsyslog.d/50-default.conf`  
add `*.*  @@10.x.x.x:514`  
`sudo service rsyslog restart`


# 4) Format logdata to JSON #

`sudoedit /etc/rsyslog.d/01-json-template.conf`
Copy the following into the file:  
```
template(name="json_lines" type="list" option.json="on") {
      constant(value="{")
      constant(value="\"@timestamp\":\"")
      property(name="timereported" dateFormat="rfc3339")
      constant(value="\",\"@version\":\"1")
      constant(value="\",\"message\":\"")
      property(name="msg" format="json")
      constant(value="\",\"sysloghost\":\"")
      property(name="hostname")
      constant(value="\",\"severity\":\"")
      property(name="syslogseverity-text")
      constant(value="\",\"facility\":\"")
      property(name="syslogfacility-text")
      constant(value="\",\"programname\":\"")
      property(name="programname")
      constant(value="\",\"syslog-tag\":\"")
      property(name="syslogtag")
      constant(value="\"}\n")
}
```


# 5) Configure server to send data to logstash #  

`sudoedit /etc/rsyslog.d/60-output.conf`  
```
*.*                         @private_ip_logstash:10514;json-template
```


# 6) Configure Logstash to receive JSON messages. #

Open the *logstash.conf* file under */etc/logstash/*
sudoedit /etc/logstash/conf.d/logstash.conf

add the following to the *logstash.conf* file:
```
input {
  udp {
    host => "logstash_private_ip"   
    port => 10514
    codec => "json"
    type => "rsyslog"
  }
}
filter { }
output {
  if [type] == "rsyslog" {
    elasticsearch {
      hosts => [ "elasticsearch_private_ip:9200" ]
    }
  }
}
```

`sudo service logstash restart`
`sudo systemctl start logstash.service`

Ensure that Logstash is running in port 10514:  
`netstat -na | grep 10514`  

https://www.elastic.co/guide/en/logstash/current/config-setting-files.html


# 7) Configure Kibana #

Open Kibana configuration file under */etc/kibana/*  
`sudoedit /etc/kibana/kibana.yml`

If you want to enable remote connection to Kibana, uncomment the line with:  
`#server.host: "localhost"`  
and replace localhost with your IP. Outcome should look like `server.host: "http://172.28.171.194.9200"`.

Next, you can rename your Kibana server by uncommenting `server.name: " "` line, and adding desired server name.

Finally, uncomment line with `#elasticsearch.url: " "` and add your IP address to match the IP address given in `/etc/elasticseatch/elasticsearch.yml`

One more thing. Restart Kibana to apply configuration changes:  
`sudo service kibana restart`


# 8) Checking Elasticsearch input #

Browse your Kibana. If it doesn't complain about not connecting to elasticsearch, these configurations are fine to some degree. We are still unable to pass data to Kibana, so something is still missing or misconfigured. If your Kibana does connect to Elasticsearch, but there is no data, then the fault should lie in Logstash.  
Browsing http://elasticsearch_IP:9200/_cat/indices?v should give you a hint. Whetever is listed there, should work properly.

Kokeiluun:  
https://www.rsyslog.com/coupling-with-logstash-via-redis/#more-2356 

# What I was missing #  

**Jussi got his Rsyslog-to-elasticsearch-to-kibana build working!**
 

**This build is now obsolete. We have no reason to use a build with logstash, because it consumes much more resources than a stack with just Rsyslog, Elasticsearch and Kibana. I will however try to complete this build.**


I'm fairly sure that the problem lies in either rsyslog or logstash configuration. I tried to make few different kind of *logstash.conf* files.  

Try 1:  
```
# Pull in syslog & rsyslog data
input {
  file {
    path => [
      "/var/log/syslog",
      "/var/log/auth.log"
    ]
    type => [
      "syslog",
      "rsyslog"
    ]
  }
}

# This input block will listen on port 10514 for logs to come in.

input {
  udp {
    host  => "172.28.172.231"
    port  => 10514
    codec => "json"
    type  => [
      "syslog",
      "rsyslog"
    ]
  }
  tcp {
    host  => "172.28.172.231"
    port  => 10514
    codec => "json"
    type  => [
      "syslog",
      "rsyslog"
    ]
  }
}

# Lets leave this empty for now. The filter plugins are used to enrich and transform data.
filter { }

# This output block will send all events of type "syslog" or "rsyslog" to Elasticsearch at the configured host and port
output {
  if [type] =="rsyslog" {
    elasticsearch {
      hosts => [ "172.28.172.231:9200" ]
    }
  }
  if [type] == "syslog" {
    elasticsearch {
      hosts => [ "172.28.172.231:9200" ]
    }
  }
}
```
source: https://opensource.com/article/17/10/logstash-fundamentals

Try 2 (this should be little more simple approach):  
```
input {
  udp {
    host  => "172.28.172.231"
    port  => 10514
    codec => "json"
    type  => [
      "syslog",
      "rsyslog"
    ]
  }
  tcp {
    host  => "172.28.172.231"
    port  => 10514
    codec => "json"
    type  => [
      "syslog",
      "rsyslog"
    ]
  }
}
output {
  elasticsearch { host => "172.28.172.231:9200" }
  stdout {
    codec    => "json"
    protocol => "http"
  }
}
```
I must continue this another day. This file is still missing input (and filter) block. source: https://discuss.elastic.co/t/error-on-logstash-cant-connect-to-elasticsearch/28674/3  
If the file doesn't work, I will follow my next lead: https://deviantony.wordpress.com/2014/09/23/how-to-setup-an-elasticsearch-cluster-with-logstash-on-ubuntu-12-04/  




