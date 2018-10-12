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


Sources today:  
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
