# 

https://www.rsyslog.com/doc/v8-stable/tutorials/tls.html

Packets required: 
rsyslog-gnutls - TLS protocol support for rsyslog

For testing purposes I will use example certs found in https://github.com/rsyslog/rsyslog/tree/master/contrib/gnutls.
Later when creating custom certs I'll need gnutls-bin (includes certtool)

## Server setup

`sudo apt -y install rsyslog-gnutls wget`

I downloaded required certs for rsyslog from rsyslog github with wget

```
wget https://raw.githubusercontent.com/rsyslog/rsyslog/master/contrib/gnutls/key.pem 
&& wget https://raw.githubusercontent.com/rsyslog/rsyslog/master/contrib/gnutls/cert.pem 
&& wget https://raw.githubusercontent.com/rsyslog/rsyslog/master/contrib/gnutls/ca.pem
```

Added to /etc/rsyslog.conf
```
# make gtls driver the default
$DefaultNetstreamDriver gtls

# certificate files
$DefaultNetstreamDriverCAFile /etc/ssl/certs/ca.pem
$DefaultNetstreamDriverCertFile /etc/ssl/certs/cert.pem
$DefaultNetstreamDriverKeyFile /etc/ssl/certs/key.pem

$ModLoad imtcp # load TCP listener

$InputTCPServerStreamDriverMode 1 # run driver in TLS-only mode
$InputTCPServerStreamDriverAuthMode anon # client is NOT authenticated
$InputTCPServerRun 10514 # start up listener at port 10514
```

Restarted rsyslog service

To my surprise no errors so far

## Client setup

`sudo apt -y install rsyslog-gnutls wget`

For client just ca.pem needed

`wget https://raw.githubusercontent.com/rsyslog/rsyslog/master/contrib/gnutls/ca.pem`

Added to /etc/rsyslog.conf
```
# certificate files - just CA for a client
$DefaultNetstreamDriverCAFile /etc/ssl/certs/ca.pem

# set up the action
$DefaultNetstreamDriver gtls # use gtls netstream driver
$ActionSendStreamDriverMode 1 # require TLS for the connection
$ActionSendStreamDriverAuthMode anon # server is NOT authenticated
*.* @@172.28.171.54:10514 # send (all) messages
```
Restarted rsyslog service

For now client rsyslog remains errorless

Tested connection with `logger -s "testitesti"` and confirmed in wireshark that the packets indeed were encrypted.

![ENCRYPTED](https://raw.githubusercontent.com/jisosomppi/log-analysis/master/images/ENCRYPTED.png.jpg)
