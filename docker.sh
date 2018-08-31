## One-click docker install https://docs.docker.com/install/linux/docker-ce/ubuntu/
## Jussi Isosomppi, 2018

## Remove previous versions of docker
sudo apt-get remove docker docker-engine docker.io

## Enable https repositories
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

## Add Dockers official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

## Add docker ropository
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

## Install Docker
sudo apt-get update
sudo apt-get install -y docker-ce

## Run test container
sudo docker run hello-world
