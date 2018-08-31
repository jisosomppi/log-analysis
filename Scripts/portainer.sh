## One click installer for Portainer (Docker web GUI)
## Jussi Isosomppi, 2018

## Create and start container
sudo docker volume create portainer_data
sudo docker run -d -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer

## Check container functionality
curl -I localhost:9000
