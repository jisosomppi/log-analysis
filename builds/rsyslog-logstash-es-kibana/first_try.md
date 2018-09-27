# this version is messy and not working. This was written on 5th week and immediately improved upon. #
New version for the [installation](https://github.com/jisosomppi/log-analysis/blob/master/builds/rsyslog-logstash-es-kibana/Installations.md) and [configuration](https://github.com/jisosomppi/log-analysis/blob/master/builds/rsyslog-logstash-es-kibana/configuring.md) nin the same folder.

---------------------------------------

Install Java 8

sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get update
sudo apt-get -y install oracle-java8-installer

Installing Screen to run Elasticsearch & Kibana there sudo apt-get install -y screen

Start a new screen session with session name: screen -S

Install Elasticsearch and run it in screen

sudo apt-get install -y curl
curl -L -O https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.4.0.tar.gz
tar -xvf elasticsearch-6.4.0.tar.gz
screen (in Screen terminal)
screen -S elasticsearch
cd elasticsearch-6.4.0/bin
./elasticsearch

detach the screen session with Ctrl-a + d

Install Kibana and run it in Screen

wget https://artifacts.elastic.co/downloads/kibana/kibana-6.4.0-linux-x86_64.tar.gz
shasum -a 512 kibana-6.4.0-linux-x86_64.tar.gz
tar -xzf kibana-6.4.0-linux-x86_64.tar.gz
screen -S kibana (in Screen terminal)
cd kibana-6.4.0-linux-x86_64/bin
./kibana

Ctrl-a + D to detach session

Install Rsyslog-elasticsearch
sudo apt-get install rsyslog-elasticsearch

Bind ES to private IP-adress (old syntax)

cd
sudoedit elasticsearch-6.4.0/config/elasticsearch.yml

Uncomment the line with: network.host
The line should now look like:
network.host: 172.28.171.189

Restart elasticsearch by stopping the script and running it again in screen.

screen -r elasticsearch (in Screen terminal)
Ctrl-c
./elasticsearch

At this point we got an error message about too low virtual memory. Increase it by giving the following command:
sudo sysctl -w vm.max_map_count=262144 Run script again and detach Screen session.

./elasticsearch
Ctrl-a + d

Configure server to receive data
sudoedit /etc/rsyslog.conf Uncomment UDP & TCP lines.

Configuring rsyslog to send data remotely:
sudoedit /etc/rsyslog.d/50-default.conf
add a line with: *.* @@172.28.171.189:514
sudo service rsyslog restart

Format logdata to JSON
sudoedit /etc/rsyslog.d/01-json-template.conf
Copy the following into the file:

template(name="json-template"
  type="list") {
    constant(value="{")
      constant(value="\"@timestamp\":\"")     property(name="timereported" dateFormat="rfc3339")
      constant(value="\",\"@version\":\"1")
      constant(value="\",\"message\":\"")     property(name="msg" format="json")
      constant(value="\",\"sysloghost\":\"")  property(name="hostname")
      constant(value="\",\"severity\":\"")    property(name="syslogseverity-text")
      constant(value="\",\"facility\":\"")    property(name="syslogfacility-text")
      constant(value="\",\"programname\":\"") property(name="programname")
      constant(value="\",\"procid\":\"")      property(name="procid")
    constant(value="\"}\n")
}

Installing logstash

curl -L -O https://artifacts.elastic.co/downloads/logstash/logstash-6.4.1.tar.gz
tar -xvf logstash-6.4.1.tar.gz
sudo apt-get install -y default-jre default-jdk

Run ./logstash in Screen session.

cd /logstash-6.4.1/bin
./logtash

We get an error message that directs us to pipelines.yml configuration file in /home/xubuntu/logstash-6.4.1/config/ due to time based limitations I had to stop working for now and didn't find a proper solution to the problem. Next time I will install Logstash, Elasticsearch and Kibana by using apt-get so the files will be under /etc and services will run automatically.
