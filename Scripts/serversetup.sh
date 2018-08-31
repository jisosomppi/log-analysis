# Setup computer

setxkbmap fi
sudo timedatectl set-timezone Europe/Helsinki
sudo apt-get update
sudo apt-get install -y git tree htop curl
cd

# Setup Git and clone this repository

git clone https://github.com/jisosomppi/log-analysis

git config --global user.name "Jussi Isosomppi"
git config --global user.email "jussi.isosomppi@gmail.com"
git config --global credential.helper "cache --timeout=3600"
git config --global push.default simple

# Make Git commit script usable

sudo cp log-analysis/gitup /usr/local/bin/
sudo chmod 755 /usr/local/bin/gitup
