## Server configuration ##  

Backup rsyslog file configuration  
```sudo cp /etc/rsyslog.conf /etc/rsyslog.conf.orig```  

Open the rsyslog file configuration  
```sudoedit /etc/rsyslog.conf```    

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
```sudo systemctl restart rsyslog``` 


## Client configuration ##
