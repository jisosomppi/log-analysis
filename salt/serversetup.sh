#!/bin/bash
#Simple logging server

# Complete basic setup
echo "Setting Finnish keyboard layout..."
setxkbmap fi
cd ~
echo "Updating packages..."
apt-get update -qq >> /dev/null
echo "Installing git and salt..."
apt-get install git salt-master salt-minion -y -qq >> /dev/null
echo "Cloning repository..."
git clone https://github.com/jisosomppi/log-analysis
echo "Running automated setup... (This will take a while)"

# Create directories
if [ ! -d "/srv/" ]; then
mkdir /srv/
fi 
mkdir /srv/salt /srv/pillar

# Place Salt files
cp -R log-analysis/salt/srvsalt/* /srv/salt
cp -R log-analysis/salt/srvpillar/* /srv/pillar
cp log-analysis/salt/saltmaster /etc/salt/minion

# Get rid of annoying warning & restart services
echo -e "\nfile_ignore_glob: []\n" >> /etc/salt/master
systemctl restart salt-minion
systemctl restart salt-master

# Run salt state for master (forcing id because local salt key is not signed yet)
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
echo "Opening the logging frontend at http://logserver.local (This address also works on connected Salt minions)"
firefox http://logserver.local
