### Following readonlyREST, we're setting up reverse proxy for Kibana with Nginx ###  

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


**Next we're configuring Nginx to use our self-signed certificates. Continue [here](https://github.com/jisosomppi/log-analysis/blob/master/documentation/ssl.md).**
