#!/bin/bash
#Simple logging server

# Complete basic setup
cd ~
echo "Setting Finnish keyboard layout..."
setxkbmap fi
echo "Updating packages..."
apt-get update -qq >> /dev/null
echo "Installing git and salt..."
apt-get install git salt-master salt-minion -y -qq >> /dev/null
echo "Cloning repository..."
git clone https://github.com/jisosomppi/log-analysis/

# Create directories
if [ ! -d "/srv/" ]; then
mkdir /srv/
fi 

# Collect user details
echo
echo
echo "Enter username for Logging server:"
read es_user
echo "Enter password for Logging server:"
read es_pass
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

# Create OpenSSL keys for Nginx
echo "Generating OpenSSL keys for Nginx..."
openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048 2> /dev/null
openssl genrsa -des3 -out localCA.key 2048 
openssl req -x509 -new -nodes -key localCA.key -sha256 -days 1825 -out localCA.pem -subj "/C=FI/ST=Uusimaa/L=Helsinki/O=Haaga-Helia/OU=Logserver/CN=logserver.local"
openssl genrsa -out logserver.local.key 2048
openssl req -new -key logserver.local.key -out logserver.local.csr -subj "/C=FI/ST=Uusimaa/L=Helsinki/O=Haaga-Helia/OU=Logserver/CN=logserver.local"
echo -e "authorityKeyIdentifier=keyid,issuer\n\
basicConstraints=CA:FALSE\nkeyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment\n\
subjectAltName = @alt_names\n\n\
[alt_names]\nDNS.1 = logserver.local\nDNS.3 = https://logserver.local\nDNS.6 = http://logserver.local" >> test.ext

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
