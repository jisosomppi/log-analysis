#!/bin/bash
#Simple logging server

echo "Updating packages..."
sudo apt-get update -qq >> /dev/null
echo "Installing git and salt..."
sudo apt-get install git salt-master salt-minion -y -qq >> /dev/null
echo "Cloning repository..."
git clone https://github.com/jisosomppi/log-analysis
echo "Running automated setup.."
echo "(This will take a while)"
sudo cp log-analysis/salt/saltmaster /etc/salt/minion
sudo systemctl restart salt-minion
sudo salt-call --local --file-root log-analysis/salt/srvsalt --pillar-root log-analysis/salt/srvpillar --id srv01 state.highstate --state-output terse -l quiet
echo -e "\nfile_ignore_glob: []\n" | sudo tee -a /etc/salt/master
sudo service salt-master restart 





echo "Server setup is now complete!"
echo ""
echo "Access the Kibana logging frontend at http://localhost"
echo "Client logs will be found in /var/log/client_logs"
echo ""
echo "Run 'sudo salt srv01 state.apply fixperms' when new"
echo "host directories or log files are created"
