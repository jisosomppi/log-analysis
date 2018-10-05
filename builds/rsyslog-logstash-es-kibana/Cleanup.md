**I got this stack working and passed log data to Kibana successfully in my last [build](https://github.com/jisosomppi/log-analysis/blob/master/builds/rsyslog-logstash-es-kibana/configuring.md). I would still image that document is a pain to read for me and everyone else, so let's clean it up.**

**This is a working solution on ubuntu 18.04. I doupt it would work on a live-usb. This documents becomes partially invalid once I add a proper client and server structure.**

1) [Installing](https://github.com/jisosomppi/log-analysis/blob/master/builds/rsyslog-logstash-es-kibana/Installations.md) Java, Logstash, Elasticsearch and Kibana was the first step for me.  
2) Uncommenting and replacing lines regarding IP address and port in *elasticsearch.yml* lets you connect to Elasticsearch remotely.  
3) At this point I uncommented *imudp* and *imtcp* modules to activate tcp & udp reception in rsyslog.conf under */etc*  
4) I enabled Rsyslog to send data to Logstash in /etc/rsyslog.d/60-output.conf by adding line with `*.* @Your_IP:10514;json-template`.  
5) Next I prepare my JSON template and added it to Rsyslog.d (I named it 01-json-template.conf).  
6) I created my logstash.conf to /etc/logstash/conf.d/. This directory shoud be empty by default.  
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
7) I verified my logstash configuration with the following command:  
`sudo -u logstash /usr/share/logstash/bin/logstash --path.settings /etc/logstash -t`
8) Next I started logstash from /usr/share/logstash/bin using the configuration file I just made.
9) At this point I wanted to ensure logstash is running properly in the right port. `netstat -na | grep 10514` or `sudo netstat -ntlpu` should both do the trick.  
10) Lastly, I configured Kibana with proper IP addresses and ports for itself and connecting to Elasticsearch. If I remember correctly, starting Kibana required more than just `sudo service kibana restart`. I ran 3 commands:  
```
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable kibana.service
sudo systemctl start kibana.service

```
