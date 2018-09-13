# Install java 8 #

**Add the Oracle Java PPA to `apt`:**  
`sudo add-apt-repository -y ppa:webupd8team/java`  

```
sudo apt-get update  
sudo apt-get -y install oracle-java8-installer
```

# Install Elasticsearch #

**Download The elasticsearch 6.4.0 tar**  
`curl -L -O https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.4.0.tar.gz`  

**Then extract it as follows:**  
`tar -xvf elasticsearch-6.4.0.tar.gz`

**Go into the bin directory:**
`cd elasticsearch-6.4.0/bin`

**Install Elasticsearch by running the script:**  
`./elasticsearch`  
  
# Install Kibana #

**Add the Kibana to your source list:**  
`echo "deb http://packages.elastic.co/kibana/4.5/debian stable main" | sudo tee -a /etc/apt/sources.list`

**Update `apt` package database:**  
`sudo apt-get update`

**Install Kibana with:**  
`sudo apt-get install -y kibana`  


