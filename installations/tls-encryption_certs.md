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
$DefaultNetstreamDriverCAFile /etc/ssl/certs/ca.pem
$DefaultNetstreamDriverCertFile /etc/ssl/certs/cert.pem
$DefaultNetstreamDriverKeyFile /etc/ssl/certs/key.pem

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

