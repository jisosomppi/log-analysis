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

**Download Kibana 6.4.0 tar:**  
`wget https://artifacts.elastic.co/downloads/kibana/kibana-6.4.0-linux-x86_64.tar.gz`

**Check the integrity of the packet:**  
`shasum -a 512 kibana-6.4.0-linux-x86_64.tar.gz `

**Open the tar:**  
`tar -xzf kibana-6.4.0-linux-x86_64.tar.gz`

**Move to the correct directory:**  
`cd kibana-6.4.0-linux-x86_64/ `

**Install Kibana with:**  
`./

