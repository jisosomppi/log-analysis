# TLS encryption

https://www.rsyslog.com/tls-secured-syslog-via-relp/

I got TLS-encryption working last week, but I wanted to confirm the config, as I had installed and reconfigured the files for several hours before a working setup

So first things first the packages we need for this, installed for both server and client:

`sudo apt -y install librelp0 rsyslog-relp`

## Client configuration

```
sudoedit /etc/rsyslog.config

# Insert the lines under the modules header


module(load="imudp")
module(load="omrelp")

input(type="imudp" port="514")

action(type="omrelp" target="{enterServerIp}" port="2514" tls="on")

module(load="imuxsock") # provides support for local system logging
```

## Server configuration

```
sudoedit /etc/rsyslog.config

# Insert the lines under the modules header

sudoedit /etc/rsyslog.conf

module(load="imrelp" ruleset="relp")

input(type="imrelp" port="2514" tls="on")

ruleset(name="relp") {
action(type="omfile" file="/var/log/relptls")
}
```

Restart rsyslog daemons on both server and client(s)

## Testing connection

With this "default" TLS setup the host logs will all go under /var/log/relptls

Tested connection with `logger -s "testitesti"

Also confirmed with Wireshark that the package indeed was encrypted.
