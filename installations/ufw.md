Service|Port|Protocol
-------|----|--------
SSH|22|TCP
Rsyslog|514|TCP
Rsyslog|514|UDP
Salt|4505|TCP
Salt|4506|TCP
Kibana|5601|TCP
Elasticsearch|9200|TCP
Elasticsearch|9300|TCP
Logstash|10514|TCP
Nginx|80|TCP


SSH  
172.28.0.0/16  
Portti: 22  
Protokolla: TCP  
`sudo ufw allow from 172.28.0.0/16 proto tcp to any port 22
`

Rsyslog  
172.28.0.0/16  
Portti: 514  
Protokollat: UDP ja TCP  
```
sudo ufw allow proto tcp from 172.28.0.0/16 to any port 514
sudo ufw allow proto udp from 172.28.0.0/16 to any port 514

```

Salt  
172.28.0.0/16  
Portit 4505 ja 4506  
```
sudo ufw allow proto tcp from 172.28.0.0/16 to any port 4505
sudo ufw allow proto tcp from 172.28.0.0/16 to any port 4506

```

Kibana  
Localhost  
Portti: 5601  
`sudo ufw allow from 127.0.0.1 to 127.0.0.1 port 5601 proto tcp
`

Elasticsearch  
Localhost  
Portit 9200 ja 9300  
```
sudo ufw allow from 127.0.0.1 to 127.0.0.1 port 9200 proto tcp
sudo ufw allow from 127.0.0.1 to 127.0.0.1 port 9300 proto tcp

```

Logstash  
Ei avata  

Nginx  
172.28.0.0/16  
Portti 80  
Protokolla: TCP  
`sudo ufw allow proto tcp from 172.28.0.0/16 to any port 80
`
