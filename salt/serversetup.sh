#!/bin/bash
#Simple logging server

cd ~
echo "Updating packages..."
sudo apt-get update -qq >> /dev/null
echo "Installing git and salt..."
sudo apt-get install git salt-master salt-minion -y -qq >> /dev/null
echo "Cloning repository..."
git clone https://github.com/jisosomppi/log-analysis
echo "Running automated setup... (This will take a while)"
sudo mkdir /srv/salt /srv/pillar
sudo cp -R log-analysis/salt/srvsalt/* /srv/salt
sudo cp -R log-analysis/salt/srvpillar/* /srv/pillar
sudo cp log-analysis/salt/saltmaster /etc/salt/minion
echo -e "\nfile_ignore_glob: []\n" | sudo tee -a /etc/salt/master
sudo systemctl restart salt-minion
sudo systemctl restart salt-master
sudo salt-call --local --id srv01 state.highstate --state-output terse -l quiet

echo "Server setup is now complete!"
echo ""
echo "You can access the Kibana logging frontend at http://localhost"
echo "Collected client logs will be found in /var/log/client_logs"
echo "Direct your clients to this servers IP address:"
hostname -I
echo ""
echo "Run 'sudo salt srv01 state.apply fixperms' when new"
echo "host directories or log files are created"
firefox http://logserver.local
