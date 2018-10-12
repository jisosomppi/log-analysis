## Looking into integrating Search Guard to Kibana

`In the following description, we assume that you have already set up a Search Guard secured Elasticsearch cluster. We’ll walk through all additional steps needed for integrating Kibana with your setup.`  

`We also assume that you have enabled TLS support on the REST layer via Search Guard SSL. While this is optional, we strongly recommend using this feature. Otherwise, traffic between Kibana and Elasticsearch is made via unsecure HTTP calls, and thus can be sniffed.`  

~~To my best knowledge, Eino is working on the previously mentioned requirements, so I will start looking into securing Kibana. At a later stage we will merge our work into a working solution.~~
Scratch that, it would seem like I have to start working on implementing Search Guard to Elasticsearch first.  

Sources:  
https://docs.search-guard.com/latest/kibana-plugin-installation  
https://www.elastic.co/guide/en/kibana/current/using-kibana-with-security.html  


## About Search Guard
https://search-guard.com/wp-content/uploads/2018/03/SG_Licensing-model-overview.pdf  
https://search-guard.com/licensing/

-Search Guard seems to be completely open source  
-We will be using the community edition

**From Search Guard pages:**
```
Search Guard offers all basic security features for free. The Community Edition of Search Guard can be used for all projects, including commercial projects, at absolutely no cost. The Community Edition includes:  
-Full data in transit encryption  
-Node-to-node encryption  
-Index level access control  
-Document type based access control  
-User-, role- and permission management  
-HTTP basic authentication  
-User Impersonation  
-Proxy support  
```

## Search Guard --> Elasticsearch

Sources:
https://github.com/floragunncom/search-guard  
https://www.syslog-ng.com/community/b/blog/posts/securing-esk-stack-free-using-search-guard/  


For *Search Guard* demo installation:
```
cd /usr/share/elasticsearch/bin
./elasticsearch-plugin install -b com.floragunn:search-guard-6:6.4.2-23.1
```

The *Search Guard* version has to match that of the *Elasticsearch* & *Kibana*. The correct version / artifact can be found in:  
https://docs.search-guard.com/latest/search-guard-versions

Lets move into the Searh Guard directory and find the demo installation script. I found it in:  
`/usr/share/elasticsearch/plugins/search-guard-6/tools`

First, we need to use **chmod** on the script, to be able to run it. I used `chmod +x`, but I'm well aware, that it might not be the most secure way to do things. However, I will wipe this computer after I'm done for today. 

https://docs.search-guard.com/latest/demo-installer  
https://docs.search-guard.com/latest/search-guard-versions  
https://fi.wikipedia.org/wiki/Chmod  


files created by the SG installation can be found under  
`/usr/share/elasticsearch/plugins/search-guard-6/sgconfig/`  

Lets take a quick look at the files.

## Elasticsearch.yml.example  
-Settings found in this file should be added to the standard elasticsearch.yml configuration file alongside with the 
Search Guard TSL settings.  


This line should be commented away. The enterprise modules are enabled by default and require licence if used in production. We could be eligible to use these modules in our project, but our end goal is to make an open source solution, so best ignore these modules from the get-go.  
`searchguard.enterprise_modules_enabled: true`  


This part is used to specify distinguished names which denote the other nodes in the cluster. Supports wilcards and regular expressions. This setting only has effect if 'searchguard.cert.intercluster_request_evaluator_class' is not set.  
```
searchguard.nodes_dn:
  - "CN=*.example.com, OU=SSL, O=Test, L=Test, C=DE"
  - "CN=node.other.com, OU=SSL, O=Test, L=Test, C=DE"
```


This block defines which DNs (distinguished names) of certificates admin privileges should be assigned to. 
```
searchguard.authcz.admin_dn:
  - "CN=kirk,OU=client,O=client,l=tEst, C=De"
```

The bare minimum Search Guard configuration consists of the TLS settings on transport layer and at least one admin certificate for initializing the Search Guard index. This is configured in elasticsearch.yml, all paths to certificates must be specified relative to the Elasticsearch config directory:
```
searchguard.ssl.transport.pemcert_filepath: <path_to_node_certificate>
searchguard.ssl.transport.pemkey_filepath: <path_to_node_certificate_key>
searchguard.ssl.transport.pemkey_password: <key_password (optional)>
searchguard.ssl.transport.pemtrustedcas_filepath: <path_to_root_ca>
searchguard.ssl.transport.enforce_hostname_verification: <true | false>

searchguard.authcz.admin_dn:
  - CN=kirk,OU=client,O=client,L=test, C=de
```
If you want to use TLS also on the REST layer (HTTPS), add the following lines to elasticsearch.yml:  
```
searchguard.ssl.http.enabled: true
searchguard.ssl.http.pemcert_filepath: <path_to_http_certificate>
searchguard.ssl.http.pemkey_filepath: <path_to_http_certificate_key>
searchguard.ssl.http.pemkey_password: <key_password (optional)>
searchguard.ssl.http.pemtrustedcas_filepath: <path_to_http_root_ca>
```
You can use the same certificates on the transport and on the REST layer. For production systems, we recommend to use individual certificates.

https://docs.search-guard.com/latest/search-guard-installation
https://sematext.com/blog/elasticsearch-kibana-security-search-guard/

running Search Guard demo-installation seems to break Elasticsearch for some reason. After the installation, I am still unable to run Elasticsearch, even after commenting whatever changes SG made to `elasticsearch.yml`.
![kuva1](https://i.imgur.com/4s6RK3i.png)

Found some tips for troubleshooting:  
https://stackoverflow.com/questions/29615414/elasticsearch-systemd-service-failing  

Ran command:  
```
sudo -u elasticsearch /usr/share/elasticsearch/bin/elasticsearch \ -Des.pidfile=/var/run/elasticsearch/elasticsearch.pid \ -Des.default.path.home=/usr/share/elasticsearch \ -Des.default.path.logs=/var/log/elasticsearch \ -Des.default.path.data=/var/lib/elasticsearch \ -Des.default.path.conf=/etc/elasticsearch
```
![kuva2](https://i.imgur.com/85niHpt.png)

I'm not sure what to make of the response.  
```
Option                Description                                               
------                -----------                                               
-E <KeyValuePair>     Configure a setting                                       
-V, --version         Prints elasticsearch version information and exits        
-d, --daemonize       Starts Elasticsearch in the background                    
-h, --help            show help                                                 
-p, --pidfile <Path>  Creates a pid file in the specified path on start         
-q, --quiet           Turns off standard output/error streams logging in console
-s, --silent          show minimal output                                       
-v, --verbose         show verbose output                                       
ERROR: Positional arguments not allowed, found [ -Des.pidfile=/var/run/elasticsearch/elasticsearch.pid,  -Des.default.path.home=/usr/share/elasticsearch,  -Des.default.path.logs=/var/log/elasticsearch,  -Des.default.path.data=/var/lib/elasticsearch,  -Des.default.path.conf=/etc/elasticsearch]
```
--------------------------------------------
It would seem like it's not the Search Guard demo-installation that breaks the Elasticsearch, but rather the installation of the plugin itself.  

![kuva3](https://i.imgur.com/mgXu7im.png)  
This is what pretty much what I got after running  
`./elasticsearch-plugin install -b com.floragunn:search-guard-6:6.4.2-23.1`

The tutorials I followed only mention a prompt, to which you should answer *yes* to get rid of any permission related errors. However, I never got this prompt, and after the plugin installation stops, I can no longer start Elasticsearch service.
