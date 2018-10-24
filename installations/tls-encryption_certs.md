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
wget https://raw.githubusercontent.com/rsyslog/rsyslog/master/contrib/gnutls/cert.pem 
wget https://raw.githubusercontent.com/rsyslog/rsyslog/master/contrib/gnutls/ca.pem
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


# Using self-generated certs

I installed the required packages:

gnutls-bin - GNU TLS library - includes certtool

rsyslog-gnutls - TLS protocol support for rsyslog (needed for both server and client(s))

## Server setup

```
sudoedit /etc/rsyslog.conf

#################
#### MODULES ####
#################

# make gtls driver the default
$DefaultNetstreamDriver gtls

# certificate files
$DefaultNetstreamDriverCAFile /etc/ssl/certs/server-ca.pem
$DefaultNetstreamDriverCertFile /etc/ssl/certs/xubuntu-cert.pem
$DefaultNetstreamDriverKeyFile /etc/ssl/certs/xubuntu-key.pem

$ModLoad imtcp # load TCP listener

$InputTCPServerStreamDriverMode 1 # run driver in TLS-only mode
$InputTCPServerStreamDriverAuthMode anon # client is NOT authenticated
$InputTCPServerRun 10514 # start up listener at port 10514

sudo service rsyslog restart
```

## Client setup

```
sudoedit /etc/rsyslog.conf

#################
#### MODULES ####
#################

# certificate files - just CA for a client
$DefaultNetstreamDriverCAFile /etc/ssl/certs/ca.pem

# set up the action
$DefaultNetstreamDriver gtls # use gtls netstream driver
$ActionSendStreamDriverMode 1 # require TLS for the connection
$ActionSendStreamDriverAuthMode anon # server is NOT authenticated
*.* @@172.28.172.69:10514 #  quite a lot of informatiosend (all) messages

sudo service rsyslog restart
```

## Generating certs

```
server@server:~$ certtool --generate-privkey --outfile server-ca-key.pem --bits 2048
** Note: You may use '--sec-param Medium' instead of '--bits 2048'
Generating a 2048 bit RSA private key...
server@server:~$ certtool --generate-self-signed --load-privkey server-ca-key.pem --outfile server-ca.pem
Generating a self signed certificate...
Please enter the details of the certificate's distinguished name. Just press enter to ignore a field.
Common name: Eino Lokittaja
UID: 
Organizational unit name: Lokattajat
Organization name: Lokittaja
Locality name: 
State or province name: 
Country name (2 chars): FI
Enter the subject's domain component (DC):     
This field should not be used in new certificates.
E-mail: 
Enter the certificate's serial number in decimal (default: 6611385902713951824): 


Activation/Expiration time.
The certificate will expire in (days): 3650


Extensions.
Does the certificate belong to an authority? (y/N): y
Path length constraint (decimal, -1 for no constraint): 
Is this a TLS web client certificate? (y/N): 
Will the certificate be used for IPsec IKE operations? (y/N): 
Is this a TLS web server certificate? (y/N): 
Enter a dnsName of the subject of the certificate: 172.28.172.69
Enter a dnsName of the subject of the certificate: 
Enter a URI of the subject of the certificate: 
Enter the IP address of the subject of the certificate: 172.28.172.69
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
	Serial Number (hex): 5bc05c732c4a5650
	Validity:
		Not Before: Fri Oct 12 08:33:57 UTC 2018
		Not After: Mon Oct 09 08:34:01 UTC 2028
	Subject: C=FI,O=Lokittaja,OU=Lokattajat,CN=Eino Lokittaja
	Subject Public Key Algorithm: RSA
	Algorithm Security Level: Medium (2048 bits)
		Modulus (bits 2048):
			00:a7:d8:ea:94:92:bd:45:4d:77:a3:a0:68:92:73:fc
			b8:37:b7:02:bb:d5:87:4c:86:ee:59:cb:a1:46:e8:eb
			c2:bb:ad:94:d2:e2:01:24:c1:5a:86:d9:82:60:1a:da
			c2:4d:40:f0:ac:02:29:76:d3:a6:2b:37:15:60:18:4d
			d2:c6:76:64:74:90:63:48:d9:80:9b:10:88:17:95:b9
			39:a1:fb:4f:e8:32:ba:ba:f2:65:c1:6a:02:cc:30:ca
			93:a8:6b:b9:61:a1:82:4d:d3:ea:00:b7:25:f9:8d:eb
			79:ab:a7:0e:66:67:17:51:84:02:02:cc:37:d3:23:82
			31:21:e4:97:23:e4:5f:be:f9:57:5b:02:01:51:65:7b
			6e:b7:c7:4f:fa:4a:ac:31:4d:e0:7f:47:01:2a:a6:c5
			63:e5:f4:76:0a:c1:73:de:3c:8b:55:bc:f1:c1:f6:42
			16:3f:6e:3b:52:02:a7:23:4c:d6:a6:00:1a:ca:b9:4e
			18:8a:c4:9f:3d:6a:5e:df:3b:8d:5f:17:64:67:65:1b
			b5:83:97:d7:17:3d:99:f1:6c:8a:68:25:88:ce:fc:8c
			ab:a3:42:40:68:bc:9a:75:57:53:22:e5:24:24:57:44
			46:7e:92:c0:b6:dd:ab:ad:82:12:0d:a9:aa:87:99:43
			6d
		Exponent (bits 24):
			01:00:01
	Extensions:
		Basic Constraints (critical):
			Certificate Authority (CA): TRUE
		Subject Alternative Name (not critical):
			DNSname: 172.28.172.69
			IPAddress: 172.28.172.69
		Key Usage (critical):
			Certificate signing.
		Subject Key Identifier (not critical):
			01de4c9560692a7b72f18f297ce984a991e38468
Other Information:
	Public Key ID:
		sha1:01de4c9560692a7b72f18f297ce984a991e38468
		sha256:8133485f890cafc4db82600317ea0f3e2c2bbec9a80b3e5b24b5acceb9ce009d
	Public Key PIN:
		pin-sha256:gTNIX4kMr8TbgmADF+oPPiwrvsmoCz5bJLWszrnOAJ0=
	Public key's random art:
		+--[ RSA 2048]----+
		|      . ++..     |
		|     . *o .      |
		|      .o+        |
		|    . o  .       |
		|     o oS        |
		| . .o.oo.        |
		|.E. ==o .=       |
		|.  o +o.= .      |
		|    o  +.        |
		+-----------------+

Is the above information ok? (y/N): y


Signing certificate...
server@server:~$ certtool --generate-privkey --outfile xubuntu-key.pem --bits 2048
** Note: You may use '--sec-param Medium' instead of '--bits 2048'
Generating a 2048 bit RSA private key...
server@server:~$ certtool --generate-request --load-privkey xubuntu-key.pem --outfile xubuntu-request.pem
Generating a PKCS #10 certificate request...
Common name: Eino Lokittaja
Organizational unit name: Lokittajat
Organization name: Lokittaja
Locality name: 
State or province name: 
Country name (2 chars): FI
Enter the subject's domain component (DC): 
UID: 
Enter a dnsName of the subject of the certificate: 172.28.171.203
Enter a dnsName of the subject of the certificate: 
Enter a URI of the subject of the certificate: 
Enter the IP address of the subject of the certificate: 172.28.171.203
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
Is this a TLS web client certificate? (y/N): 
Is this a TLS web server certificate? (y/N): 
server@server:~$ certtool --generate-certificate --load-request xubuntu-request.pem --outfile xubuntu-cert.pem --load-ca-certificate server-ca.pem --load-ca-privkey server-ca-key.pem 
Generating a signed certificate...
Enter the certificate's serial number in decimal (default: 6611391417105138548): 


Activation/Expiration time.
The certificate will expire in (days): 3650

Expiration time: Mon Oct  9 11:55:25 2028
CA expiration time: Mon Oct  9 11:34:01 2028
Warning: The time set exceeds the CA's expiration time
Is it ok to proceed? (y/N): y


Extensions.
Do you want to honour all the extensions from the request? (y/N): y
Does the certificate belong to an authority? (y/N): n
Is this a TLS web client certificate? (y/N): 
Will the certificate be used for IPsec IKE operations? (y/N): 
Is this a TLS web server certificate? (y/N): 
Enter a dnsName of the subject of the certificate: 172.28.171.203
Enter a dnsName of the subject of the certificate: 
Enter a URI of the subject of the certificate: 
Enter the IP address of the subject of the certificate: 172.28.171.203
Enter the e-mail of the subject of the certificate: 
Will the certificate be used for signing (required for TLS)? (Y/n): y
Will the certificate be used for encryption (not required for TLS)? (Y/n): y
Will the certificate be used to sign OCSP requests? (y/N): 
Will the certificate be used to sign code? (y/N): 
Will the certificate be used for time stamping? (y/N): 
Will the certificate be used for email protection? (y/N): 
X.509 Certificate Information:
	Version: 3
	Serial Number (hex): 5bc06177179e4374
	Validity:
		Not Before: Fri Oct 12 08:55:21 UTC 2018
		Not After: Mon Oct 09 08:55:25 UTC 2028
	Subject: C=FI,O=Lokittaja,OU=Lokittajat,CN=Eino Lokittaja
	Subject Public Key Algorithm: RSA
	Algorithm Security Level: Medium (2048 bits)
		Modulus (bits 2048):
			00:b4:3f:8a:97:18:a7:66:84:48:c3:39:5f:7f:a2:de
			7b:6f:f7:1e:07:cb:bc:fc:87:d0:22:0f:29:2b:34:80
			60:68:e0:ca:69:85:66:82:1a:76:03:50:81:93:a1:02
			a7:11:94:ee:1f:3c:02:6e:ca:e8:4c:70:91:03:07:26
			2f:c8:40:6d:74:4c:cc:27:36:ec:f2:74:08:fe:35:4c
			c0:d3:16:bf:03:60:67:6a:0d:b6:af:18:51:0b:58:31
			c6:26:55:12:4b:b2:a4:d9:02:0d:b3:26:fe:55:97:61
			16:7f:2d:c3:35:73:4d:81:ac:1f:24:70:2e:f5:1b:eb
			c6:f0:ed:3e:51:f4:cc:e0:20:21:8f:06:99:59:6a:31
			3a:1e:cb:58:eb:62:8b:ca:bd:cc:ae:c7:68:ba:a0:a0
			ce:f4:fc:53:f2:98:24:5b:aa:9f:00:b3:8c:2b:bd:3d
			15:e5:37:de:5e:43:d6:9f:ea:d7:fb:8d:1f:60:86:cf
			d3:51:0a:37:ea:f3:78:ee:99:c7:b7:46:74:a2:e2:2e
			1b:7a:bb:1c:16:da:76:1f:90:18:c5:15:2a:bc:d2:a7
			83:2a:a2:59:5b:cc:be:c9:c2:c0:38:f5:7c:67:42:33
			d6:fb:78:ce:75:76:22:02:b8:a4:73:90:69:34:9d:ff
			55
		Exponent (bits 24):
			01:00:01
	Extensions:
		Subject Alternative Name (not critical):
			DNSname: 172.28.171.203
			IPAddress: 172.28.171.203
			DNSname: 172.28.171.203
			IPAddress: 172.28.171.203
		Basic Constraints (critical):
			Certificate Authority (CA): FALSE
		Key Usage (critical):
			Digital signature.
			Key encipherment.
		Subject Key Identifier (not critical):
			259b5b2fa0ed87f6389c23cf6fa3bc2913d26622
		Authority Key Identifier (not critical):
			01de4c9560692a7b72f18f297ce984a991e38468
Other Information:
	Public Key ID:
		sha1:259b5b2fa0ed87f6389c23cf6fa3bc2913d26622
		sha256:fa9d74d4d09813a1cb87890c69771cd27592ccf937dbc1434f5df40ded31942d
	Public Key PIN:
		pin-sha256:+p101NCYE6HLh4kMaXcc0nWSzPk328FDT130De0xlC0=
	Public key's random art:
		+--[ RSA 2048]----+
		|                 |
		|                 |
		|        . .      |
		|         =       |
		|     .  S .      |
		|  E o =o + .     |
		|   . =.ooo. .    |
		|      ++Bo+.     |
		|       *XXo.     |
		+-----------------+

Is the above information ok? (y/N): y


Signing certificate...
```

I moved "server-ca.pem" to client /home/xubuntu/gntls/

Adter service restarts got error on client:

![Gnutlserror](https://raw.githubusercontent.com/jisosomppi/log-analysis/master/images/GnuTLS_error.png.jpg)

I'm guessing that I've just configured certs wrong, as I still don't have the big pictutre of certs clear to me.

# New try with new instructions and relp

Removed lines added in the former conf to /etc/rsyslog.conf
Installed rsyslog-relp package

## Generating the certificates

```
server@server:~$ certtool --generate-privkey --outfile ca-key.pem --bits 2048
** Note: You may use '--sec-param Medium' instead of '--bits 2048'
Generating a 2048 bit RSA private key...
server@server:~$ certtool --generate-self-signed --load-privkey ca-key.pem --outfile ca.pem
Generating a self signed certificate...
Please enter the details of the certificate's distinguished name. Just press enter to ignore a field.
Common name: Eino Lokittaja
UID: 
Organizational unit name: 
Organization name: 
Locality name: 
State or province name: 
Country name (2 chars): FI
Enter the subject's domain component (DC): 
This field should not be used in new certificates.
E-mail: 
Enter the certificate's serial number in decimal (default: 6611438636534953346): 


Activation/Expiration time.
The certificate will expire in (days): 3650


Extensions.
Does the certificate belong to an authority? (y/N): y
Path length constraint (decimal, -1 for no constraint): 
Is this a TLS web client certificate? (y/N): 
Will the certificate be used for IPsec IKE operations? (y/N): 
Is this a TLS web server certificate? (y/N): 
Enter a dnsName of the subject of the certificate: 172.28.172.69
Enter a dnsName of the subject of the certificate: 
Enter a URI of the subject of the certificate: 
Enter the IP address of the subject of the certificate: 172.28.172.69
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
	Serial Number (hex): 5bc08c6938f57582
	Validity:
		Not Before: Fri Oct 12 11:58:35 UTC 2018
		Not After: Mon Oct 09 11:58:38 UTC 2028
	Subject: C=FI,CN=Eino Lokittaja
	Subject Public Key Algorithm: RSA
	Algorithm Security Level: Medium (2048 bits)
		Modulus (bits 2048):
			00:ca:fc:65:57:02:2d:9c:8f:91:96:b0:af:c2:f4:b7
			17:52:3b:80:43:37:bf:97:01:86:ee:85:6f:70:93:83
			2d:77:53:6b:94:8c:59:37:05:4f:96:1a:28:8c:da:6f
			ae:fb:6f:dc:72:10:b6:1e:9a:6b:80:d2:d0:5f:49:09
			68:d7:7b:f2:bf:5c:00:ac:ac:59:df:db:ab:d7:9f:4c
			d6:da:9e:15:da:c0:34:58:b4:0d:9f:69:f8:ef:6f:06
			cc:34:b0:45:94:db:7b:17:14:d4:41:9c:5f:25:57:48
			fc:9f:b1:67:c2:23:ce:6e:9f:8a:1b:3a:ff:e2:fa:fe
			ce:25:fd:ee:ef:e7:64:dd:9b:f6:d4:72:e1:ac:bd:6d
			0b:bd:3a:1b:a7:20:f5:6c:9a:29:2f:42:08:52:cb:de
			35:36:17:7f:85:ae:fc:86:6c:a6:b9:4e:8b:0d:ed:d3
			28:fc:cb:52:c6:31:06:af:1c:49:ec:7c:28:02:d5:7f
			e6:a6:78:92:c1:60:b2:95:0c:a5:d3:87:2c:b6:9b:51
			5f:ed:89:5b:17:80:5a:d2:c8:76:ae:fc:d8:29:f9:62
			55:d1:d3:00:c7:70:53:b2:3b:88:0a:24:0b:4a:e6:a7
			b9:e6:12:c1:35:dd:bb:0c:45:7a:d0:c1:e1:dd:af:5c
			09
		Exponent (bits 24):
			01:00:01
	Extensions:
		Basic Constraints (critical):
			Certificate Authority (CA): TRUE
		Subject Alternative Name (not critical):
			DNSname: 172.28.172.69
			IPAddress: 172.28.172.69
		Key Usage (critical):
			Certificate signing.
		Subject Key Identifier (not critical):
			251325f980d711a42307bcd9d14b23d5d0197e1c
Other Information:
	Public Key ID:
		sha1:251325f980d711a42307bcd9d14b23d5d0197e1c
		sha256:35b836ca311e54892f81942f23689b6c113c808ad6301986f8899d66c652c57b
	Public Key PIN:
		pin-sha256:Nbg2yjEeVIkvgZQvI2ibbBE8gIrWMBmG+ImdZsZSxXs=
	Public key's random art:
		+--[ RSA 2048]----+
		|     ...oBB*.oE  |
		|      o.*+=.+. . |
		|      .=**.o. o  |
		|      oo.=o  .   |
		|        S        |
		|                 |
		|                 |
		|                 |
		|                 |
		+-----------------+

Is the above information ok? (y/N): y


Signing certificate...
server@server:~$ chmod 400 ca-key.pem
```

### Server key and config

```
server@server:~$ certtool --generate-privkey --outfile server-key.pem --bits 2048
** Note: You may use '--sec-param Medium' instead of '--bits 2048'
Generating a 2048 bit RSA private key...
server@server:~$ certtool --generate-request --load-privkey server-key.pem --outfile server-request.pem
Generating a PKCS #10 certificate request...
Common name: 172.28.172.69
Organizational unit name: 
Organization name: 
Locality name: 
State or province name: 
Country name (2 chars): 
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
Enter the certificate's serial number in decimal (default: 6611440985319250654): 


Activation/Expiration time.
The certificate will expire in (days): 3650

Expiration time: Mon Oct  9 15:07:50 2028
CA expiration time: Mon Oct  9 14:58:38 2028
Warning: The time set exceeds the CA's expiration time
Is it ok to proceed? (y/N): y


Extensions.
Do you want to honour all the extensions from the request? (y/N): y
Does the certificate belong to an authority? (y/N): n
Is this a TLS web client certificate? (y/N): y
Will the certificate be used for IPsec IKE operations? (y/N): 
Is this a TLS web server certificate? (y/N): y
Enter a dnsName of the subject of the certificate: 172.28.172.69
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
	Serial Number (hex): 5bc08e8c17699ade
	Validity:
		Not Before: Fri Oct 12 12:07:46 UTC 2018
		Not After: Mon Oct 09 12:07:50 UTC 2028
	Subject: CN=172.28.172.69
	Subject Public Key Algorithm: RSA
	Algorithm Security Level: Medium (2048 bits)
		Modulus (bits 2048):
			00:98:d0:9b:4a:64:56:c6:81:bc:95:7e:71:d4:3c:bb
			db:9f:15:a1:a3:03:14:03:84:55:d5:35:05:9f:23:56
			d1:65:40:ab:b5:6b:07:b4:e9:b2:2f:94:ea:b5:06:78
			e0:0c:28:37:08:f8:2b:fa:0c:cf:54:2d:e3:d1:b6:eb
			40:16:a9:f1:65:12:12:32:13:e1:3b:43:05:c5:9a:db
			23:b3:fd:48:2f:6e:30:ed:37:f0:f7:78:3d:2c:a7:e9
			54:60:50:1b:80:cc:6c:fe:15:50:93:28:97:ae:56:ef
			67:ce:ef:92:66:5f:ea:e4:e9:f6:b5:35:59:e2:a6:17
			40:f3:a1:5e:d6:4b:ce:61:9e:42:5d:53:97:6d:d7:7c
			61:72:47:87:d2:cb:ec:5f:cd:e6:f7:43:39:c3:8f:c5
			12:10:b7:a5:fc:08:46:10:eb:b5:e7:9c:6f:3d:5a:ae
			e7:f7:08:4c:90:de:71:b3:b0:15:9d:7b:03:87:5c:39
			a1:04:af:ce:72:05:c2:1c:f8:23:39:af:e0:74:c3:81
			53:8d:d8:0a:50:2c:29:2a:7e:45:b0:72:a9:a2:49:0d
			c4:c9:f4:91:e8:00:33:f0:cd:7f:c7:54:e2:cd:0f:63
			de:8b:97:c1:6e:ab:3e:ff:d3:58:8b:f0:c0:a5:62:cd
			1f
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
			DNSname: 172.28.172.69
		Subject Key Identifier (not critical):
			a397cfa9392fb64984ec3ea9388394de8235937f
		Authority Key Identifier (not critical):
			251325f980d711a42307bcd9d14b23d5d0197e1c
Other Information:
	Public Key ID:
		sha1:a397cfa9392fb64984ec3ea9388394de8235937f
		sha256:9ecba43c5b9a4eccb9bc2fb654809cba319fe4b105762227a94f4eec6fa07cbb
	Public Key PIN:
		pin-sha256:nsukPFuaTsy5vC+2VICcujGf5LEFdiInqU9O7G+gfLs=
	Public key's random art:
		+--[ RSA 2048]----+
		|                 |
		|                 |
		|                 |
		|     . .         |
		|  ..  o S        |
		| o=  . o o       |
		|+o.+  o.+        |
		|oooo..Eo+= .     |
		|  oo.o.o=*=      |
		+-----------------+

Is the above information ok? (y/N): y


Signing certificate...

server@server:~$ rm -f server-request.pem 
```
```
sudoedit /etc/rsyslog.conf

module(load="imrelp" ruleset="relp")
input(type="imrelp" port="20514"
tls="on"
tls.caCert="/home/server/ca.pem"
tls.myCert="/home/server/server-cert.pem"
tls.myPrivKey="/home/server/server-key.pem"
tls.authMode="name"
tls.permittedpeer=["172.28.171.203"] )
ruleset (name="relp") { action(type="omfile" file="/var/log/relp_log") }
```

## Client key and config

```
server@server:~$ certtool --generate-privkey --outfile xubuntu-key.pem --bits 2048
** Note: You may use '--sec-param Medium' instead of '--bits 2048'
Generating a 2048 bit RSA private key...
server@server:~$ certtool --generate-request --load-privkey xubuntu-key.pem --outfile request.pem 
Generating a PKCS #10 certificate request...
Common name: 172.28.171.203
Organizational unit name: 
Organization name: 
Locality name: 
State or province name: 
Country name (2 chars): FI
Enter the subject's domain component (DC): 
UID: 
Enter a dnsName of the subject of the certificate: 172.28.171.203
Enter a dnsName of the subject of the certificate: 
Enter a URI of the subject of the certificate: 
Enter the IP address of the subject of the certificate: 172.28.171.203
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
server@server:~$ certtool --generate-certificate --load-request request.pem --outfile xubuntu-cert.pem --load-ca-certificate ca.pem --load-ca-privkey ca-key.pem 
Generating a signed certificate...
Enter the certificate's serial number in decimal (default: 6611445169207025621): 


Activation/Expiration time.
The certificate will expire in (days): 3650

Expiration time: Mon Oct  9 15:24:03 2028
CA expiration time: Mon Oct  9 14:58:38 2028
Warning: The time set exceeds the CA's expiration time
Is it ok to proceed? (y/N): y


Extensions.
Do you want to honour all the extensions from the request? (y/N): y
Does the certificate belong to an authority? (y/N): n
Is this a TLS web client certificate? (y/N): y
Will the certificate be used for IPsec IKE operations? (y/N):  
Is this a TLS web server certificate? (y/N): y
Enter a dnsName of the subject of the certificate: 172.28.171.203
Enter a dnsName of the subject of the certificate: 
Enter a URI of the subject of the certificate: 
Enter the IP address of the subject of the certificate: 172.28.171.203
Will the certificate be used for signing (DHE ciphersuites)? (Y/n): 
Will the certificate be used for encryption (RSA ciphersuites)? (Y/n): 
Will the certificate be used to sign OCSP requests? (y/N): 
Will the certificate be used to sign code? (y/N): 
Will the certificate be used for time stamping? (y/N): 
Will the certificate be used for email protection? (y/N): 
X.509 Certificate Information:
	Version: 3
	Serial Number (hex): 5bc0925a3a8e9fd5
	Validity:
		Not Before: Fri Oct 12 12:24:01 UTC 2018
		Not After: Mon Oct 09 12:24:03 UTC 2028
	Subject: C=FI,CN=172.28.171.203
	Subject Public Key Algorithm: RSA
	Algorithm Security Level: Medium (2048 bits)
		Modulus (bits 2048):
			00:a0:e8:f1:04:fb:48:bc:e3:f7:3a:32:0f:27:7d:ab
			3c:0f:b5:3f:1d:31:6a:8e:a6:e3:0a:67:d9:d2:84:ca
			d6:62:db:fa:5c:19:9f:79:b3:f2:ae:3b:47:53:51:9d
			af:f2:65:f6:ff:11:f8:2d:cb:4c:1d:41:70:7c:4b:4b
			0b:4c:22:eb:26:1c:42:96:81:6c:4f:ba:0f:b5:e8:a8
			66:7a:82:39:bc:d6:ce:ac:48:3c:5e:12:82:6b:20:2d
			bd:bf:1b:43:49:50:90:4e:42:ad:1b:f8:ae:ae:75:45
			c2:d6:42:1b:21:4c:a6:d5:8a:7e:17:2f:00:91:25:a6
			18:07:e8:45:d4:2f:48:ac:c0:c6:45:2c:ff:42:47:f8
			c0:9c:25:59:0c:d9:b0:62:d2:1f:91:65:74:db:d0:93
			ac:7a:1c:15:a2:d9:0d:95:e1:54:a2:76:3c:f4:54:54
			59:42:cb:b0:2c:df:d7:f8:3a:30:0c:e9:2a:eb:26:90
			6b:db:62:77:67:67:f2:e6:e7:8c:e4:ad:3b:bf:d6:07
			ef:7e:33:2b:9d:c2:c8:b5:bc:29:8b:7b:60:8c:9d:7d
			c7:0f:e5:3b:b5:61:c6:f9:b9:74:56:10:11:21:13:d4
			cd:ac:75:42:d9:05:07:9d:b4:38:4b:72:30:bf:44:ea
			d3
		Exponent (bits 24):
			01:00:01
	Extensions:
		Subject Alternative Name (not critical):
			DNSname: 172.28.171.203
			IPAddress: 172.28.171.203
			DNSname: 172.28.171.203
			IPAddress: 172.28.171.203
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
		Subject Key Identifier (not critical):
			49fe88384668b4ed42c933f37eee0a53f9a58797
		Authority Key Identifier (not critical):
			251325f980d711a42307bcd9d14b23d5d0197e1c
Other Information:
	Public Key ID:
		sha1:49fe88384668b4ed42c933f37eee0a53f9a58797
		sha256:efae14bfb4523fb903564738d2b82398f718fe34f9ef6a35442c9fcb4e1279f2
	Public Key PIN:
		pin-sha256:764Uv7RSP7kDVkc40rgjmPcY/jT572o1RCyfy04SefI=
	Public key's random art:
		+--[ RSA 2048]----+
		|                 |
		|                 |
		|  .     .        |
		| o = . o .       |
		|  @ =   S        |
		| o O o = +       |
		|  + * = E .      |
		|   * ..o         |
		|    o=o          |
		+-----------------+

Is the above information ok? (y/N): y


Signing certificate...
server@server:~$ rm -f request.pem 
```
```
sudoedit /etc/rsyslog.conf

module(load="omrelp")
module(load="imtcp")
input(type="imtcp" port="514")
action(type="omrelp" target="172.28.172.69" port="20514"
tls="on"
tls.caCert="/home/xubuntu/ca.pem"
tls.myCert="/home/xubuntu/xubuntu-cert.pem"
tls.myPrivKey="/home/xubuntu/xubuntu-key.pem"
tls.authmode="name"
tls.permittedpeer=["172.28.172.69"] )
```
Restarted both services

## Debugging

Server error
![servererror](https://raw.githubusercontent.com/jisosomppi/log-analysis/master/images/server_error.png.jpg)

Client error
![clienterror](https://raw.githubusercontent.com/jisosomppi/log-analysis/master/images/client-error'.png.jpg)


