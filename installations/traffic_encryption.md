# Encrypting Rsyslog traffic in a network

Process explained in https://www.rsyslog.com/doc/v8-stable/tutorials/tls.html

## For testing purposes set up Rsyslog server and clien

### Client config
https://www.rsyslog.com/sending-messages-to-a-remote-syslog-server/

### Server config
https://www.rsyslog.com/receiving-messages-from-a-remote-system/

### Separating log files
https://www.rsyslog.com/storing-messages-from-a-remote-system-into-a-specific-file/

## First tests done with unsecure certs found in

https://github.com/rsyslog/rsyslog/tree/master/contrib/gnutls

## Secure certs generated with certtool

`sudo apt install gnutls-bin`

## Reference
https://www.rsyslog.com/doc/v8-stable/tutorials/tls.html
https://www.rsyslog.com/doc/v8-stable/tutorials/tls_cert_summary.html
