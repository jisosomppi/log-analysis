## Server configuration ##  

Backup rsyslog file configuration  
`sudo cp /etc/rsyslog.conf /etc/rsyslog.conf.orig`  

Open the rsyslog file configuration  
`sudoedit /etc/rsyslog.conf`    

Uncomment lines to make server listen on the udp and tcp ports  
```
# provides UDP syslog reception  
#module(load="imudp")  
#input(type="imudp" port="514")  
```  

and  
```
# provides TCP syslog reception  
#module(load="imtcp")  
#input(type="imtcp" port="514")  
```

Restart rsyslog service  
`sudo systemctl restart rsyslog` 

Allow Rsyslog default port 514 on firewall and restart UFW. 
```
sudo ufw allow 514/tcp  
sudo ufw allow 514/tcp  
sudo ufw reload  
```

## Client configuration ##  

Backup rsyslog.conf file  
`sudo cp /etc/rsyslog /etc/rsyslog.conf.orig`  

Open said file  
`sudoedit /etc/rsyslog.conf`  

Add the line:  `*.* @@SERVER:514` Where "SERVER" is the IP address of server.  

Save & close. Create a new file  
`sudoedit /etc/rsyslog.d/10-rsyslog.conf`  

add the line `*.* @@ADDRESS:514` where "ADDRESS" is the Ip address of server.  

Restart rsyslog  
`sudo systemctl restart rsyslog`

Test connection to server by generating some log data:  
`sudo logger -s " This is my Rsyslog client "`

Go to /var/log/Client_logs on **Rsyslog Server**. There should be a new folder named with the hostname of your Rsyslog client.  








