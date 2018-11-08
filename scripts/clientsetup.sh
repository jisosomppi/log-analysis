#!/bin/bash
#Simple client setup
sudo apt-get update -qq >> /dev/null
sudo apt-get install salt-minion -qq >> /dev/null
echo "Please enter master IP address here:"
read MasterIP
echo "Please enter a unique id for your system:"
read SystemID
echo "Writing information to /etc/salt/minion..."
echo -e "master: $MasterIP\nid: $SystemID" | sudo tee /etc/salt/minion
echo "Restarting salt-minion..."
sudo systemctl restart salt-minion
