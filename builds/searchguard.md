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

