# Setting up an x509 Certificate Authority

Reference: 
* https://gist.github.com/fm-jason/c2bf2b986cb47a234f81cfce8e0892de
* https://docs.saltstack.com/en/latest/ref/states/all/salt.states.x509.html
* https://www.rsyslog.com/doc/v8-stable/tutorials/tls.html
* http://virtuallyhyper.com/2013/04/setup-your-own-certificate-authority-ca-on-linux-and-use-it-in-a-windows-environment/
* https://deliciousbrains.com/ssl-certificate-authority-for-local-https-development/
* Also referencing [Eino's research notes](https://github.com/jisosomppi/log-analysis/blob/master/documentation/tls/working-conf-with-certs.md) for the actual setup
* Adding root CA to Firefox
  * ~~https://mike.kaply.com/2012/03/30/customizing-firefox-default-profiles/~~ *deprecated in Firefox 46.0*
  * https://wiki.mozilla.org/CA:AddRootToFirefox
  * https://developer.mozilla.org/en-US/docs/Mozilla/Projects/NSS/Tools/certutil
  * https://gist.github.com/stevenroose/e6abde14258971eae982

## The need
We're trying to set up Rsyslog authentication between clients using x509 certificates. We're also hoping to access the Kibana frontend without security prompts.

Since we're already using Salt, we could maybe use it to generate and distribute the keys securely. 

## Benefits
* Creating the certificates automatically
* Distributing the keys via the Salt pillar, securely
* Getting rid of certificate warnings while browsing Kibana 

## Working setup process
Following the instructions at https://deliciousbrains.com/ssl-certificate-authority-for-local-https-development/, create keys and certificates:
```
# Create the Certificate Authority key, enter a passphrase
openssl genrsa -des3 -out localCA.key 2048 
```

```
# Create root certificate, use recognizable Common Name
openssl req -x509 -new -nodes -key localCA.key -sha256 -days 1825 -out localCA.pem -subj "/C=FI/ST=Uusimaa/L=Helsinki/O=Haaga-Helia/OU=Logserver/CN=logserver.local"
```

```
# Create key for web server
openssl genrsa -out logserver.local.key 2048
```

```
# Create Certificate Singature Request (CSR), input doesn't matter
openssl req -new -key logserver.local.key -out logserver.local.csr -subj "/C=FI/ST=Uusimaa/L=Helsinki/O=Haaga-Helia/OU=Logserver/CN=logserver.local"
```
```
# Create logserver.local.ext with following contents:
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = logserver.local
DNS.3 = https://logserver.local
DNS.6 = http://logserver.local
```

```
# Create certificate & key for web server
openssl x509 -req -in logserver.local.csr -CA localCA.pem -CAkey localCA.key -CAcreateserial \
-out logserver.local.crt -days 1825 -sha256 -extfile logserver.local.ext
```

After this, move the generated key `logserver.local.key` and certificate `logserver.local.crt` into `/etc/ssl/` in the right folders, direct `/etc/nginx/snippets` cert conf to them and install `localCA.pem` into Firefox.

~~Something strange happens with DNS redirection, but at least `https://logserver.local` works like it should, i.e. shows the green lock icon and goes to the page without warnings.~~

Changing the server name in the `sites-available/default` file into `logserver.local` seems to fix the DNS redirection issues, since now all connections are directed to the correct domain name (even localhost!). After this the `.ext` file can probably be reduced to just logserver.local and its http:// and https:// variants. 

**Success! Next up: automating this setup with Salt and using the certificates for Rsyslog.**

## Automating Firefox certificate addition
Looks like the best way to add certs (from the command line) is to use certutil. Certutil is an official Mozilla tool, and is contained in the `libnss3-tools` apt-package. The program has a pretty nice manual file, which should help in adding the certificate.

```
# Convert certificate into PKCS12 for Firefox import
# CURRENTLY BROKEN
# openssl pkcs12 -export -out logserver.local.pfx -inkey logserver.local.key -in logserver.local.crt -certfile localCA.crt

## Import root CA to Firefox
# Need to find the random-generated alphanumeric 
# Insert new root CA key to existing profiles cert database, maybe like this: 
# certutil -A -n "keynickname" -t "u,u,u" -i localCA.pem -d ~/.mozilla/firefox/**code**.default/
# Copy cert database into /etc/firefox/default, something like:
# cp ~/.mozilla/firefox/**code**.default/cert3.db /etc/firefox/default/
# Delete existing Firefox user to force create new with the modified database?
# Or find the profile name -> replace existing db
```
