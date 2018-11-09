#!/bin/bash
#Simple logging server

echo "Updating packages..."
sudo apt-get update -qq >> /dev/null
echo "Installing git and salt-minion..."
sudo apt-get install git salt-minion -y -qq >> /dev/null
echo "Cloning repository..."
git clone https://github.com/jisosomppi/log-analysis
echo "Running automated setup.."
echo "(This will take a while)"
sudo cp log-analysis/salt/saltmaster /etc/salt/master
sudo systemctl restart salt-minion
sudo salt-call --local --file-root log-analysis/salt/srvsalt --pillar-root log-analysis/salt/srvpillar --id srv01 state.highstate --state-output terse
echo "Setup is now complete! Access the Kibana logging frontend at http://localhost"
