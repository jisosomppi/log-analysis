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

**UPDATE! it seems like the current apt installed version of Nginx supports IPv6 without any further configurations**

I can't get it working right now.. Seems like I have to reinstall Nginx from source code and after that enable IPv6 in configurations. I'm having problems installing the program from source.
```
./configure --without-http_autoindex_module --without-http_userid_module \
--without-http_auth_basic_module --without-http_geo_module \
--without-http_fastcgi_module --without-http_empty_gif_module \
--with-poll_module --with-http_stub_status_module \
--with-http_ssl_module --with-ipv6
```

I had to install these packages in order for the command to work:  
**C Compiler**  
```
sudo apt install gcc
sudo apt install build-essential
```
**PCRE Library**  
`sudo apt-get install libpcre3 libpcre3-dev`

**SSL Library**  
`sudo apt-get install libssl-dev`

**ZLib**  
`sudo apt install zlib1g-dev`



After several attemps I ran the command succesfully and got the following:  
```
Configuration summary
  + using system PCRE library
  + using system OpenSSL library
  + using system zlib library

  nginx path prefix: "/usr/local/nginx"
  nginx binary file: "/usr/local/nginx/sbin/nginx"
  nginx modules path: "/usr/local/nginx/modules"
  nginx configuration prefix: "/usr/local/nginx/conf"
  nginx configuration file: "/usr/local/nginx/conf/nginx.conf"
  nginx pid file: "/usr/local/nginx/logs/nginx.pid"
  nginx error log file: "/usr/local/nginx/logs/error.log"
  nginx http access log file: "/usr/local/nginx/logs/access.log"
  nginx http client request body temporary files: "client_body_temp"
  nginx http proxy temporary files: "proxy_temp"
  nginx http uwsgi temporary files: "uwsgi_temp"
  nginx http scgi temporary files: "scgi_temp"

./configure: warning: the "--with-ipv6" option is deprecated
```
The last line leads me to believe that IPv6 is already configured into the packet.. This however hasn't been made clear in any point. I guess the only thing left to do is to find the configuration files and make the necessary changes.

I have a feeling there is no need to even configure anything in the current versions.. I'll test this with a fresh install on live-usb.  

Using the following command for testing:  
`netstat -tulpna | grep nginx`

**Additional links I used on the matter**  
https://www.cyberciti.biz/faq/nginx-ipv6-configuration/  
https://www.linode.com/docs/web-servers/nginx/nginx-installation-and-basic-setup/  
https://docs.nginx.com/nginx/admin-guide/installing-nginx/installing-nginx-open-source/#sources_download  
https://linuxconfig.org/how-to-install-gcc-the-c-compiler-on-ubuntu-18-04-bionic-beaver-linux  


# Creating Nginx server blocks and self-signing ssl certificate #  

By default, Nginx on Ubuntu 16.04 has one server block enabled by default. It is configured to serve documents out of a directory at /var/www/html.

**Step 1: Setting Up New Document Root Directories**

I created a directory structure in */var/www/* for each server block (or site).  
```
sudo mkdir -p /var/www/test.com/html  
sudo mkdir -p /var/www/test2.com/html
```

**Step 2: Creating Sample Pages for Each Site**

After this, I created a default page for each of these sites.  
`sudoedit /var/www/test.com/html/index.html`
```
<html>
    <head>
        <title>This is a test site</title>
    </head>
    <body>
        <h1>Success. The test.com server block is working</h1>
    </body>
</html>
```
Repeating the same for the other server block (test2.com)


**Step 3: Creating Server Block Files for Each Domain**

I created the first server block config by copying over the default file:  
`sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/test.com`  

After copying the file, I opened it to make some changes. For starters I removed `default_server` from the lines with *listen*. Next I fixed the *root* path and added the server name.
```
/etc/nginx/sites-available/example.com
server {
        listen 80;
        listen [::]:80;

        root /var/www/test.com/html;
        index index.html index.htm index.nginx-debian.html;

        server_name test.com www.test.com;

        location / {
                try_files $uri $uri/ =404;
        }
}
```
After this, I repeated the steps for the second domain.


**Step 4: Enabling the Server Blocks and Restarting Nginx**

Now that I have my server block files, I need to enable them. I can do this by creating symbolic links from these files to the sites-enabled directory, which Nginx reads from during startup.

These links can be created by typing:  
```
sudo ln -s /etc/nginx/sites-available/test.com /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/test2.com /etc/nginx/sites-enabled/
```

Next, I made a small change to the *nginx.conf*.  I uncommented the `server_names_hash_bucket_size 64;` line in order to avoid a possible hash bucket memory problem that can arise from adding additional server names.  

The server blocks should be fine now, so next I just tested the configuration with:  
`sudo nginx -t`  
and restarted the service with:  
`sudo service nginx restart`

Lastly, I went to `/etc/hosts` and added the following lines to the file:  
```
your_ip_address test.com www.test.com
your_ip_address test2.com www.test2.com
```

**Next, I'd suggest anyone reading this to consult this [guide](https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-in-ubuntu-16-04) for better understanding about self-signing certs.**

As mentioned, my knowledge about certs is severely lacking, so I will just follow the steps provided by the source I linked.

**Step 1: Create the SSL Certificate**  
TLS/SSL works by using a combination of a public certificate and a private key. The SSL key is kept secret on the server. It is used to encrypt content sent to clients. The SSL certificate is publicly shared with anyone requesting the content. It can be used to decrypt the content signed by the associated SSL key.

We can create a self-signed key and certificate pair with OpenSSL in a single command:  
`sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt`  

Lets walk through this command step by step.   

**openssl**: This is the basic command line tool for creating and managing OpenSSL certificates, keys and other files.  
**req**:This subcommand specifies that we want to use X.509 certificate signing request (CSR) management. The "X.509" is a public key infrastructure standard that SSL and TLS adheres to for its key and certificate management. We want to create a new X.509 cert, so we are using this subcommand.  
**-x509**: This further modifies the previous subcommand by telling the utility that we want to make a self-signed certificate instead of generating a certificate signing request, as would normally happen.  
**-nodes**: This tells OpenSSL to skip the option to secure our certificate with a passphrase. We need Nginx to be able to read the file, without user intervention, when the server starts up. A passphrase would prevent this from happening because we would have to enter it after every restart.  
**-days 365**: This option sets the length of time that the certificate will be considered valid. We set it for one year here.  
**-newkey rsa:2048**: This specifies that we want to generate a new certificate and a new key at the same time. We did not create the key that is required to sign the certificate in a previous step, so we need to create it along with the certificate. The rsa:2048 portion tells it to make an RSA key that is 2048 bits long.  
**-keyout**: This line tells OpenSSL where to place the generated private key file that we are creating.  
**-out**: This tells OpenSSL where to place the certificate that we are creating.

These options will create both a key file and a certificate. We will be asked a few questions about our server in order to embed the information correctly in the certificate.  
The most important line is the one that requests the `Common Name` (e.g. server FQDN or YOUR name). You need to enter the domain name associated with your server or, more likely, your server's public IP address.  
Both of the files you created will be placed in the appropriate subdirectories of the `/etc/ssl` directory.

While we are using OpenSSL, we should also create a strong Diffie-Hellman group, which is used in negotiating [Forward Secrecy](https://en.wikipedia.org/wiki/Forward_secrecy) with clients.

We can do this by typing:  
`sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048`


**Step 2: Configure Nginx to Use SSL**

We have created our key and certificate files under the `/etc/ssl` directory. Now we just need to modify our Nginx configuration to take advantage of these.  

**Create a Configuration Snippet Pointing to the SSL Key and Certificate**  
first, let's create a new Nginx configuration snippet in the /etc/nginx/snippets directory.  
To properly distinguish the purpose of this file, let's call it `self-signed.conf`:
`sudoedit /etc/nginx/snippets/self-signed.conf`
Adding the lines:  
```
ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;
```

**Create a Configuration Snippet with Strong Encryption Settings**  
Next, we will create another snippet that will define some SSL settings. This will set Nginx up with a strong SSL cipher suite and enable some advanced features that will help keep our server secure.

The parameters we will set can be reused in future Nginx configurations, so we will give the file a generic name:  
 `sudoedit /etc/nginx/snippets/ssl-params.conf`
 ```
ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
ssl_prefer_server_ciphers on;
ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";
ssl_ecdh_curve secp384r1;
ssl_session_cache shared:SSL:10m;
ssl_session_tickets off;
#ssl_stapling on;
#ssl_stapling_verify on;
resolver 8.8.8.8 8.8.4.4 valid=300s;
resolver_timeout 5s;
# Disable preloading HSTS for now.  You can use the commented out header line that includes
# the "preload" directive if you understand the implications.
#add_header Strict-Transport-Security "max-age=63072000; includeSubdomains; preload";
add_header Strict-Transport-Security "max-age=63072000; includeSubdomains";
add_header X-Frame-Options DENY;
add_header X-Content-Type-Options nosniff;

ssl_dhparam /etc/ssl/certs/dhparam.pem;
 ```
 If I understood correctly, the lines containing  *ssl-stapling** are left active in the source guide, but they are deactivated when the changes are enabled. Thus, we can just comment the lines away in this phase.  
 
**Adjust the Nginx Configuration to Use SSL**  
In this part, I will use the default server block, even though we created some additional ones earlier.  
At this point, it might be a good idea to create a back-up copy of the *default* file:  
`sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak`

Now, lets open the server block file to make some changes into the configuration:  
`sudoedit /etc/nginx/sites-available/default`
```
server {
  listen 80;
  listen [::]:80;
  server_name 172.28.171.138;
  return 302 https://$server_name$request_uri;

  error_log   /var/log/nginx/kibana.error.log;
  access_log  /var/log/nginx/kibana.access.log;

}

server {

    listen 443 ssl http2 default_server;
    listen [::]:443 ssl http2 default_server;
    include snippets/self-signed.conf;
    include snippets/ssl-params.conf;

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

**Enable changes in Nginx**

`sudo nginx -t`
If configuration is a OK, restart the service:  
`sudo service nginx restart`

Test encryption by visiting your IP --> `https://your_IP`








Sources:  
https://www.digitalocean.com/community/tutorials/how-to-set-up-let-s-encrypt-with-nginx-server-blocks-on-ubuntu-16-04 (This tutorial requires a dns server)    
https://www.digitalocean.com/community/tutorials/how-to-set-up-nginx-server-blocks-virtual-hosts-on-ubuntu-16-04 (server blocks)  
https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-in-ubuntu-16-04 (Self-signing certs)  

