# rsyslog_elasticsearch_greylog

I followd graylog documentation
http://docs.graylog.org/en/2.4/pages/installation/os/ubuntu.html
 
Installed JDK

`sudo apt-get install apt-transport-https openjdk-8-jre-headless uuid-runtime pwgen curl`

## MongoDB installation

```
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.6.list
sudo apt update
sudo apt-get install -y mongodb-org
```

```
sudo systemctl daemon-reload
sudo systemctl enable mongod.service
sudo systemctl restart mongod.service
```

Checked MongoDB status `sudo systemctl status mongod.service` :
```
● mongod.service - High-performance, schema-free document-oriented database
   Loaded: loaded (/lib/systemd/system/mongod.service; enabled; vendor preset: enabled)
   Active: active (running) since Wed 2018-09-26 14:09:56 EEST; 27s ago
     Docs: https://docs.mongodb.org/manual
 Main PID: 3471 (mongod)
   CGroup: /system.slice/mongod.service
           └─3471 /usr/bin/mongod --config /etc/mongod.conf

syys 26 14:09:56 xubu systemd[1]: Started High-performance, schema-free document-oriented database.
```

## Elasticsearch

```
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-5.x.list
sudo apt-get update && sudo apt-get install elasticsearch
```

I set `cluster.name: graylog` and uncomment line in `/etc/elasticsearch/elasticsearch.yml`

```
sudo systemctl daemon-reload
sudo systemctl enable elasticsearch.service
sudo systemctl restart elasticsearch.service
```
Tested elsaticsearch with
`curl -X GET "localhost:9200/"`

## Graylog

```
wget https://packages.graylog2.org/repo/packages/graylog-2.4-repository_latest.deb
sudo dpkg -i graylog-2.4-repository_latest.deb
sudo apt-get update && sudo apt-get install graylog-server
```

Set `password_secret` and `root_password_sha2` in `/etc/graylog/server/server.conf`

Generated password using `pwgen -N 1 -s 96` as shown in the conf file
and a hash of the pass usin `echo -n "pass you generated" | sha256sum` (that command will generate additional `a space and a line, don't copy them`


To be able to connect to Graylog you should set `rest_listen_uri` and `web_listen_uri` to the public host name.
In default config this means uncommentig `we_listen_uri`

```
sudo systemctl daemon-reload
sudo systemctl enable graylog-server.service
sudo systemctl start graylog-server.service
```

For some reason graylog-server won't start:

```
xubu@xubu:~/rsyslog_greylog$ sudo systemctl status graylog-server.service 
● graylog-server.service - Graylog server
   Loaded: loaded (/usr/lib/systemd/system/graylog-server.service; enabled; vendor preset: enabled)
   Active: activating (auto-restart) (Result: exit-code) since Fri 2018-09-21 16:19:18 EEST; 825ms ago
     Docs: http://docs.graylog.org/
  Process: 14675 ExecStart=/usr/share/graylog-server/bin/graylog-server (code=exited, status=1/FAILURE)
 Main PID: 14675 (code=exited, status=1/FAILURE)
```
I uninstalled and reinstalled openjdk-8 and graylog started working.

Next problem was with login to graylog.
I had cpied the hash of password to server.cong with additional " -" that broke the thing.
After erasing them I finally was able to log inside.

Tested Graylog by opening `http://lovalhost:9000/` and logged in with credentials found in graylog `server.conf`

## Sending logdata to Graylog

Tried simple and unsafe way to send logs from Rsyslog to Graylog with instructions found at https://ashleyhindle.com/how-to-setup-graylog2-and-get-logs-into-it/

Inserted line `*.* @@localhost:5140;RSYSLOG_SyslogProtocol23Format` to `/etc/rsyslog.d/50-default.conf`
and restarted rsyslog `sudo service rsyslog restart`

On Graylog web interface configured System -> Inputs -> Syslog UDP

![kuve1](https://github.com/jisosomppi/log-analysis/blob/master/builds/rsyslog-graylog/kuve1.png)

