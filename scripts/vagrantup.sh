# fast vagrant script

sudo apt-get install -y vagrant virtualbox
mkdir ~/vagrant && cd ~/vagrant
vagrant init bento/ubuntu-16.04
vagrant up
vagrant ssh

