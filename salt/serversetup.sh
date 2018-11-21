#!/bin/bash
#Simple logging server

# Complete basic setup
cd ~
echo "Setting Finnish keyboard layout..."
setxkbmap fi
echo "Updating packages..."
apt-get update -qq >> /dev/null
echo "Installing git and salt..."
apt-get install firefox openssl git salt-master salt-minion libnss3-tools -y -qq >> /dev/null
echo "Cloning repository..."
## Cloning single branch: ca-test
git clone -b ca-test https://github.com/jisosomppi/log-analysis/

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
stty -echo
read es_pass
stty echo

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
# Could maybe use expect to enter password to interactive scripts:
# https://stackoverflow.com/questions/15379031/
# So read password from user input, save to variable, enter with expect
#
# Or try this way: https://stackoverflow.com/questions/4294689/
# -passout & -passin
echo "Enter a strong password for your root CA:"
stty -echo
read ssl_pass
stty echo

# Create OpenSSL keys for Nginx
echo "Generating OpenSSL keys for Nginx..."
# Calculate Diffie-Hellman parameters for stronger encryption
openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048 2> /dev/null
# Create root CA key
# echo "Enter a strong password for root CA key:"
openssl genrsa -des3 -out localCA.key -passout pass:$ssl_pass 2048 
# echo "Enter the same password to verify root certificate creation:"
openssl req -x509 -new -nodes -key localCA.key -sha256 -days 1825 -out localCA.pem -passin pass:$ssl_pass -subj "/C=FI/ST=Uusimaa/L=Helsinki/O=Haaga-Helia/OU=Logserver/CN=logserver.local"
# Create a new key for the log server
openssl genrsa -out logserver.local.key 2048
# Make a certificate signature request (CSR)
openssl req -new -key logserver.local.key -out logserver.local.csr -subj "/C=FI/ST=Uusimaa/L=Helsinki/O=Haaga-Helia/OU=Logserver/CN=logserver.local"

# Create ext file for additional certificate fields
echo -e "authorityKeyIdentifier=keyid,issuer\n\
basicConstraints=CA:FALSE\n\
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment\n\
subjectAltName = @alt_names\n\n\
[alt_names]\n\
DNS.1 = logserver.local\n\
DNS.2 = http://logserver.local\n\
DNS.3 = https://logserver.local" >> logserver.local.ext

# Sign the CSR
# echo "Enter the root CA password one last time to verify the server certificate:"
openssl x509 -req -in logserver.local.csr -CA localCA.pem -CAkey localCA.key -CAcreateserial -out logserver.local.crt -days 1825 -sha256 -extfile logserver.local.ext -passin pass:$ssl_pass

# Convert certificate into PKCS12 for Firefox import
# CURRENTLY BROKEN
# openssl pkcs12 -export -out logserver.local.pfx -inkey logserver.local.key -in logserver.local.crt -certfile localCA.crt

## Copy certificates to /etc/ssl
cp logserver.local.crt /etc/ssl/certs/
cp logserver.local.key /etc/ssl/private/

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
firefox https://logserver.local
