
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

rserveri@rserveri:~$ certtool --generate-request --load-privkey key.pem --outfile request.pem
Generating a PKCS #10 certificate request...
Common name: rserveri
Organizational unit name: Lokittajat
Organization name: Lokittajat
Locality name: Servula
State or province name: 
Country name (2 chars): FI
Enter the subject's domain component (DC): 
UID: 
Enter a dnsName of the subject of the certificate: 
Enter a URI of the subject of the certificate: 
Enter the IP address of the subject of the certificate: 
Enter the e-mail of the subject of the certificate: 
Enter a challenge password: 
Does the certificate belong to an authority? (y/N): n
Will the certificate be used for signing (DHE ciphersuites)? (Y/n): 
Will the certificate be used for encryption (RSA ciphersuites)? (Y/n): 
Will the certificate be used to sign code? (y/N): 
Will the certificate be used for time stamping? (y/N): 
Will the certificate be used for email protection? (y/N): 
Will the certificate be used for IPsec IKE operations? (y/N): 
Will the certificate be used to sign OCSP requests? (y/N): 
Is this a TLS web client certificate? (y/N): y
Is this a TLS web server certificate? (y/N): y
rserveri@rserveri:~$ certtool --generate-certificate --load-request request.pem --outfile cert.pem --load-ca-certificate ca.pem --load-ca-privkey ca-key.pem
Generating a signed certificate...
Enter the certificate's serial number in decimal (default: 6608852413158096997): 


Activation/Expiration time.
The certificate will expire in (days): 365

Expiration time: Sat Oct  5 15:42:51 2019
CA expiration time: Sat Oct  5 15:28:37 2019
Warning: The time set exceeds the CA's expiration time
Is it ok to proceed? (y/N): y


Extensions.
Do you want to honour all the extensions from the request? (y/N): 
Does the certificate belong to an authority? (y/N): n
Is this a TLS web client certificate? (y/N): y
Will the certificate be used for IPsec IKE operations? (y/N): 
Is this a TLS web server certificate? (y/N): y
Enter a dnsName of the subject of the certificate: 
Enter a URI of the subject of the certificate: 
Enter the IP address of the subject of the certificate: 
Will the certificate be used for signing (DHE ciphersuites)? (Y/n): 
Will the certificate be used for encryption (RSA ciphersuites)? (Y/n): 
Will the certificate be used to sign OCSP requests? (y/N): 
Will the certificate be used to sign code? (y/N): 
Will the certificate be used for time stamping? (y/N): 
Will the certificate be used for email protection? (y/N): 
X.509 Certificate Information:
	Version: 3
	Serial Number (hex): 5bb75c412b458065
	Validity:
		Not Before: Fri Oct 05 12:42:48 UTC 2018
		Not After: Sat Oct 05 12:42:51 UTC 2019
	Subject: C=FI,L=Servula,O=Lokittajat,OU=Lokittajat,CN=rserveri
	Subject Public Key Algorithm: RSA
	Algorithm Security Level: Medium (2048 bits)
		Modulus (bits 2048):
			00:ae:ce:ca:b7:ee:05:c0:ae:4b:1f:0f:bc:7b:d7:29
			3a:4e:3a:df:6d:c8:ce:53:50:0a:9c:f4:c4:20:de:b4
			91:93:36:fe:81:3a:7d:2a:33:1e:68:75:a4:93:40:88
			1f:a2:ef:95:ee:17:83:8b:ec:fc:1d:d7:08:34:43:6a
			7d:36:00:04:cb:1e:04:22:45:5c:1a:59:9d:f3:89:42
			cb:b2:db:f3:11:65:f1:e6:a8:24:f0:99:a1:28:46:65
			d5:85:e9:94:0d:82:9f:13:4b:27:50:44:b1:fe:61:a2
			37:4c:67:f9:ba:8c:6e:ff:b5:69:eb:c0:8d:2e:7a:f7
			a2:d3:0c:48:d1:2f:2e:63:c3:2a:ef:70:e6:4e:e7:72
			b5:00:5e:31:b4:23:70:a5:8a:63:79:59:d7:9f:d3:59
			12:e9:8e:9e:05:8c:cb:1b:90:2e:58:4d:89:ba:91:b5
			42:48:fe:fb:7d:d3:be:eb:73:d9:d1:f8:02:c5:fc:09
			5b:7d:b0:46:50:14:4a:0d:40:42:96:94:ee:a2:86:5f
			f1:7e:f1:36:e9:8f:7a:d9:86:31:34:76:6a:16:60:e8
			ea:9a:89:ba:2f:20:c2:39:c0:7c:89:b7:e9:3a:11:b9
			ac:9b:de:c9:42:31:e6:d2:90:8e:8c:c1:45:c2:a3:47
			d1
		Exponent (bits 24):
			01:00:01
	Extensions:
		Basic Constraints (critical):
			Certificate Authority (CA): FALSE
		Key Purpose (not critical):
			TLS WWW Client.
			TLS WWW Server.
		Key Usage (critical):
			Digital signature.
			Key encipherment.
		Subject Key Identifier (not critical):
			b219ad3e3e53e34c541be3b03408b817da25962d
		Authority Key Identifier (not critical):
			39b1044a9b2205c66c013c9b9ca461d38b9a33dd
Other Information:
	Public Key ID:
		sha1:b219ad3e3e53e34c541be3b03408b817da25962d
		sha256:61ba793950b9148a70a590d6cdb9766ad40880a2497f4920e55d6da14244a660
	Public Key PIN:
		pin-sha256:Ybp5OVC5FIpwpZDWzbl2atQIgKJJf0kg5V1toUJEpmA=
	Public key's random art:
		+--[ RSA 2048]----+
		|   ..+ .         |
		|  . E + + +      |
		|   = = . * +     |
		|  o o  .o o      |
		|   .  o.S        |
		|       *+        |
		|      += .       |
		|     .+ o        |
		|     .o+         |
		+-----------------+

Is the above information ok? (y/N): & ~
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

Installed gnutls-bin (includes certtool) and librelp0 for both server and client `sudo apt install gnutls-bin librelp0`

### Setting up CA

```
rserveri@rserveri:~$ certtool --generate-privkey --outfile ca-key.pem --bits 2048
** Note: You may use '--sec-param Medium' instead of '--bits 2048'
Generating a 2048 bit RSA private key...
rserveri@rserveri:~$ certtool --generate-self-signed --load-privkey ca-key.pem --outfile ca.pem
Generating a self signed certificate...
Please enter the details of the certificate's distinguished name. Just press enter to ignore a field.
Common name: Eino
UID: 
Organizational unit name: Lokittajat
Organization name: Lokittajat
Locality name: Servula
State or province name: 
Country name (2 chars): FI
Enter the subject's domain component (DC): 
This field should not be used in new certificates.
E-mail: 
Enter the certificate's serial number in decimal (default: 6608848766436549883): 


Activation/Expiration time.
The certificate will expire in (days): 365


Extensions.
Does the certificate belong to an authority? (y/N): y
Path length constraint (decimal, -1 for no constraint): 
Is this a TLS web client certificate? (y/N): 
Will the certificate be used for IPsec IKE operations? (y/N): 
Is this a TLS web server certificate? (y/N): 
Enter a dnsName of the subject of the certificate: 
Enter a URI of the subject of the certificate: 
Enter the IP address of the subject of the certificate: 
Enter the e-mail of the subject of the certificate: 
Will the certificate be used to sign OCSP requests? (y/N): 
Will the certificate be used to sign code? (y/N): 
Will the certificate be used for time stamping? (y/N): 
Will the certificate be used for email protection? (y/N): 
Will the certificate be used to sign other certificates? (y/N): y
Will the certificate be used to sign CRLs? (y/N): 
Enter the URI of the CRL distribution point: 
X.509 Certificate Information:
	Version: 3
	Serial Number (hex): 5bb758f019baa4fb
	Validity:
		Not Before: Fri Oct 05 12:28:34 UTC 2018
		Not After: Sat Oct 05 12:28:37 UTC 2019
	Subject: C=FI,L=Servula,O=Lokittajat,OU=Lokittajat,CN=Eino
	Subject Public Key Algorithm: RSA
	Algorithm Security Level: Medium (2048 bits)
		Modulus (bits 2048):
			00:e6:56:d4:e7:e7:7c:b6:1b:c2:8c:42:dc:b5:12:10
			4c:61:96:e2:38:61:47:7b:8b:ef:ec:7a:bb:a0:53:4f
			30:34:8a:04:72:7e:c5:d5:40:4c:46:3e:21:07:b4:cd
			48:e6:46:6f:ac:53:d1:38:ae:ff:9b:45:63:06:4f:14
			bf:6b:24:ba:a4:7a:90:ae:d8:b7:9e:95:4f:47:16:f3
			74:49:12:a7:c9:20:27:97:2f:43:c7:dc:a1:9a:16:45
			ce:a8:7c:41:cb:79:27:4a:12:45:18:18:a4:19:0c:88
			0f:e2:ce:68:d6:db:b2:c4:49:e9:4f:45:a1:c3:76:27
			7b:52:cf:0f:d5:21:df:d6:60:79:ff:8c:ca:9c:ab:8d
			5c:e0:88:6f:85:08:1e:9e:f0:61:9c:40:ce:77:b3:75
			e3:2d:93:c4:77:20:f3:39:99:da:e0:96:95:7f:e5:0e
			55:51:89:f2:b9:e3:2f:77:49:65:e7:24:d8:99:cf:18
			22:54:1d:08:20:a1:8d:b2:f1:38:00:cb:5e:54:5b:dc
			f8:59:20:bd:6f:06:4d:bc:10:ad:a1:94:12:91:a4:28
			88:9a:c9:be:35:65:de:5e:1d:fe:c3:3f:1e:d9:28:32
			bf:c0:42:5a:4f:3b:5d:b8:ec:02:b1:4b:74:c6:c8:81
			39
		Exponent (bits 24):
			01:00:01
	Extensions:
		Basic Constraints (critical):
			Certificate Authority (CA): TRUE
		Key Usage (critical):
			Certificate signing.
		Subject Key Identifier (not critical):
			39b1044a9b2205c66c013c9b9ca461d38b9a33dd
Other Information:
	Public Key ID:
		sha1:39b1044a9b2205c66c013c9b9ca461d38b9a33dd
		sha256:476442ac1ebafa3b8121b115f92f2eea5af741d32c8c3742185de00fc946b7eb
	Public Key PIN:
		pin-sha256:R2RCrB66+juBIbEV+S8u6lr3QdMsjDdCGF3gD8lGt+s=
	Public key's random art:
		+--[ RSA 2048]----+
		|B++ . .          |
		|o@ o + .         |
		|B.O =   o        |
		|.B o   . +       |
		|.o .    S        |
		|= . E    .       |
		| o               |
		|                 |
		|                 |
		+-----------------+

Is the above information ok? (y/N): y


Signing certificate...
rserveri@rserveri:~$ sudo chmod 400 ca-key.pem
```

### Generating the machine certificate

```
rserveri@rserveri:~$ certtool --generate-privkey --outfile key.pem --bits 2048
** Note: You may use '--sec-param Medium' instead of '--bits 2048'
Generating a 2048 bit RSA private key...
rserveri@rserveri:~$ certtool --generate-request --load-privkey key.pem --outfile request.pem
Generating a PKCS #10 certificate request...
Common name: rserveri
Organizational unit name: Lokittajat
Organization name: Lokittajat
Locality name: Servula
State or province name: 
Country name (2 chars): FI
Enter the subject's domain component (DC): 
UID: 
Enter a dnsName of the subject of the certificate: 
Enter a URI of the subject of the certificate: 
Enter the IP address of the subject of the certificate: 
Enter the e-mail of the subject of the certificate: 
Enter a challenge password: 
Does the certificate belong to an authority? (y/N): n
Will the certificate be used for signing (DHE ciphersuites)? (Y/n): 
Will the certificate be used for encryption (RSA ciphersuites)? (Y/n): 
Will the certificate be used to sign code? (y/N): 
Will the certificate be used for time stamping? (y/N): 
Will the certificate be used for email protection? (y/N): 
Will the certificate be used for IPsec IKE operations? (y/N): 
Will the certificate be used to sign OCSP requests? (y/N): 
Is this a TLS web client certificate? (y/N): y
Is this a TLS web server certificate? (y/N): y
rserveri@rserveri:~$ certtool --generate-certificate --load-request request.pem --outfile cert.pem --load-ca-certificate ca.pem --load-ca-privkey ca-key.pem
Generating a signed certificate...
Enter the certificate's serial number in decimal (default: 6608852413158096997): 


Activation/Expiration time.
The certificate will expire in (days): 365

Expiration time: Sat Oct  5 15:42:51 2019
CA expiration time: Sat Oct  5 15:28:37 2019
Warning: The time set exceeds the CA's expiration time
Is it ok to proceed? (y/N): y


Extensions.
Do you want to honour all the extensions from the request? (y/N): 
Does the certificate belong to an authority? (y/N): n
Is this a TLS web client certificate? (y/N): y
Will the certificate be used for IPsec IKE operations? (y/N): 
Is this a TLS web server certificate? (y/N): y
Enter a dnsName of the subject of the certificate: 
Enter a URI of the subject of the certificate: 
Enter the IP address of the subject of the certificate: 
Will the certificate be used for signing (DHE ciphersuites)? (Y/n): 
Will the certificate be used for encryption (RSA ciphersuites)? (Y/n): 
Will the certificate be used to sign OCSP requests? (y/N): 
Will the certificate be used to sign code? (y/N): 
Will the certificate be used for time stamping? (y/N): 
Will the certificate be used for email protection? (y/N): 
X.509 Certificate Information:
	Version: 3
	Serial Number (hex): 5bb75c412b458065
	Validity:
		Not Before: Fri Oct 05 12:42:48 UTC 2018
		Not After: Sat Oct 05 12:42:51 UTC 2019
	Subject: C=FI,L=Servula,O=Lokittajat,OU=Lokittajat,CN=rserveri
	Subject Public Key Algorithm: RSA
	Algorithm Security Level: Medium (2048 bits)
		Modulus (bits 2048):
			00:ae:ce:ca:b7:ee:05:c0:ae:4b:1f:0f:bc:7b:d7:29
			3a:4e:3a:df:6d:c8:ce:53:50:0a:9c:f4:c4:20:de:b4
			91:93:36:fe:81:3a:7d:2a:33:1e:68:75:a4:93:40:88
			1f:a2:ef:95:ee:17:83:8b:ec:fc:1d:d7:08:34:43:6a
			7d:36:00:04:cb:1e:04:22:45:5c:1a:59:9d:f3:89:42
			cb:b2:db:f3:11:65:f1:e6:a8:24:f0:99:a1:28:46:65
			d5:85:e9:94:0d:82:9f:13:4b:27:50:44:b1:fe:61:a2
			37:4c:67:f9:ba:8c:6e:ff:b5:69:eb:c0:8d:2e:7a:f7
			a2:d3:0c:48:d1:2f:2e:63:c3:2a:ef:70:e6:4e:e7:72
			b5:00:5e:31:b4:23:70:a5:8a:63:79:59:d7:9f:d3:59
			12:e9:8e:9e:05:8c:cb:1b:90:2e:58:4d:89:ba:91:b5
			42:48:fe:fb:7d:d3:be:eb:73:d9:d1:f8:02:c5:fc:09
			5b:7d:b0:46:50:14:4a:0d:40:42:96:94:ee:a2:86:5f
			f1:7e:f1:36:e9:8f:7a:d9:86:31:34:76:6a:16:60:e8
			ea:9a:89:ba:2f:20:c2:39:c0:7c:89:b7:e9:3a:11:b9
			ac:9b:de:c9:42:31:e6:d2:90:8e:8c:c1:45:c2:a3:47
			d1
		Exponent (bits 24):
			01:00:01
	Extensions:
		Basic Constraints (critical):
			Certificate Authority (CA): FALSE
		Key Purpose (not critical):
			TLS WWW Client.
			TLS WWW Server.
		Key Usage (critical):
			Digital signature.
			Key encipherment.
		Subject Key Identifier (not critical):
			b219ad3e3e53e34c541be3b03408b817da25962d
		Authority Key Identifier (not critical):
			39b1044a9b2205c66c013c9b9ca461d38b9a33dd
Other Information:
	Public Key ID:
		sha1:b219ad3e3e53e34c541be3b03408b817da25962d
		sha256:61ba793950b9148a70a590d6cdb9766ad40880a2497f4920e55d6da14244a660
	Public Key PIN:
		pin-sha256:Ybp5OVC5FIpwpZDWzbl2atQIgKJJf0kg5V1toUJEpmA=
	Public key's random art:
		+--[ RSA 2048]----+
		|   ..+ .         |
		|  . E + + +      |
		|   = = . * +     |
		|  o o  .o o      |
		|   .  o.S        |
		|       *+        |
		|      += .       |
		|     .+ o        |
		|     .o+         |
		+-----------------+

Is the above information ok? (y/N):y
rserveri@rserveri:~$ rm -f request.pem
```
I transferred ca.pem, cert.pem and key.pem to client.

### Client configuration
```
sudoedit /etc/rsyslog.conf

### RELP tls
module(load="imuxsock") # provides support for local system logging
module(load="imuxsock")
module(load="omrelp")
module(load="imtcp")
input(type="imtcp" port="10514")
action(type="omrelp" target="172.28.171.54" port="20514" tls="on" tls.caCert="/home/rorja/keys/ca.pem"
tls.myCert="/home/rorja/keys/cert.pem" tls.myPrivKey="/home/rorja/keys/key.pem"
tls.authmode="name" tls.permittedpeer=["ubuntu-server"] )
```
restarted rsyslog

### Server config
```
sudoedit /etc/rsyslog.conf

# RELP tls   
module(load="imuxsock")
module(load="imrelp" ruleset="relp")
input(type="imrelp" port="20514"
tls="on"
tls.caCert="/home/rserveri/keys/ca.pem"
tls.myCert="/home/rserveri/keys/cert.pem"
tls.myPrivKey="/home/rserveri/keys/key.pem"
tls.authMode="name"
tls.permittedpeer=["rorja","ubuntu-client2","ubuntu-client3"] )
ruleset (name="relp") { action(type="omfile" file="/var/log/relp_log") }
```
restarted rsyslog

On server got the following error:

```
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
loka 05 12:22:08 rorja rsyslogd[10455]:  [origin software="rsyslogd" swVersion="8.32.0" x-pid="10455" x-info="http://www.rsyslog.com"]
loka 05 12:22:08 rorja rsyslogd[10455]: could not load module '/usr/lib/x86_64-linux-gnu/rsyslog/lmnsd_gtls.so', dlopen: /usr/lib/x86_
loka 05 12:22:08 rorja rsyslogd[10455]: action 'action 8' suspended (module 'builtin:omfwd'), retry 0. There should be messages before
loka 05 12:22:08 rorja rsyslogd[10455]: could not load module '/usr/lib/x86_64-linux-gnu/rsyslog/lmnsd_gtls.so', dlopen: /usr/lib/x86_
loka 05 12:22:08 rorja rsyslogd[10455]: action 'action 8' suspended (module 'builtin:omfwd'), next retry is Fri Oct  5 12:22:38 2018, 
loka 05 12:22:08 rorja rsyslogd[10455]: could not load module '/usr/lib/x86_64-linux-gnu/rsyslog/lmnsd_gtls.so', dlopen: /usr/lib/x86_
loka 05 12:22:08 rorja rsyslogd[10455]: action 'action 1' suspended (module 'builtin:omfwd'), retry 0. There should be messages before
loka 05 12:22:08 rorja rsyslogd[10455]: could not load module '/usr/lib/x86_64-linux-gnu/rsyslog/lmnsd_gtls.so', dlopen: /usr/lib/x86_
```

I noticed that I didn't have the rsyslog-relp package, so installed it `sudo apt install rsyslog-relp`

After also removing one dublicated line from the rsyslog.conf I was able narrow errors to these

```
loka 05 16:20:40 rserveri rsyslogd[18009]: imrelp[20514]: error 'Failed to set certificate key files [gnutls error -34: Base64 decoding error.]', object  'lstn 20514' - input may not work as intended [v8.32.0 try http://www.rsyslog.com/e/2353 ]
loka 05 16:20:40 rserveri rsyslogd[18009]: imrelp: could not activate relp listener, code 10031 [v8.32.0 try http://www.rsyslog.com/e/2291 ]
```

I felt that I wasn't going anywhere with this so decided to purge rsyslog and start again with
https://www.rsyslog.com/newbie-guide-to-rsyslog/
and https://www.rsyslog.com/tls-secured-syslog-via-relp/

### TLS secured syslog via RELP

https://www.rsyslog.com/tls-secured-syslog-via-relp/

Installed rsyslog and librelp `sudo apt -y intall rsyslog librelp0`

#### Client config

```
sudoedit /etc/rsyslog.conf

module(load="imudp")
module(load="omrelp")

input(type="imudp" port="514")

action(type="omrelp" target="172.28.171.54" port="2514" tls="on")
```

restarted rsyslog

#### Server config

```
sudoedit /etc/rsyslog.conf

module(load="imrelp" ruleset="relp")

input(type="imrelp" port="2514" tls="on")

ruleset(name="relp") {
action(type="omfile" file="/var/log/relptls")
}
```

restarted

had errors

```
loka 05 16:55:52 rserveri rsyslogd[19987]: could not load module '/usr/lib/x86_64-linux-gnu/rsyslog/imrelp.so', dlopen: /usr/lib/x86_64-linux-gnu/rsyslog/imrelp.so: cannot open shared object file: No such file or directory  [v8.32.0 try http://www.rsyslog.com/e/2066 ]
loka 05 16:55:52 rserveri rsyslogd[19987]: error during parsing file /etc/rsyslog.conf, on or before line 14: parameter 'ruleset' not known -- typo in config file? [v8.32.0 try http://www.rsyslog.com/e/2207 ]
loka 05 16:55:52 rserveri systemd[1]: Started System Logging Service.
loka 05 16:55:52 rserveri rsyslogd[19987]: input module name 'imrelp' is unknown [v8.32.0 try http://www.rsyslog.com/e/2209 ]
loka 05 16:55:52 rserveri rsyslogd[19987]: error during parsing file /etc/rsyslog.conf, on or before line 16: parameter 'tls' not known -- typo in config file? [v8.32.0 try http://www.rsyslog.com/e/2207 ]
loka 05 16:55:52 rserveri rsyslogd[19987]: error during parsing file /etc/rsyslog.conf, on or before line 16: parameter 'port' not known -- typo in config file? [v8.32.0 try http://www.rsyslog.com/e/2207 ]
```

Found out that there is a rsyslog-relp package in packet manager so I installed it `sudo apt install rsyslog-relp` and magically all my errors vanished.

With this setup I was also able test client-server fuctionality.

Tested encryption with Wireshark
