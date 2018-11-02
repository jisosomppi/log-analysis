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

**UPDATED. You can download the zip file from out github [downloads folder](https://github.com/jisosomppi/log-analysis/blob/master/downloads/readonlyrest-1.16.28_es6.4.2.zip) or with wget:**  
`wget https://github.com/jisosomppi/log-analysis/raw/master/downloads/readonlyrest-1.16.28_es6.4.2.zip`

I opened downloaded the zip file from the link sent to my email and followed the steps in the email to some degree.  
![kuva3](https://i.imgur.com/QLC01pK.png)  

First, I moved to my download folder and ran the command  
`/absolute/path/elasticsearch-plugin install file:///absolute/path/readonlyrest-1.16.28_es6.4.2.zip`  

This seemed to work properly. However, a question about permissions rose up, because this is the exact same looking thing that crashed my ElasticSearch when I tried to install SearchGuard.
![kuva2](https://i.imgur.com/EZPLz4O.png)

The plugin can be removed with:  
`sudo /usr/share/elasticsearch/bin/elasticsearch-plugin remove readonlyrest`

~~Now, according to Tero's post, we should add *readonlyREST* configuration into the *elasticsearch.yml*.~~
This is outdated, and doesn't work in newer versions (from 6.1 onwards if I'm not mistaken). Instead of adding the configuration into the *elasticsearch.yml* file, you should create a new file called *readonlyrest.yml* to the same folder and add the configuration there.  
```
readonlyrest:
 enable: true
 response_if_req_forbidden: Sorry, your request is forbidden.
 access_control_rules:
 - name: Full access with HTTP auth
   auth_key: yourpassword
   type: allow
```

Opensource ElasticSearch (without x-pack and some other plugins which we currently have no use for anyway):  
https://www.elastic.co/downloads/elasticsearch-oss  
I still have no idea how to get the oss version of elasticsearch with apt-get installation. I'll look into it later.

I got the plugin running for the first time! Here are my steps so far:  
**1) Installing java**  
```
sudo apt-get install -y default-jre
sudo apt-get install -y default-jdk
```
**2) Installing Elasticsearch**  
```
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo apt-get install apt-transport-https
echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list
sudo apt-get update
sudo apt-get install elasticsearch
```
**3) Installing readonlyREST**  
By curling localhost:9200 to see if elasticsearch is running, you also find out the version you installed. Mine is 6.4.2.  
Next, I got the download link from [readonlyREST web page](https://readonlyrest.com/download/).

**UPDATED**  
As stated earlier in the post, you can now download the installation file from our github [downloads folder](https://github.com/jisosomppi/log-analysis/blob/master/downloads/readonlyrest-1.16.28_es6.4.2.zip) if you don't wish to get an email link.  
`wget https://github.com/jisosomppi/log-analysis/raw/master/downloads/readonlyrest-1.16.28_es6.4.2.zip` should also work.

After I downloaded the plugin zip, I installed it using abosute paths:  
`sudo /usr/share/elasticsearch/bin/elasticsearch-plugin install file:///home/xubuntu/Downloads/readonlyrest-1.16.28_es6.4.2.zip`

**4) Setting up readonlyrest.yml to /etc/elasticsearch**
Previously, I tried to run elasticsearch after installing the plugin and received a lot of errors. Not one installation guide told me to actually create the configuration file before starting the program. If I understood correctly, since ElasticSearch version 6.1 you have to create *readonlyrest.yml* instead of putting the configurations into *elasticsearch.yml*.

I found and example of *readonlyrest.yml* from https://mpolinowski.github.io/securing-elasticsearch-readonlyrest/. This link seems to have some strange syntax, so I used Tero's post as a base.  
```
sudo nano /etc/elasticsearch/readonlyrest.yml


readonlyrest:
  enable: true
  response_if_req_forbidden: Access denied.
  access_control_rules:
  - name: Full access with HTTP auth
    auth_key: user:pass
    type: allow
```
In this case the username used to log in is user, and password is pass.

This is where I ran into another problem. `sudo service elasticsearch restart` and `sudo service elasticsearch status` tell me that the service is active and running, but nothing is actually running in port 9200 and the service hasn't properly started.

I tried to remove the plugin and see if elasticsearch runs without it. It did. I am currently unsure what causes this mess.

Found solution from https://github.com/beshu-tech/readonlyrest-docs/blob/master/elasticsearch.md.
I had a feeling that x-pack and readonlyREST cannot run simultaneously, but x-pack wasn't listed in active plugins and I didn't really think it would have be the cause of my headache.

The solution was to add the following line into *elasticsearch.yml* configuration file:  
`xpack.security.enabled: false`  

![it-works](https://i.imgur.com/6X6I62A.png)


### Next up, we're setting up reverse proxy for Kibana with Nginx ###  

I found these pages to get me started:  
https://mpolinowski.github.io/nginx-node-security  
https://blog.ruanbekker.com/blog/2017/09/16/nginx-reverse-proxy-for-elasticsearch-and-kibana-5-on-aws/  
https://www.elastic.co/blog/playing-http-tricks-nginx (this seems like a good place to begin)  
https://gist.github.com/Dev-Dipesh/2ac30a8a01afb7f65b2192928a875aa1

**Before going more deeply into Nginx, I installed Kibana and made some very basic configurations to *kibana.yml* file. This extended the authentication provided by *readonlyREST* to Kibana login.**

I installed Kibana with the following commands:  
```
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list
sudo apt-get update && sudo apt-get install kibana
```
Next, I activated the lines about authentication in *kibana.yml* (under /etc/kibana/) and added the credentials used by ElasticSearch.  
After restarting kibana and visiting kibana web page I got the following:

![kibana-auth](https://i.imgur.com/ilQChzy.png)

At this point, we have locked ElasticSearch and Kibana behind basic authentication. They are running locally in localhost address. However, we would also like to be able to connect to Kibana remotely once the server is up, so a (reverse) proxy is needed.  
I started reading on the links I put up earlier, but didn't really get a clear picture of setting up Nginx.  
I followed this [github page](https://gist.github.com/Dev-Dipesh/2ac30a8a01afb7f65b2192928a875aa1) written Dev-Dipesh.

Basically, I had set everything else up already, so I only needed to install Nginx, write a configuration file and restart it.  

I installed nginx and required apache utilities with:  
`sudo apt-get install nginx apache2-utils`

After this, I opened the configuration file
`sudoedit /etc/nginx/sites-available/default`

and rewrote the contents
```
server {
  listen 80;
    server_name kibana;


  error_log   /var/log/nginx/kibana.error.log;
  access_log  /var/log/nginx/kibana.access.log;



  location / {
    rewrite ^/(.*) /$1 break;
    proxy_ignore_client_abort on;
    proxy_pass http://localhost:5601;
    proxy_set_header  X-Real-IP  $remote_addr;
    proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header  Host $http_host;

  }
}
```
After this I restarted Nginx and checked my "home page".  
`ifconfig`
My computer's IP address is 172.28.171.32.  ---> http://172.28.171.32

![kibanaception](https://i.imgur.com/Gfnfn7o.png)  
Note: I also went through authentication, just like earlier when I connected to Kibana for the first time.  
It would seem like everything worked. This will be enough for today, next time I will look into the configurations more deeply.


https://www.linode.com/docs/web-servers/nginx/nginx-installation-and-basic-setup/ This has been a good source to gain more information about Nginx configurations.  
I'm working on Ubuntu 16.04 Live-usb, so I will have to start from scratch again. Lets install Nginx again and see what the default files look like. 

So, lets recap. To install Nginx I ran the following command:  
`sudo apt-get install nginx apache2-utils`  

I think installing some java is also recommended when starting fresh:  
```
sudo apt-get install -y default-jre
sudo apt-get install -y default-jdk
```

The configuration files can be found under */etc*. According to the page I linked, it's good idea to uncomment the line with:  
`server_tokens off;`

"NGINX’s version number is visible by default with any connection made to the server, whether by a successful 201 connection by cURL, or a 404 returned to a browser. Disabling server tokens makes it more difficult to determine NGINX’s version, and therefore more difficult for an attacker to execute version-specific attacks."

Last time I restarted Nginx using `sudo service nginx restart`. According to the guide I linked, `nginx -s reload` should also work.



## Supporting IPv6 in Nginx ##
Next, the aforementioned link indicates, that some versions of nginx don't support IPv6 by default. I found [this article](https://kovyrin.net/2010/01/16/enabling-ipv6-support-in-nginx/) to be helpful on the matter.  

I can't get it working right now.. Seems like I have to reinstall Nginx from source code and after that enable IPv6 in configurations. I'm having problems installing the program from source.
```
./configure --without-http_autoindex_module --without-http_userid_module \
--without-http_auth_basic_module --without-http_geo_module \
--without-http_fastcgi_module --without-http_empty_gif_module \
--with-poll_module --with-http_stub_status_module \
--with-http_ssl_module --with-ipv6
```

**Additional links I used on the matter**  
https://www.cyberciti.biz/faq/nginx-ipv6-configuration/  
https://www.linode.com/docs/web-servers/nginx/nginx-installation-and-basic-setup/  
https://docs.nginx.com/nginx/admin-guide/installing-nginx/installing-nginx-open-source/#sources_download  
https://linuxconfig.org/how-to-install-gcc-the-c-compiler-on-ubuntu-18-04-bionic-beaver-linux  




