#!/bin/bash
#Simple salt-minion

echo "Updating packages..."
sudo apt-get update -qq >> /dev/null
echo "Installing salt-minion..."
sudo apt-get install salt-minion -y -qq >> /dev/null
echo "Please enter master IP address here:"
read MasterIP
echo "Please enter a unique id for your system:"
read SystemID
echo "Writing information to /etc/salt/minion..."
echo -e "master: $MasterIP\nid: ws-$SystemID" | sudo tee /etc/salt/minion
echo "Restarting salt-minion..."
sudo systemctl restart salt-minion
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt
sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
