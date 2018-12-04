#!/bin/bash
#"Simple" logging server setup
#Copyright 2018 Isosomppi, Kupias, Kähäri https://github.com/jisosomppi/log-analysis BSD-3

# Check if script has been run before
if [ -f /tmp/setup_runonce ]; then
    echo "This install script has already been run! It is intended to be run only once."
    exit 0
fi
touch /tmp/setup_runonce

# Complete basic setup
cd ~
echo "Setting Finnish keyboard layout..."
setxkbmap fi
echo "Updating packages..."
apt-get update -qq >> /dev/null
echo "Installing git and salt..."
apt-get install firefox openssl git salt-master salt-minion libnss3-tools -y -qq >> /dev/null
echo "Cloning repository..."
git clone https://github.com/jisosomppi/log-analysis/

# Create directories
if [ ! -d "/srv/" ]; then
mkdir /srv/
fi 

# Collect user details
echo
echo "Collecting user information for Elasticsearch & Kibana..."
echo "Enter username for Logging server:"
read es_user
echo "Enter password for Logging server:"
#stty -echo
read es_pass
#stty echo

# Write details into pillar
echo -e "\nelasticsearch_username: $es_user\nelasticsearch_password: $es_pass\n" >> log-analysis/salt/srvpillar/server.sls

# Place Salt files
mkdir /srv/salt /srv/pillar
cp -R log-analysis/salt/srvsalt/* /srv/salt
cp -R log-analysis/salt/srvpillar/* /srv/pillar
cp log-analysis/salt/saltmaster /etc/salt/minion
sudo mv log-analysis/downloads/readonlyrest-1.16.28_es6.4.2.zip /tmp/

# Get rid of annoying warning & restart services
echo -e "\nfile_ignore_glob: []\n" >> /etc/salt/master
systemctl restart salt-minion
systemctl restart salt-master

## OpenSSL key creation
echo "Enter a strong password for your root CA:"
#stty -echo
read ssl_pass
#stty echo

# Create OpenSSL keys for Nginx
echo "Generating OpenSSL keys for Nginx..."
# Calculate Diffie-Hellman parameters for stronger encryption
openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048 2> /dev/null
# Create root CA key
openssl genrsa -des3 -out localCA.key -passout pass:$ssl_pass 2048 
# Create root CA certificate
openssl req -x509 -new -nodes -key localCA.key -sha256 -days 1825 -out localCA.pem -passin pass:$ssl_pass -subj "/C=FI/ST=Uusimaa/L=Helsinki/O=Haaga-Helia/OU=Logserver/CN=logserver.local"
# Create a new key for the log server
openssl genrsa -out logserver.local.key 2048
# Make a certificate signature request (CSR)
openssl req -new -key logserver.local.key -out logserver.local.csr -subj "/C=FI/ST=Uusimaa/L=Helsinki/O=Haaga-Helia/OU=Logserver/CN=logserver.local"

# Create ext file for additional certificate information (alternative names)
echo -e "authorityKeyIdentifier=keyid,issuer\n\
basicConstraints=CA:FALSE\n\
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment\n\
subjectAltName = @alt_names\n\n\
[alt_names]\n\
DNS.1 = logserver.local\n\
DNS.2 = http://logserver.local\n\
DNS.3 = https://logserver.local" >> logserver.local.ext

# Sign the CSR
openssl x509 -req -in logserver.local.csr -CA localCA.pem -CAkey localCA.key -CAcreateserial -out logserver.local.crt -days 1825 -sha256 -extfile logserver.local.ext -passin pass:$ssl_pass

## Copy certificates to /etc/ssl
cp localCA.pem /etc/ssl
cp logserver.local.crt /etc/ssl
cp logserver.local.key /etc/ssl
cp logserver.local.crt /etc/ssl/certs/
cp logserver.local.key /etc/ssl/private/

## Create client certificate, just like above
openssl genrsa -out logclient.local.key 2048
openssl req -new -key logclient.local.key -out logclient.local.csr -subj "/C=FI/ST=Uusimaa/L=Helsinki/O=Haaga-Helia/OU=Logserver/CN=logclient.local"
openssl x509 -req -in logclient.local.csr -CA localCA.pem -CAkey localCA.key -CAcreateserial -out logclient.local.crt -days 1825 -sha256 -passin pass:$ssl_pass

## Copy client keys for salt distribution
cp localCA.pem /srv/salt/rsyslog-client/
cp logclient.local.crt /srv/salt/rsyslog-client/
cp logclient.local.key /srv/salt/rsyslog-client/

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

# Run salt state for master (forcing id because local salt key is not signed yet)
echo "Applying salt state for server install... (This will take a while)"
salt-call --local --id srv01 state.highstate --state-output terse -l quiet

# Print instructions
echo "Server setup is now complete!"
echo "Direct your clients to this servers IP address:"
hostname -I
echo
echo
echo "Collected client logs will be found in /var/log/client_logs"
echo "Run 'sudo salt srv01 state.apply fixperms' when new host directories or log files are created"
echo
echo "Opening the logging frontend at https://logserver.local (This address also works on connected Salt minions)"
# $SUDO_USER calls name of user who ran the script, escaping the "Can't run Firefox as root" error
sudo -u $SUDO_USER firefox https://logserver.local
