# Docker installation

*! This guide appears to have some problems when running on live-usb. We're looking into a solution.*

## Install using the repository

1. Update apt package index:  
```
sudo apt-get update
```

2. Install packages  
```
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
```

3. Add Docker's official GPG key:  
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```
Verify that you have the key with the fingerprint using command:
```
sudo apt-key fingerprint 0EBFCD88
``` 
What you're supposed to see:
```
pub   4096R/0EBFCD88 2017-02-22
      Key fingerprint = 9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88
uid                  Docker Release (CE deb) <docker@docker.com>
sub   4096R/F273FCD8 2017-02-22
``` 

4. Use the following command to set up the stable repository:
```
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
```

## Install Docker CE

1. Update the apt package index:
```
sudo apt-get update
```

2. Install the *latest version* of Docker CE:
```
sudo apt-get install -y docker-ce
```
The docker daemon should start automatically.

3. Verify that Docker CE is installed correctly by running the ```hello-world``` image.
```
sudo docker run hello-world
```
This command downloads a test image and runs it in a container, after not being able to find it locally.

**Source**  
https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-docker-ce-1


# Portainer.io installation

Use the following docker commands to deploy portainer:
```
docker volume create portainer_data
```
and
```
$ docker run -d -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer
```

You can test your Portainer by accessing your browser
```
localhost:9000
```
You should now be able to create your account and access Portainer locally.

**Source**  
https://portainer.io/install.html






