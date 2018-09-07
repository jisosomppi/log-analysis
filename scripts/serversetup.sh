## One-click installer script to setup logging server
## Jussi Isosomppi, 2018

# Setup computer
setxkbmap fi
sudo timedatectl set-timezone Europe/Helsinki
sudo apt-get update
sudo apt-get install -y git tree htop curl salt-master salt-minion docker-compose apt-transport-https ca-certificates software-properties-common
cd

# Setup Git and clone this repository
git config --global user.name "Jussi Isosomppi"
git config --global user.email "jussi.isosomppi@gmail.com"
git config --global credential.helper "cache --timeout=3600"
git config --global push.default simple

git clone https://github.com/jisosomppi/log-analysis

# Make Git commit script usable
sudo cp log-analysis/scripts/gitup /usr/local/bin/
sudo chmod 755 /usr/local/bin/gitup

## Add Dockers official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

## Add docker repository
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

## Install Docker
sudo apt-get update
sudo apt-get install -y docker-ce

## Create and start Portainer GUI
sudo docker volume create portainer_data
sudo docker run -d -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer

## Clone git repository for ELK Stack containers
cd
git clone https://github.com/deviantony/docker-elk

## Start the stack (-d to detach the containers and free up the terminal)
cd docker-elk
sudo docker-compose up -d

## Salt setup
echo "file_ignore_glob: []" | sudo tee -a /etc/salt/master
echo "master: localhost" | sudo tee -a /etc/salt/minion
sudo service salt-master restart
sudo service salt-minion restart
