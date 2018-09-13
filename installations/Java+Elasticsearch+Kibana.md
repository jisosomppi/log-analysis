# Install java 8 #

**Add the Oracle Java PPA to `apt`:**  
`sudo add-apt-repository -y ppa:webupd8team/java`  

```
sudo apt-get update  
sudo apt-get -y install oracle-java8-installer
```

# Install Elasticsearch #

**Add Elastic's package source list.**  
`sudo wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -`  

**Create the Elasticsearch source list:**  
```
echo "deb http://packages.elastic.co/elasticsearch/2.x/debian stable main" | sudo tee -a /etc/apt/sources.list.d/elasticsearch-2.x.list  
sudo apt-get update  
```

**Install Elasticsearch with command:**  
`sudo apt-get install -y elasticsearch`  
  
# Install Kibana #

**Add the Kibana to your source list:**  
`echo "deb http://packages.elastic.co/kibana/4.5/debian stable main" | sudo tee -a /etc/apt/sources.list`

**Update `apt` package database:**  
`sudo apt-get update`

**Install Kibana with:**  
`sudo apt-get install -y kibana`  


