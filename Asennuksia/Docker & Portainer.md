# Docker asennus

*Install using the repository*

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





