
# Encrypting Rsyslog traffic in a networkserveri@rserveri:/var$ sudoedit /etc/rsyslog.d/50-default.conf 
sudoedit: /etc/rsyslog.d/50-default.conf unchanged
rserveri@rserveri:/var$ cd /home/rserveri/
rserveri@rserveri:~$ ls
Desktop  Documents  Downloads  log-analysis  Music  Pictures  Public  Templates  Videos
rserveri@rserveri:~$ sudo cp log-analysis/etc/rsyslog.d/
20-ufw.conf           50-default.conf       50-default.conf.save  elasticsearch.conf    tmpl.conf             
rserveri@rserveri:~$ sudo cp log-analysis/etc/rsyslog.d/tmpl.conf /etc/rsyslog.d/
[sudo] password for rserveri: 
'rserveri@rserveri:~$ ls /etc/rsyslog.d/
20-ufw.conf  50-default.conf  tmpl.conf
rserveri@rserveri:~$ sudo service rsyslog restart 
rserveri@rserveri:~$ sudo service rsyslog status 
● rsyslog.service - System Logging Service
   Loaded: loaded (/lib/systemd/system/rsyslog.service; enabled; vendor preset: enabled)
   Active: active (running) since Fri 2018-10-05 11:27:35 EEST; 4s ago
     Docs: man:rsyslogd(8)
           http://www.rsyslog.com/doc/
 Main PID: 10525 (rsyslogd)
    Tasks: 9 (limit: 4915)
   CGroup: /system.slice/rsyslog.service
           └─10525 /usr/sbin/rsyslogd -n

loka 05 11:27:35 rserveri systemd[1]: Starting System Logging Service...
loka 05 11:27:35 rserveri rsyslogd[10525]: warning: ~ action is deprecated, consider using the 'stop' statement instead [v8.32.0 try http://www.rsyslog.com/e/2307 ]
loka 05 11:27:35 rserveri rsyslogd[10525]: imuxsoc

Process explained in https://www.rsyslog.com/doc/v8-stable/tutorials/tls.html

## For testing purposes set up Rsyslog server and clien

### Client config
https://www.rsyslog.com/sending-messages-to-a-remote-syslog-server/
https://www.tecmint.com/setup-rsyslog-client-to-send-logs-to-rsyslog-server-in-centos-7/

### Server config
https://www.rsyslog.com/receiving-messages-from-a-remote-system/
https://www.tecmint.com/create-centralized-log-server-with-rsyslog-in-centos-7/

### Separating log files
https://www.rsyslog.com/storing-messages-from-a-remote-system-into-a-specific-file/

## First tests done with unsecure certs found in

https://github.com/rsyslog/rsyslog/tree/master/contrib/gnutls

## Secure certs generated with certtool

`sudo apt install gnutls-bin`

## Reference
https://www.rsyslog.com/doc/v8-stable/tutorials/tls.html
https://www.rsyslog.com/doc/v8-stable/tutorials/tls_cert_summary.html

### Rsyslog server config

As instructed in https://www.tecmint.com/create-centralized-log-server-with-rsyslog-in-centos-7/:

Uncommented lines

```
module(load="imtcp")
input(type="imtcp" port="10514")
```

Added template for separating logs from different hosts (must be placed before "GLOBAL DIRECTIVES"

```
serveri@rserveri:/var$ sudoedit /etc/rsyslog.d/50-default.conf 
sudoedit: /etc/rsyslog.d/50-default.conf unchanged
rserveri@rserveri:/var$ cd /home/rserveri/
rserveri@rserveri:~$ ls
Desktop  Documents  Downloads  log-analysis  Music  Pictures  Public  Templates  Videos
rserveri@rserveri:~$ sudo cp log-analysis/etc/rsyslog.d/
20-ufw.conf           50-default.conf       50-default.conf.save  elasticsearch.conf    tmpl.conf             
rserveri@rserveri:~$ sudo cp log-analysis/etc/rsyslog.d/tmpl.conf /etc/rsyslog.d/
[sudo] password for rserveri: 
'rserveri@rserveri:~$ ls /etc/rsyslog.d/
20-ufw.conf  50-default.conf  tmpl.conf
rserveri@rserveri:~$ sudo service rsyslog restart 
rserveri@rserveri:~$ sudo service rsyslog status 
● rsyslog.service - System Logging Service
   Loaded: loaded (/lib/systemd/system/rsyslog.service; enabled; vendor preset: enabled)
   Active: active (running) since Fri 2018-10-05 11:27:35 EEST; 4s ago
     Docs: man:rsyslogd(8)
           http://www.rsyslog.com/doc/
 Main PID: 10525 (rsyslogd)
    Tasks: 9 (limit: 4915)
   CGroup: /system.slice/rsyslog.service
           └─10525 /usr/sbin/rsyslogd -n

loka 05 11:27:35 rserveri systemd[1]: Starting System Logging Service...
loka 05 11:27:35 rserveri rsyslogd[10525]: warning: ~ action is deprecated, consider using the 'stop' statement instead [v8.32.0 try http://www.rsyslog.com/e/2307 ]
loka 05 11:27:35 rserveri rsyslogd[10525]: imuxsoc$template RemoteLogs,"/var/log/%HOSTNAME%/%PROGRAMNAME%.log"
. ?RemoteLogs & ~
```

Restarted rsyslog with `sudo service rsyslog restart`


### Rsyslog client config

On client added in `/etc/rsyslog.conf`



```
*. * @@172.28.171.54.10514
```

After that I restarted rsyslog service `sudo service rsyslog restart`

I tested with `logger -s "tesitesti"`, but it didn't create a new host file to server `/var/log/`

This config didn't work. On https://www.rsyslog.com/sending-messages-to-a-remote-syslog-server/ it's stated that "# it is equivalent to the following obsolete legacy format line:
*.* @@192.0.2.1:10514 # do NOT use this any longer!"

So I replaced the forward statement with 

```
*.*  action(type="omfwd" target="172.28.171.54" port="10514" protocol="tcp"
            action.resumeRetryCount="100"
            queue.type="linkedList" queue.size="10000")
```

Restarted service `sudo service rsyslog restart` and tested with `logger -s "tesitesti"`

Still doesen't work. On client I mowed the forward statement to `/etc/rsyslog.d/50-default.con`
Didn't change a thing.

On server I noticed error with `sudo service rsyslog status`

```
   Loaded: loaded (/lib/systemd/system/rsyslog.service; enabled; vendor preset: enabled)
   Active: active (running) since Fri 2018-10-05 10:25:58 EEST; 35min ago
     Docs: man:rsyslogd(8)
           http://www.rsyslog.com/doc/
 Main PID: 10103 (rsyslogd)
    Tasks: 9 (limit: 4915)
   CGroup: /system.slice/rsyslog.service
           └─10103 /usr/sbin/rsyslogd -n

loka 05 10:25:58 rserveri systemd[1]: Starting System Logging Service...
loka 05 10:25:58 rserveri systemd[1]: Started System Logging Service.
loka 05 10:25:58 rserveri rsyslogd[10103]: invalid character in selector line - ';template' expected [v8.32.0]
loka 05 10:25:58 rserveri rsyslogd[10103]: error during parsing file /etc/rsyslog.conf, on or before line 28: errors occured in file '
loka 05 10:25:58 rserveri rsyslogd[10103]: imuxsock: Acquired UNIX socket '/run/systemd/journal/syslog' (fd 3) from systemd.  [v8.32.0
loka 05 10:25:58 rserveri rsyslogd[10103]: rsyslogd's groupid changed to 106
loka 05 10:25:58 rserveri rsyslogd[10103]: rsyslogd's userid changed to 102
loka 05 10:25:58 rserveri rsyslogd[10103]:  [origin software="rsyslogd" swVersion="8.32.0" x-pid="10103" x-info="http://www.rsyslog.co
~
```

Error was on remote log separation statement. I changed the statement to match similar found in rsyslog documantation:

```
if $fromhost-ip startswith '172.28.172.211' then /var/log/172.28.172.211.log

& ~
```

Restarted and now error free.

New test to remote logging. It worked but is quite a ugly solution. All logs regardles of the application is on the same text file. At this point I found out that we allready had a working and better statement for separation in github..
So I copied that to `/etc/rsyslog.d/tmpl.conf` and removed the statement from `rsyslog.conf`.

Restarted and tested and it worked.

Lesson here: TecMint is shit and should never be used and blocked on your network.


### Testing certs

I followed instructions found in rsyslog documentation https://www.rsyslog.com/doc/v8-stable/tutorials/tls.html.

Cloned rgerhards rsyslog repository `git clone https://github.com/rsyslog/rsyslog.git` and copied the file containing cert keys for testing with `cp -r rsyslog/contrib/gnutls .`
Both server and client needs these keys so did these steps for both.

On server made a 80-tlscerts.conf file to rsyslog.d with input

```
# make gtls driver the default
$DefaultNetstreamDriver gtls

# certificate files
$DefaultNetstreamDriverCAFile /home/rserveri/contrib/gnutls/ca.pem
$DefaultNetstreamDriverCertFile /home/rserveri/contrib/gnutls/cert.pem
$DefaultNetstreamDriverKeyFile /home/rserveri/contrib/gnutls/key.pem

$ModLoad imtcp # load TCP listener

$InputTCPServerStreamDriverMode 1 # run driver in TLS-only mode
$InputTCPServerStreamDriverAuthMode anon # client is NOT authenticated
$InputTCPServerRun 10514 # start up listener at port 10514
```

And on client similarly 
```
# certificate files - just CA for a client
$DefaultNetstreamDriverCAFile /home/rorja/contrib/gnutls/ca.pem

# set up the action
$DefaultNetstreamDriver gtls # use gtls netstream driver
$ActionSendStreamDriverMode 1 # require TLS for the connection
$ActionSendStreamDriverAuthMode anon # server is NOT authenticated
*.* @@(o)172.28.171.54:10514 # send (all) messages
```

At this point I should propably remove the forward statement from any other .conf file, but let's test firsts.

Restarted rsyslog on both server and client.

Getting errors on both server and client:

Server:
```
● rsyslog.service - System Logging Service
   Loaded: loaded (/lib/systemd/system/rsyslog.service; enabled; vendor preset: enabled)
   Active: active (running) since Fri 2018-10-05 12:21:50 EEST; 1min 50s ago
     Docs: man:rsyslogd(8)
           http://www.rsyslog.com/doc/
 Main PID: 11859 (rsyslogd)
    Tasks: 4 (limit: 4915)
   CGroup: /system.slice/rsyslog.service
           └─11859 /usr/sbin/rsyslogd -n

loka 05 12:21:50 rserveri rsyslogd[11859]: command 'InputTCPServerStreamDriverMode' is currently not permitted - did you already set it via a RainerScript command (v6+ config)? [v8.32.0 try http://www.rsyslog.com/e/2222 ]
loka 05 12:21:50 rserveri systemd[1]: Started System Logging Service.
loka 05 12:21:50 rserveri rsyslogd[11859]: command 'InputTCPServerStreamDriverAuthMode' is currently not permitted - did you already set it via a RainerScript command (v6+ config)? [v8.32.0 try http://www.rsyslog.com/e/2222 ]
loka 05 12:21:50 rserveri rsyslogd[11859]: imuxsock: Acquired UNIX socket '/run/systemd/journal/syslog' (fd 3) from systemd.  [v8.32.0]
loka 05 12:21:50 rserveri rsyslogd[11859]: could not load module '/usr/lib/x86_64-linux-gnu/rsyslog/lmnsd_gtls.so', dlopen: /usr/lib/x86_64-linux-gnu/rsyslog/lmnsd_gtls.so: cannot open shared object file: No such file or directory  [v8.32.0 try http://www.rsyslog.com/e/2
loka 05 12:21:50 rserveri rsyslogd[11859]: tcpsrv could not create listener (inputname: 'imtcp') [v8.32.0 try http://www.rsyslog.com/e/2066 ]
loka 05 12:21:50 rserveri rsyslogd[11859]: activation of module imtcp failed [v8.32.0 try http://www.rsyslog.com/e/2066 ]
loka 05 12:21:50 rserveri rsyslogd[11859]: rsyslogd's groupid changed to 106
loka 05 12:21:50 rserveri rsyslogd[11859]: rsyslogd's userid changed to 102
loka 05 12:21:50 rserveri rsyslogd[11859]:  [origin software="rsyslogd" swVersion="8.32.0" x-pid="11859" x-info="http://www.rsyslog.com"] start
```

and client:
```
rorja@rorja:~$ sudo service rsyslog status
[sudo] password for rorja: 
● rsyslog.service - System Logging Service
   Loaded: loaded (/lib/systemd/system/rsyslog.service; enabled; vendor preset: enabled)
   Active: active (running) since Fri 2018-10-05 12:22:08 EEST; 5min ago
     Docs: man:rsyslogd(8)
           http://www.rsyslog.com/doc/
 Main PID: 10455 (rsyslogd)
    Tasks: 5 (limit: 4915)
   CGroup: /system.slice/rsyslog.service
           └─10455 /usr/sbin/rsyslogd -n

loka 05 12:22:08 rorja systemd[1]: Started System Logging Service.
loka 05 12:22:08 rorja rsyslogd[10455]: rsyslogd's userid changed to 102
loka 05 12:22:08 rorja rsyslogd[10455]:  [origin software="rsyslogd" swVersion="8.32.0" x-pid="10455" x-info="http://www.rsyslog.com"] start
loka 05 12:22:08 rorja rsyslogd[10455]: could not load module '/usr/lib/x86_64-linux-gnu/rsyslog/lmnsd_gtls.so', dlopen: /usr/lib/x86_64-linux-gnu/rsyslog/lmnsd_gtls.so: cannot open shared object file: No such file or directory  [v8.32.0 try http://www.rsyslog.com/e/2066
loka 05 12:22:08 rorja rsyslogd[10455]: action 'action 8' suspended (module 'builtin:omfwd'), retry 0. There should be messages before this one giving the reason for suspension. [v8.32.0 try http://www.rsyslog.com/e/2007 ]
loka 05 12:22:08 rorja rsyslogd[10455]: could not load module '/usr/lib/x86_64-linux-gnu/rsyslog/lmnsd_gtls.so', dlopen: /usr/lib/x86_64-linux-gnu/rsyslog/lmnsd_gtls.so: cannot open shared object file: No such file or directory  [v8.32.0 try http://www.rsyslog.com/e/2066
loka 05 12:22:08 rorja rsyslogd[10455]: action 'action 8' suspended (module 'builtin:omfwd'), next retry is Fri Oct  5 12:22:38 2018, retry nbr 0. There should be messages before this one giving the reason for suspension. [v8.32.0 try http://www.rsyslog.com/e/2007 ]
loka 05 12:22:08 rorja rsyslogd[10455]: could not load module '/usr/lib/x86_64-linux-gnu/rsyslog/lmnsd_gtls.so', dlopen: /usr/lib/x86_64-linux-gnu/rsyslog/lmnsd_gtls.so: cannot open shared object file: No such file or directory  [v8.32.0 try http://www.rsyslog.com/e/2066
loka 05 12:22:08 rorja rsyslogd[10455]: action 'action 1' suspended (module 'builtin:omfwd'), retry 0. There should be messages before this one giving the reason for suspension. [v8.32.0 try http://www.rsyslog.com/e/2007 ]
loka 05 12:22:08 rorja rsyslogd[10455]: could not load module '/usr/lib/x86_64-linux-gnu/rsyslog/lmnsd_gtls.so', dlopen: /usr/lib/x86_64-linux-gnu/rsyslog/lmnsd_gtls.so: cannot open shared object file: No such file or directory  [v8.32.0 try http://www.rsyslog.com/e/2066
```
On server side replaced 

```
# make gtls driver the default
$DefaultNetstreamDriver gtls

$ModLoad imtcp # load TCP listener

$InputTCPServerStreamDriverMode 1 # run driver in TLS-only mode
$InputTCPServerStreamDriverAuthMode anon # client is NOT authenticated
$InputTCPServerRun 10514 # start up listener at port 10514
```

with 

```
# provides TCP syslog reception
module(load="imtcp")
input(
        type="imtcp" 
        port="10514"
        StreamDriver="gtls"
        StreamDriver.Mode="1"
        StreamDriver.AuthMode="anon"

)
```

in `/etc/rsyslog.conf`, leaving only certs in 80-tlscerts.conf.

That didn't work either:

```
● rsyslog.service - System Logging Service
   Loaded: loaded (/lib/systemd/system/rsyslog.service; enabled; vendor preset: enabled)
   Active: active (running) since Fri 2018-10-05 13:42:05 EEST; 16min ago
     Docs: man:rsyslogd(8)
           http://www.rsyslog.com/doc/
 Main PID: 13882 (rsyslogd)
    Tasks: 9 (limit: 4915)
   CGroup: /system.slice/rsyslog.service
           └─13882 /usr/sbin/rsyslogd -n

loka 05 13:42:05 rserveri systemd[1]: Starting System Logging Service...
loka 05 13:42:05 rserveri rsyslogd[13882]: error during parsing file /etc/rsyslog.conf, on or before line 29: parameter 'StreamDriver.AuthMode' not known -- typo in config file? [v8.32.0 try http://www.rsyslog.com/e/2207 ]
loka 05 13:42:05 rserveri rsyslogd[13882]: error during parsing file /etc/rsyslog.conf, on or before line 29: parameter 'StreamDriver.Mode' not known -- typo in config file? [v8.32.0 try http://www.rsyslog.com/e/2207 ]
loka 05 13:42:05 rserveri systemd[1]: Started System Logging Service.
loka 05 13:42:05 rserveri rsyslogd[13882]: error during parsing file /etc/rsyslog.conf, on or before line 29: parameter 'StreamDriver' not known -- typo in config file? [v8.32.0 try http://www.rsyslog.com/e/2207 ]
loka 05 13:42:05 rserveri rsyslogd[13882]: imuxsock: Acquired UNIX socket '/run/systemd/journal/syslog' (fd 3) from systemd.  [v8.32.0]
loka 05 13:42:05 rserveri rsyslogd[13882]: rsyslogd's groupid changed to 106
loka 05 13:42:05 rserveri rsyslogd[13882]: rsyslogd's userid changed to 102
loka 05 13:42:05 rserveri rsyslogd[13882]:  [origin software="rsyslogd" swVersion="8.32.0" x-pid="13882" x-info="http://www.rsyslog.com"] start
rserveri@rserveri:~$ 
```

Next I decided to remove all changes including certs and trying instructions found on https://www.rsyslog.com/using-tls-with-relp/

Tested with logger to be sure that I was at the working starting point.

Installed gnutls-bin (includes certtool) and librelp0 `sudo apt install gnutls-bin librelp0`




