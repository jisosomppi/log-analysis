## One click installer for ELK Stack containers (https://github.com/deviantony/docker-elk)
## Jussi Isosomppi, 2018

## Install docker-compose, needed to build the containers
sudo apt-get install -y docker-compose

## Clone git repository
cd
git clone https://github.com/deviantony/docker-elk

## Start the stack (-d to detach the containers and free up the terminal)
cd docker-elk
sudo docker-compose up -d

## Test functionality
curl -I localhost:5601
