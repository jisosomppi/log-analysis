# Logging and analysis of security data in a network  
*[Jussi Isosomppi](https://github.com/jisosomppi), [Eino Kupias](https://github.com/einokupias), [Saku Kähäri](https://github.com/nauskis)*  
***ICT Infrastructure Project, fall 2018***  
***Haaga-Helia University of Applied Sciences***  
***Course details: [terokarvinen.com](http://terokarvinen.com/2018/aikataulu--monialaprojekti-infra-pro4tn004-3001--syksy-2018--10-op)***

![Dashboard](https://github.com/jisosomppi/log-analysis/blob/master/images/dashboard.png)

## Project description
Our aim with this project is to create a centralized logging solution, created with ease of use and data security in mind. Our solution relies on Saltstack for centralized management, and on encryption and SSL certificates for data security. We wrote scripts to make the setup process easy and consistent, so that each installation would lead to the same end result.

## Table of Contents
* [Installation/setup instructions](#installationsetup-instructions)
  * [Server install](#server-install)
  * [Client install](#client-install)
  * [Testing](#testing)
* [Further reading](#further-reading)

## Installation/setup instructions
For our testing, we used Xubuntu 16.04 as our base operating system. The setup works with a live USB as well as on an installed OS. For the client, we verified VM functionality with Vagrant/Virtualbox and the `bento/ubuntu-16.04` box.

### Server install
```
wget https://raw.githubusercontent.com/jisosomppi/log-analysis/master/salt/serversetup.sh
chmod +x serversetup.sh
sudo ./serversetup.sh

```
Once the server setup script has completed its task, it will open a new firefox window (or tab) showing the Kibana dashboard at https://logserver.local. To make the page display without errors, add the `~/localCA.pem` file to the authorized certificates (On Firefox: Preferences -> Privacy and Security -> View Certificates -> Import...). 

### Client install
If you want to use Vagrant as your test client, run this script to set it up:
```
wget https://raw.githubusercontent.com/jisosomppi/log-analysis/master/salt/vagrantup.sh
chmod +x vagrantup.sh
sudo ./vagrantup.sh

```

Run the following on your client:
```
wget https://raw.githubusercontent.com/jisosomppi/log-analysis/master/salt/clientsetup.sh
chmod +x clientsetup.sh
sudo ./clientsetup.sh

```
Enter your master's IP address (displayed at the end of the master setup script) and choose a name for your minion. 

### Testing
After both the minion and master are set up properly, run the following command on your master:  
`sudo salt-key -A -y && sleep 5 && sudo salt '*' state.highstate --state-output terse`  
This makes sure that all of the salt minions (including the server) are in the correct state. 

To generate log data for Kibana to display, run the command `logtest` on the minion. You can leave the script running and access Kibana with the username and password you chose during the server setup. The log file permissions are updated every minute on the server, but if you want to view your results quicker you can just run the Salt state `fixperms` again (`sudo salt 'srv*' state.apply fixperms`).

You can add our premade dashboard by going to `Management -> Saved Objects -> Import` in Kibana. The dashboard can be found at `/tmp/default_dashboard.json`.

## Further reading
Check out our [additional documentation](https://github.com/jisosomppi/log-analysis/blob/master/documentation/additional.md) for more information on module contents, customization, research documentation and more!
