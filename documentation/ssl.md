## Creating self signed certificates for Nginx ##

**Next, I'd suggest anyone reading this, to consult this [guide](https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-in-ubuntu-16-04) for better understanding about self-signing certs.**

As mentioned, my knowledge about certs is severely lacking, so I will just follow the steps provided by the source I linked.

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
Add the lines:  
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

When signing your own certificate, it is normal, that your browser warns you about the connection not being secure. I'm not sure how you can add the exception when using Chrome, but it's fairly easy on Firefox.


Sources:  
https://www.digitalocean.com/community/tutorials/how-to-set-up-let-s-encrypt-with-nginx-server-blocks-on-ubuntu-16-04 (This tutorial requires a dns server)    
https://www.digitalocean.com/community/tutorials/how-to-set-up-nginx-server-blocks-virtual-hosts-on-ubuntu-16-04 (server blocks)  
https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-in-ubuntu-16-04 (Self-signing certs)  
