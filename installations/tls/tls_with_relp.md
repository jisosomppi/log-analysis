https://www.rsyslog.com/using-tls-with-relp/
https://waqarafridi.wordpress.com/2015/11/16/configure-ssltls-between-two-rsyslog-systems/

`sudo apt -y install librelp0 rsyslog-relp gnutls-bin` on both client and server

```
server@server:~$ certtool --generate-privkey --outfile ca-key.pem
Generating a 3072 bit RSA private key...
server@server:~$ ls
ca-key.pem  Desktop  Documents  Downloads  log-analysis  Music  Pictures  Public  Templates  Videos
server@server:~$ certtool --generate-self-signed --load-privkey ca-key.pem --outfile ca.pem
Generating a self signed certificate...
Please enter the details of the certificate's distinguished name. Just press enter to ignore a field.
Common name: someName
UID: 
Organizational unit name: SomeUI
Organization name: someORg
Locality name: FI
State or province name: FI
Country name (2 chars): FI
Enter the subject's domain component (DC): 
This field should not be used in new certificates.
E-mail: 
Enter the certificate's serial number in decimal (default: 6616583770972002918): 


Activation/Expiration time.
The certificate will expire in (days): 3650


Extensions.
Does the certificate belong to an authority? (y/N): y
Path length constraint (decimal, -1 for no constraint): 
Is this a TLS web client certificate? (y/N): 
Will the certificate be used for IPsec IKE operations? (y/N): 
Is this a TLS web server certificate? (y/N): 
Enter a dnsName of the subject of the certificate: 
Enter a URI of the subject of the certificate: 
Enter the IP address of the subject of the certificate: 
Enter the e-mail of the subject of the certificate: a1602684@myy.haaga-helia.fi
Will the certificate be used to sign OCSP requests? (y/N): 
Will the certificate be used to sign code? (y/N): 
Will the certificate be used for time stamping? (y/N): 
Will the certificate be used for email protection? (y/N): 
Will the certificate be used to sign other certificates? (y/N): y
Will the certificate be used to sign CRLs? (y/N): 
Enter the URI of the CRL distribution point: 
X.509 Certificate Information:
	Version: 3
	Serial Number (hex): 5bd2d3e22f669a66
	Validity:
		Not Before: Fri Oct 26 08:44:21 UTC 2018
		Not After: Mon Oct 23 08:44:25 UTC 2028
	Subject: C=FI,ST=FI,L=FI,O=someORg,OU=SomeUI,CN=someName
	Subject Public Key Algorithm: RSA
	Algorithm Security Level: High (3072 bits)
		Modulus (bits 3072):
			00:b4:dd:f0:ce:bb:a4:0f:ce:ad:9c:af:e7:b4:2e:cd
			cb:3b:10:85:53:74:9a:16:8f:44:c0:e5:e6:dd:0c:33
			e1:35:5a:d0:b7:60:72:df:06:7f:2c:d5:42:3d:e0:fc
			a8:2b:0c:3d:d0:30:d6:e4:b6:0a:80:06:b4:52:27:3f
			a5:9a:04:63:f8:ec:22:9a:af:16:14:9d:e5:bc:17:be
			c9:7c:fc:ac:99:8d:70:a0:9a:6a:9a:3b:6d:fd:7b:ef
			4b:8d:98:80:0d:26:f0:92:bc:4d:bb:9d:ce:99:08:85
			6e:b7:a8:6b:bf:70:b6:78:ec:c5:2e:f7:5c:cb:e5:90
			fa:68:ee:b3:c8:7d:17:d6:cf:ea:97:e0:29:5d:01:03
			ca:0d:9f:c6:70:39:6d:e9:f6:36:5f:a4:7e:c7:e6:33
			e7:2b:07:3b:98:04:b0:fc:a3:3e:3c:fa:eb:bd:1c:8c
			65:96:51:5b:74:1d:99:11:da:ba:55:00:74:22:83:b7
			b2:71:98:34:7a:b2:33:48:a7:80:db:d5:b4:8b:85:ff
			6d:72:c0:36:91:29:9f:5a:ea:ad:b5:f9:37:59:40:4e
			6e:cb:bc:3d:50:2a:e2:b0:da:20:df:d4:fe:3f:38:c2
			3e:3e:d9:d1:ea:d1:fd:4b:fd:d6:6f:b2:0b:ae:d9:54
			f5:42:d8:e1:72:a1:04:f3:54:3a:0a:eb:76:89:25:2f
			36:85:5f:1c:23:b9:4f:e3:67:50:8a:e6:dc:d9:91:33
			
```
```
server@server:~$ certtool --generate-privkey --outfile server-key.pem
Generating a 3072 bit RSA private key...
server@server:~$ certtool --generate-request --load-privkey server-key.pem --outfile server-request.pem
Generating a PKCS #10 certificate request...
Common name: Server
Organizational unit name: someOrg
Organization name: SomeUI
Locality name: FI
State or province name: FI
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
server@server:~$ certtool --generate-certificate --load-request server-request.pem --outfile server-cert.pem --load-ca-certificate ca.pem --load-ca-privkey ca-key.pem
Generating a signed certificate...
Enter the certificate's serial number in decimal (default: 6616585784847907409): 


Activation/Expiration time.
The certificate will expire in (days): 3650

Expiration time: Mon Oct 23 11:52:12 2028
CA expiration time: Mon Oct 23 11:44:25 2028
Warning: The time set exceeds the CA's expiration time
Is it ok to proceed? (y/N): y


Extensions.
Do you want to honour all the extensions from the request? (y/N): y
Does the certificate belong to an authority? (y/N): n
Is this a TLS web client certificate? (y/N): y
Will the certificate be used for IPsec IKE operations? (y/N): n
Is this a TLS web server certificate? (y/N): y
Enter a dnsName of the subject of the certificate: server
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
	Serial Number (hex): 5bd2d5b713c23a51
	Validity:
		Not Before: Fri Oct 26 08:52:09 UTC 2018
		Not After: Mon Oct 23 08:52:12 UTC 2028
	Subject: C=FI,ST=FI,L=FI,O=SomeUI,OU=someOrg,CN=Server
	Subject Public Key Algorithm: RSA
	Algorithm Security Level: High (3072 bits)
		Modulus (bits 3072):
			00:b9:e2:e2:22:1c:2e:5a:64:33:81:87:23:52:ee:4c
			45:65:3c:86:e1:c9:9f:61:9b:92:f9:b4:c6:4f:56:51
			07:3e:31:6f:c6:b1:4d:45:b0:fb:7b:af:56:7e:b5:7d
			af:e6:c9:6c:8e:a1:f1:ff:ac:49:61:6a:6b:de:dd:92
			de:2e:9c:1c:39:5a:a5:c2:73:37:a4:46:70:a3:ee:ca
			bb:03:e7:ea:74:c5:cf:ed:e9:c1:78:43:30:b2:15:ed
			45:30:72:66:78:2d:e2:4d:5f:ee:f6:cc:ef:f8:01:8a
			4e:65:9d:be:e6:02:08:5b:74:ed:74:2f:87:cf:5a:c4
			ff:9d:be:83:cd:ec:aa:63:e2:ae:49:14:d4:38:e2:31
			06:fa:f1:25:bf:39:c8:fa:83:0f:3a:64:a5:c6:f0:90
			37:f4:5d:99:f8:99:63:a3:4d:3e:54:f5:6a:f4:9a:9f
			76:9a:57:33:55:54:b3:d2:cd:06:22:40:6a:2a:a7:59
			51:bd:b3:66:72:22:2a:df:1a:bf:a2:d7:7b:71:38:4b
			e9:e3:91:2f:e1:52:58:17:d1:ac:4d:b8:71:bf:27:85
			e1:da:96:5a:25:27:bf:dd:da:8c:af:17:4d:e0:9c:12
			56:b4:16:44:2a:85:c3:da:16:be:c9:95:47:ee:10:65
			c8:04:ab:f1:f8:79:84:bf:3f:7d:dd:30:7b:ce:44:1a
			1c:1d:3a:81:22:2e:f3:e9:25:91:ac:1b:b8:80:94:dd
			37:11:51:a7:31:f2:04:59:e1:82:39:06:c3:a5:e7:df
			fd:d3:07:05:0a:80:9d:2e:64:53:36:d9:1e:c9:ba:b4
			38:96:fc:2c:8f:a3:6c:26:43:0b:9f:17:59:e4:1b:4c
			77:42:aa:d2:b6:b8:ae:b5:af:a4:df:f8:64:93:25:e6
			42:12:e6:7e:87:d2:82:f5:26:0b:58:f8:10:57:3a:82
			ec:96:c8:f4:e4:d7:05:c2:71:74:b1:9c:52:e0:61:44
			33
		Exponent (bits 24):
			01:00:01
	Extensions:
		Basic Constraints (critical):
			Certificate Authority (CA): FALSE
		Key Usage (critical):
			Digital signature.
			Key encipherment.
		Key Purpose (not critical):
			TLS WWW Client.
			TLS WWW Server.
			TLS WWW Client.
			TLS WWW Server.
		Subject Alternative Name (not critical):
			DNSname: server
		Subject Key Identifier (not critical):
			0ac439e457d16c51b0ce1abfabf49a4cc7dcb4aa
		Authority Key Identifier (not critical):
			ef008a94e1d490a43cb01b8f49bfbb07b848a68a
Other Information:
	Public Key ID:
		sha1:0ac439e457d16c51b0ce1abfabf49a4cc7dcb4aa
		sha256:356532cd26a6e34c7904b36f00313b4c23aa333d9868cc0eac982c91d062ea69
	Public Key PIN:
		pin-sha256:NWUyzSam40x5BLNvADE7TCOqMz2YaMwOrJgskdBi6mk=
	Public key's random art:
		+--[ RSA 3072]----+
		|    .   o+o+.    |
		|   + . .  +.     |
		|    * .  ..      |
		|   . o   o       |
		|    .   S o .    |
		|     . . * o .   |
		|      . + = o    |
		|       + + o     |
		|        E+=.     |
		+-----------------+

Is the above information ok? (y/N): y


Signing certificate...
```
```
server@server:~$ certtool --generate-privkey --outfile client-key.pem
Generating a 3072 bit RSA private key...
server@server:~$ certtool --generate-request --load-privkey client-key.pem --outfile client-request.pem
Generating a PKCS #10 certificate request...
Common name: client
Organizational unit name: SomeUi
Organization name: SomeOrg
Locality name: Fi
State or province name: FI
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
server@server:~$ certtool --generate-certificate --load-request client-request.pem --outfile client-cert.pem --load-ca-certificate ca.pem --load-ca-privkey ca-key.pem 
Generating a signed certificate...
Enter the certificate's serial number in decimal (default: 6616587708876100685): 


Activation/Expiration time.
The certificate will expire in (days): 3649


Extensions.
Do you want to honour all the extensions from the request? (y/N): y
Does the certificate belong to an authority? (y/N): n
Is this a TLS web client certificate? (y/N): y
Will the certificate be used for IPsec IKE operations? (y/N): n
Is this a TLS web server certificate? (y/N): y
Enter a dnsName of the subject of the certificate: client
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
	Serial Number (hex): 5bd2d7770cc6944d
	Validity:
		Not Before: Fri Oct 26 08:59:36 UTC 2018
		Not After: Sun Oct 22 08:59:45 UTC 2028
	Subject: C=FI,ST=FI,L=Fi,O=SomeOrg,OU=SomeUi,CN=client
	Subject Public Key Algorithm: RSA
	Algorithm Security Level: High (3072 bits)
		Modulus (bits 3072):
			00:c9:a6:42:41:60:18:9a:96:e5:32:6f:f9:fa:80:70
			27:19:5e:eb:a3:1a:3f:df:e6:11:0f:22:7c:82:88:f5
			42:30:33:46:c6:cd:f1:84:1d:da:87:4f:b0:16:24:2b
			0d:fc:cf:58:07:1e:0b:1d:15:f5:91:af:2d:5f:48:4c
			18:23:ad:b4:bc:f7:99:d5:ad:9a:d6:7b:6c:ce:c6:9c
			9c:2a:29:25:32:06:a7:53:bf:88:b5:3c:66:52:f5:a8
			c1:83:a0:be:a7:8e:89:4e:5d:97:90:40:4b:6b:d9:a1
			01:e5:e7:3f:16:03:89:2a:4e:92:49:9d:0d:91:82:8c
			f8:42:96:74:73:2f:38:fe:a9:74:9a:48:b9:e5:cd:9d
			b4:0f:cb:ab:d4:4a:0c:1b:da:03:6e:be:c1:05:ba:07
			5a:c4:bc:61:3d:3e:a6:30:ce:41:41:ff:a5:04:d4:00
			dc:d3:e2:36:15:99:ce:ce:81:68:36:83:0a:11:74:2f
			f2:6b:86:99:32:fb:5b:63:20:04:3b:0e:ab:9c:3f:94
			77:4c:9d:66:b5:9b:fa:e7:e2:a6:1e:be:ec:1d:29:e8
			03:5b:d7:10:e5:75:5b:54:14:7d:f3:f2:f6:b0:af:d9
			07:32:7c:63:60:d6:df:ab:14:1a:2b:2a:72:c0:cf:91
			c3:e0:6f:b8:ee:9f:0e:30:eb:3b:dc:8b:b8:03:6b:cc
			eb:0c:c8:95:91:55:ab:3e:a6:cd:c7:0e:c6:b9:8e:d2
			6c:8a:3a:0a:35:ef:c7:14:0b:05:8e:f8:c3:6a:a4:ba
			4b:f1:ad:6b:86:03:9c:62:31:fb:ab:cf:74:d8:86:34
			72:4d:11:f5:08:c7:59:41:1d:79:88:d2:ff:6e:f4:1e
			17:61:70:6d:98:cb:de:e4:f3:b0:cc:8d:df:6a:e8:13
			0c:19:04:0f:ab:10:54:5f:d3:2d:db:85:b2:84:46:91
			19:21:2a:8b:22:08:c9:cd:5c:28:c2:a5:7a:7d:58:1a
			49
		Exponent (bits 24):
			01:00:01
	Extensions:
		Basic Constraints (critical):
			Certificate Authority (CA): FALSE
		Key Usage (critical):
			Digital signature.
			Key encipherment.
		Key Purpose (not critical):
			TLS WWW Client.
			TLS WWW Server.
			TLS WWW Client.
			TLS WWW Server.
		Subject Alternative Name (not critical):
			DNSname: client
		Subject Key Identifier (not critical):
			4c5bde21fce282d8b78d26685842870bdacf9484
		Authority Key Identifier (not critical):
			ef008a94e1d490a43cb01b8f49bfbb07b848a68a
Other Information:
	Public Key ID:
		sha1:4c5bde21fce282d8b78d26685842870bdacf9484
		sha256:5fc6717a6f1cb76d752105c2cb8cbbe59f761c1dbd798381b4070298453abe79
	Public Key PIN:
		pin-sha256:X8Zxem8ct211IQXCy4y75Z92HB29eYOBtAcCmEU6vnk=
	Public key's random art:
		+--[ RSA 3072]----+
		|                 |
		|         .       |
		|   o    . + .    |
		|. E o  o + + .   |
		|.+ + .  S o o    |
		|. + +o . . .     |
		|   B..o o .      |
		|  . = ...=       |
		|   .   oo .      |
		+-----------------+

Is the above information ok? (y/N): y


Signing certificate...
```

Added to `/etc/hosts` clients name and ip, and same for client.
Confirmed with ping to machine names.

## Client config

```
sudoedit /etc/rsyslog.conf

module(load="omrelp")
module(load="imtcp")

input(type="imtcp" port="514″)

action(type="omrelp" target="172.28.171.54″ port="20514″ tls="on"
tls.caCert="/etc/rsyslog.d/certs/ca.pem"
tls.myCert="/etc/rsyslog.d/certs/client-cert.pem"
tls.myPrivKey="/etc/rsyslog.d/certs/client-key.pem"
tls.authmode="name"
tls.permittedpeer=["server"]
)

sudo service rsyslog restart
```

## Server config
```
sudoedit /etc/rsyslog.conf

module(load="imrelp" ruleset="relp")
 
input(type="imrelp" port="10514″ tls="on"
tls.caCert="/etc/rsyslog.d/ca.pem"
tls.myCert="/etc/rsyslog.d/server-cert.pem"
tls.myPrivKey="/etc/rsyslog.d/server-key.pem"
tls.authMode="name"
tls.permittedpeer=["client","machine2.example.com"] #That/those common names of the machines
)
 
ruleset (name="relp") {
action(type="omfile" file="/var/log/client_logs/%HOSTNAME%/%PROGRAMNAME%.log")
}

sudo service rsyslog restart
```
```
server@server:~$ rsyslogd -N1
rsyslogd: version 8.32.0, config validation run (level 1), master config /etc/rsyslog.conf
rsyslogd: error during parsing file /etc/rsyslog.conf, on or before line 17: syntax error on token '" tls.caCert=' [v8.32.0 try http://www.rsyslog.com/e/2207 ]
rsyslogd: CONFIG ERROR: could not interpret master config file '/etc/rsyslog.conf'. [v8.32.0 try http://www.rsyslog.com/e/2207 ]
```
Apparently had wrong kind of ″-mark (cursive I guess), noticed them also on client side, replaced with proper "-marks (fixed for examples above)

```
client side
client@client:~$ sudo service rsyslog restart
client@client:~$ sudo rsyslogd -N1
rsyslogd: version 8.32.0, config validation run (level 1), master config /etc/rsyslog.conf
rsyslogd: could not load module '/usr/lib/x86_64-linux-gnu/rsyslog/omrelp.so', dlopen: /usr/lib/x86_64-linux-gnu/rsyslog/omrelp.so: cannot open shared object file: No such file or directory  [v8.32.0 try http://www.rsyslog.com/e/2066 ]
rsyslogd: error during parsing file /etc/rsyslog.conf, on or before line 37: invalid character '(' in object definition - is there an invalid escape sequence somewhere? [v8.32.0 try http://www.rsyslog.com/e/2207 ]
rsyslogd: error during parsing file /etc/rsyslog.conf, on or before line 37: syntax error on token 'load' [v8.32.0 try http://www.rsyslog.com/e/2207 ]
rsyslogd: CONFIG ERROR: could not interpret master config file '/etc/rsyslog.conf'. [v8.32.0 try http://www.rsyslog.com/e/2207 ]
```

Was missing closing bracket ) after `tls.permittedpeer=["server"]`
This was missing also from reference material, corrected to .conf file

Now I was error free, but didn't get ny logs to server either.
Checked that server ip was correct, added client ip-adress to permitted peers
