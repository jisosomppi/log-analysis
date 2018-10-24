# Limiting access to Elasticsearch with login and password with [readonlyREST](https://readonlyrest.com/download/) module.

I found and old post written by my teacher, [Tero Karvinen](http://terokarvinen.com/2016/elasticsearch-password-authentication-with-free-software) and I will be using it as my primary source as I setup my Elasticsearch with additional security.

Firstly, I went through my usual [setup](https://github.com/jisosomppi/log-analysis/blob/master/builds/rsyslog-logstash-es-kibana/Installations.md) for updates, Java and Elasticsearch installation.

Next, I enabled firewall, because by default, Elasticsearch has no security.  
`sudo ufw enable`

After enabling firewall, I made few changes to the *Elasticsearch.yml* file. I Uncommented and replaced lines regarding IP address and http port. Making changes into the configuration also requires a restart.  
`sudo service elasticsearch restart`

Next, I wanted to know if Elasticsearch is running properly so I used *Curl* to find out. I had to install it first though.  
```  
sudo apt-get install -y curl  
curl localhost:9200  
```  
![kuva1](https://i.imgur.com/gkdoI18.png)  

Next, I need to install the *readonlyREST* plugin. Tero's command didn't work for me, and even if it did, it would still have outdated version. So, lets find out which version we need.  
In readonlyREST [download page](https://readonlyrest.com/download/) you need to fill out the wanted product (elasticsearch plugin), elasticsearch version and your email address, to which the site will send a download link for the plugin. This was kinda off putting, but I didn't find an easy alternative so lets just go with it. Our elasticsearch version is 6.4.2 (We found this out in the previous step where we curled the localhost port 9200).  

I opened downloaded the zip file from the link sent to my email and followed the steps in the email to some degree.  
![kuva3](https://i.imgur.com/QLC01pK.png)  

First, I moved to my download folder and ran the command  
`/usr/share/elasticsearch/bin/elasticsearch-plugin install file:readonlyrest-1.16.28_es6.4.2.zip`  

This seemed to work properly. However, a question about permissions rose up, because this is the exact same looking thing that crashed my ElasticSearch when I tried to install SearchGuard.
![kuva2](https://i.imgur.com/EZPLz4O.png)

The plugin can be removed with:  
`sudo /usr/share/elasticsearch/bin/elasticsearch-plugin remove readonlyrest`

Now, according to Tero's post, we should add *readonlyREST* configuration into the *elasticsearch.yml*.

Ongelmia javassa:  
https://docs.oracle.com/javase/8/docs/technotes/guides/security/permissions.html
