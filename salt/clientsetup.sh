#!/bin/bash
#Simple salt-minion
#Copyright 2018 Isosomppi, Kupias, Kähäri https://github.com/jisosomppi/log-analysis BSD-3

echo "Updating packages..."
apt-get update -qq >> /dev/null
echo "Installing salt-minion..."
apt-get install salt-minion -y -qq >> /dev/null
echo "Please enter master IP address here:"
read MasterIP
echo "Please enter a unique id for your system:"
read SystemID
echo "Writing salt settings to file and restarting salt-minion..."
echo -e "master: $MasterIP\nid: ws-$SystemID" | sudo tee /etc/salt/minion
systemctl restart salt-minion
