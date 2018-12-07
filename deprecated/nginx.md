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

I have a feeling there is no need to even configure anything in the current versions.. I'll test this with a fresh install on live-usb. It turned out that my sources were outdated, and nginx supports IPv6 by default these days.

Used the following command for testing:  
`netstat -tulpna | grep nginx`

**Additional links I used on the matter**  
https://www.cyberciti.biz/faq/nginx-ipv6-configuration/  
https://www.linode.com/docs/web-servers/nginx/nginx-installation-and-basic-setup/  
https://docs.nginx.com/nginx/admin-guide/installing-nginx/installing-nginx-open-source/#sources_download  
https://linuxconfig.org/how-to-install-gcc-the-c-compiler-on-ubuntu-18-04-bionic-beaver-linux  


# Creating Nginx server blocks ~~and self-signing ssl certificate~~ #  

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
