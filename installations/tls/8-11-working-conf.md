https://www.rsyslog.com/doc/v8-stable/tutorials/tls.html
https://serverfault.com/questions/579709/rsyslog-through-tls

Sertificates were created on "server" -machine

`sudo apt install -y gnutls-bin`

## Self-signed CA

```
testi@testi:~/Downloads$ cd /etc/ssl/rsyslog/
testi@testi:/etc/ssl/rsyslog$ sudo certtool --generate-privkey --outfile CA-key.pem
Generating a 3072 bit RSA private key...
testi@testi:/etc/ssl/rsyslog$ sudo chmod 400 CA-key.pem
testi@testi:/etc/ssl/rsyslog$ sudo certtool --generate-self-signed --load-privkey CA-key.pem --outfile CA.pem
Generating a self signed certificate...
Please enter the details of the certificate's distinguished name. Just press enter to ignore a field.
Common name: Eino Kupias
UID: 
Organizational unit name: 
Organization name: 
Locality name: 
State or province name: 
Country name (2 chars): 
Enter the subject's domain component (DC): 
This field should not be used in new certificates.
E-mail: 
Enter the certificate's serial number in decimal (default: 6621455869640976498): 


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
Enter the e-mail of the subject of the certificate: 
Will the certificate be used to sign OCSP requests? (y/N): 
Will the certificate be used to sign code? (y/N): 
Will the certificate be used for time stamping? (y/N): 
Will the certificate be used for email protection? (y/N): 
Will the certificate be used to sign other certificates? (y/N): y
Will the certificate be used to sign CRLs? (y/N): y
Enter the URI of the CRL distribution point: 
X.509 Certificate Information:
	Version: 3
	Serial Number (hex): 5be423080de02872
	Validity:
		Not Before: Thu Nov 08 11:50:33 UTC 2018
		Not After: Sun Nov 05 11:50:35 UTC 2028
	Subject: CN=Eino Kupias
	Subject Public Key Algorithm: RSA
	Algorithm Security Level: High (3072 bits)
		Modulus (bits 3072):
			00:a9:a6:93:c8:8b:e5:fd:7b:b8:2a:5f:0b:71:a7:c6
			c5:d3:25:b7:f3:1a:94:32:5a:08:f5:c3:b5:c0:5c:80
			5d:48:35:10:87:ca:cc:be:c2:0b:0a:21:6b:cc:46:0d
			ee:c4:7d:69:c6:6a:54:87:1d:b2:37:27:bc:13:2c:08
			fe:8f:12:b0:b7:65:1a:01:d8:47:c7:55:3f:6d:f9:7d
			3e:c9:c8:67:9f:61:6d:e4:f4:31:64:69:25:c9:1e:8e
			df:84:6c:ce:08:1e:ab:80:c4:09:6a:ff:2a:83:ea:c8
			90:18:98:94:96:18:76:98:3f:4b:e3:46:ee:26:2c:0e
			33:09:1e:d7:d8:9e:6c:94:9d:ca:e0:e5:3b:79:ef:da
			67:ca:ec:60:24:87:c6:30:40:70:11:a6:0d:84:bc:d2
			c8:07:9c:17:62:2d:7c:74:17:56:78:cc:9a:c2:7d:da
			87:6b:3e:78:82:64:d6:7d:61:c8:27:4f:ca:59:c3:43
			72:bb:f0:ea:42:91:6a:f0:30:c4:a1:71:3b:34:64:0c
			f0:6b:fd:f1:41:04:77:21:b1:73:c0:93:44:88:e6:c7
			c3:41:26:1b:14:ab:3d:43:3f:36:83:cb:d3:a3:c1:32
			69:ac:4f:30:68:db:17:dd:57:d5:eb:25:f9:e2:9c:2b
			e3:d3:e5:c6:39:eb:e1:0e:c2:66:37:22:7a:8e:d6:b8
			ba:cf:32:fb:c4:8c:d0:1c:f9:20:85:f1:5c:3e:4b:47
			d0:e7:da:85:75:2e:fd:c3:e0:b8:e0:b5:8d:94:45:e3
			03:e5:26:3d:df:f7:8a:01:03:7f:cd:a8:10:d9:c8:6c
			9c:d3:8e:05:fa:ba:60:e6:34:40:86:89:88:99:34:f9
			bd:31:77:5a:91:4f:03:ae:07:f2:18:ab:a4:00:46:17
			49:32:1c:d8:93:54:fc:4c:e4:d1:e3:d9:1d:30:15:33
			20:3a:4b:12:56:82:c8:4f:8a:1d:fa:17:88:f2:74:57
			31
		Exponent (bits 24):
			01:00:01
	Extensions:
		Basic Constraints (critical):
			Certificate Authority (CA): TRUE
		Key Usage (critical):
			Certificate signing.
			CRL signing.
		Subject Key Identifier (not critical):
			d96aa2b42b07fcb5838d086d618cacd4207e98c1
Other Information:
	Public Key ID:
		sha1:d96aa2b42b07fcb5838d086d618cacd4207e98c1
		sha256:11cda1925438ece44c587b808d11e7d4de29a66dcd62387fbc58f7df34a907c3
	Public Key PIN:
		pin-sha256:Ec2hklQ47ORMWHuAjRHn1N4ppm3NYjh/vFj33zSpB8M=
	Public key's random art:
		+--[ RSA 3072]----+
		|.                |
		|.E               |
		|+o*              |
		|.*+o     o       |
		|o+..    S .      |
		|o =   .  .       |
		| o +.=..o        |
		|  o.=o+o         |
		|   o+. .         |
		+-----------------+

Is the above information ok? (y/N): y


Signing certificate...
```

## Server cert

```
testi@testi:/etc/ssl/rsyslog$ sudo certtool --generate-privkey --outfile SERVER-key.pem --bits 2048
** Note: You may use '--sec-param Medium' instead of '--bits 2048'
Generating a 2048 bit RSA private key...
testi@testi:/etc/ssl/rsyslog$ sudo certtool --generate-request --load-privkey SERVER-key.pem --outfile SERVER-request.pem 
Generating a PKCS #10 certificate request...
Common name: 172.28.171.71                                                                               
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
Does the certificate belong to an authority? (y/N): 
Will the certificate be used for signing (DHE ciphersuites)? (Y/n): 
Will the certificate be used for encryption (RSA ciphersuites)? (Y/n): 
Will the certificate be used to sign code? (y/N): 
Will the certificate be used for time stamping? (y/N): 
Will the certificate be used for email protection? (y/N): 
Will the certificate be used for IPsec IKE operations? (y/N): 
Will the certificate be used to sign OCSP requests? (y/N): 
Is this a TLS web client certificate? (y/N): 
Is this a TLS web server certificate? (y/N): 
testi@testi:/etc/ssl/rsyslog$ sudo certtool --generate-certificate --load-request SERVER-request.pem --outfile SERVER-cert.pem --load-ca-certificate CA.pem --load-ca-privkey CA-key.pem
Generating a signed certificate...
Enter the certificate's serial number in decimal (default: 6621456488541653430): 


Activation/Expiration time.
The certificate will expire in (days): 1000


Extensions.
Do you want to honour all the extensions from the request? (y/N): 
Does the certificate belong to an authority? (y/N): 
Is this a TLS web client certificate? (y/N): y
Will the certificate be used for IPsec IKE operations? (y/N): 
Is this a TLS web server certificate? (y/N): y
Enter a dnsName of the subject of the certificate: 172.28.171.71
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
	Serial Number (hex): 5be42398273b09b6
	Validity:
		Not Before: Thu Nov 08 11:52:59 UTC 2018
		Not After: Wed Aug 04 11:53:03 UTC 2021
	Subject: CN=172.28.171.71
	Subject Public Key Algorithm: RSA
	Algorithm Security Level: Medium (2048 bits)
		Modulus (bits 2048):
			00:bb:fc:bb:51:1a:fb:57:b5:0f:a5:c5:78:11:fa:32
			9e:21:84:16:29:ee:c3:43:0d:57:7d:4f:f6:db:f6:ef
			ff:63:d8:f7:a2:19:3e:d1:a1:39:7b:7f:23:67:ff:4c
			12:19:e0:1d:2e:b8:27:a7:cf:64:06:39:38:84:36:c2
			6f:2e:ec:11:59:c7:79:e9:ae:1c:7c:ca:8b:3c:a6:48
			c6:e9:ca:7b:31:f0:39:a7:bb:10:28:2f:63:c5:80:c4
			a4:0e:57:d0:64:b9:96:59:ef:a7:8b:92:1f:ab:38:2f
			b5:30:49:8e:6d:1d:17:3c:f4:ef:2b:b5:c1:e4:7d:cc
			35:7d:65:61:86:1f:dd:86:04:41:d4:d9:da:22:75:67
			0e:90:d2:82:ec:d0:7c:a7:87:9a:54:3e:e5:1c:1b:5c
			0b:22:8d:7a:5c:8b:9f:74:fd:8b:c1:40:d4:a1:46:b2
			87:8b:34:7f:1c:eb:a2:48:2c:fd:83:1c:86:55:1f:fa
			b7:b4:69:9e:1b:c0:38:84:0e:61:78:35:73:b7:f1:b5
			2f:8e:30:80:9a:f4:5f:08:7b:a4:85:8c:e3:dd:ab:d7
			43:c9:78:c6:e1:0b:48:42:97:d1:6d:71:cc:c0:c4:4f
			fb:8e:fd:91:9c:77:34:1c:fa:06:21:88:2f:87:7d:dd
			d5
		Exponent (bits 24):
			01:00:01
	Extensions:
		Basic Constraints (critical):
			Certificate Authority (CA): FALSE
		Key Purpose (not critical):
			TLS WWW Client.
			TLS WWW Server.
		Subject Alternative Name (not critical):
			DNSname: 172.28.171.71
		Key Usage (critical):
			Digital signature.
			Key encipherment.
		Subject Key Identifier (not critical):
			233a069d02d5a33fe6d55ca305346f710e5ecd58
		Authority Key Identifier (not critical):
			d96aa2b42b07fcb5838d086d618cacd4207e98c1
Other Information:
	Public Key ID:
		sha1:233a069d02d5a33fe6d55ca305346f710e5ecd58
		sha256:829b7fc545e721ec318a74b37aa8faeec1aabede937652ac30a951648a34dd11
	Public Key PIN:
		pin-sha256:gpt/xUXnIewxinSzeqj67sGqvt6TdlKsMKlRZIo03RE=
	Public key's random art:
		+--[ RSA 2048]----+
		|  ..   .o o o=E  |
		| .  o   .+ *. o  |
		|.  . .   .+ .    |
		| ... .   .+      |
		|  o.o .oS+ .     |
		|   o+...+.       |
		|   o+o           |
		|   ...           |
		|                 |
		+-----------------+

Is the above information ok? (y/N): y


Signing certificate...
```

##Client certs

```
testi@testi:/etc/ssl/rsyslog$ sudo certtool --generate-privkey --outfile CLIENT-key.pem --bits 2048
** Note: You may use '--sec-param Medium' instead of '--bits 2048'
Generating a 2048 bit RSA private key...
testi@testi:/etc/ssl/rsyslog$ sudo certtool --generate-request --load-privkey CLIENT-key.pem --outfile CLIENT-request.pem 
Generating a PKCS #10 certificate request...
Common name: 172.28.171.52
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
Does the certificate belong to an authority? (y/N): 
Will the certificate be used for signing (DHE ciphersuites)? (Y/n): 
Will the certificate be used for encryption (RSA ciphersuites)? (Y/n): 
Will the certificate be used to sign code? (y/N): 
Will the certificate be used for time stamping? (y/N): 
Will the certificate be used for email protection? (y/N): 
Will the certificate be used for IPsec IKE operations? (y/N): 
Will the certificate be used to sign OCSP requests? (y/N): 
Is this a TLS web client certificate? (y/N): 
Is this a TLS web server certificate? (y/N): 
testi@testi:/etc/ssl/rsyslog$ sudo certtool --generate-certificate --load-request CLIENT-request.pem --outfile CLIENT-cert.pem --load-ca-certificate CA.pem --load-ca-privkey CA-key.pem
Generating a signed certificate...
Enter the certificate's serial number in decimal (default: 6621458334721676231): 


Activation/Expiration time.
The certificate will expire in (days): 1000


Extensions.
Do you want to honour all the extensions from the request? (y/N): 
Does the certificate belong to an authority? (y/N): 
Is this a TLS web client certificate? (y/N): y
Will the certificate be used for IPsec IKE operations? (y/N): 
Is this a TLS web server certificate? (y/N): y
Enter a dnsName of the subject of the certificate: 172.28.171.52
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
	Serial Number (hex): 5be42546002293c7
	Validity:
		Not Before: Thu Nov 08 12:00:08 UTC 2018
		Not After: Wed Aug 04 12:00:10 UTC 2021
	Subject: CN=172.28.171.52
	Subject Public Key Algorithm: RSA
	Algorithm Security Level: Medium (2048 bits)
		Modulus (bits 2048):
			00:da:35:a3:dd:4b:96:87:83:ab:eb:17:6e:89:51:fa
			28:9c:df:e2:d3:3b:f4:ac:49:7b:ab:f3:de:00:6a:46
			ef:e5:10:e6:ac:0c:f4:a8:46:35:13:8f:5a:4a:5a:b2
			d4:bc:e6:b1:1a:6b:c7:28:62:10:96:70:9a:74:60:2a
			e3:91:8d:33:2e:f3:30:a4:7f:2b:ff:35:70:53:7c:3e
			61:e0:d3:b8:cb:5c:c1:a5:2c:9a:f2:20:dd:6f:c6:a0
			6a:89:d5:54:84:7c:5b:ee:11:bf:45:f5:e3:d1:e2:15
			92:6a:51:95:39:63:65:a9:9c:d3:47:38:1a:c6:2d:72
			cf:b6:02:4d:d7:dd:aa:3e:92:2e:c3:42:42:9a:58:7f
			d3:2c:3c:86:6f:f1:af:bc:48:ca:d1:04:0a:80:25:69
			fb:be:4d:1d:54:e9:67:77:11:87:99:07:b7:fe:8c:00
			06:2b:cc:c2:73:d4:fb:b4:e2:b4:9b:78:62:3c:f6:ce
			37:bf:31:fa:97:40:ad:c8:2d:2d:4c:73:f0:fd:9f:a0
			b1:cc:7f:8c:d7:87:b8:ba:3a:35:22:72:04:f5:b8:7f
			f6:12:8f:41:3b:0c:aa:b5:56:f7:8c:37:b0:94:2d:92
			72:5f:2b:94:6e:46:76:64:86:0b:0f:2f:1c:df:c7:03
			75
		Exponent (bits 24):
			01:00:01
	Extensions:
		Basic Constraints (critical):
			Certificate Authority (CA): FALSE
		Key Purpose (not critical):
			TLS WWW Client.
			TLS WWW Server.
		Subject Alternative Name (not critical):
			DNSname: 172.28.171.52
		Key Usage (critical):
			Digital signature.
			Key encipherment.
		Subject Key Identifier (not critical):
			5dfd6066901b56ed617774a7887f36461411a504
		Authority Key Identifier (not critical):
			d96aa2b42b07fcb5838d086d618cacd4207e98c1
Other Information:
	Public Key ID:
		sha1:5dfd6066901b56ed617774a7887f36461411a504
		sha256:f960175e1635ed89222cda09d5c0be40ec97d1d4eb58d104d3e0cc50dd670bb3
	Public Key PIN:
		pin-sha256:+WAXXhY17YkiLNoJ1cC+QOyX0dTrWNEE0+DMUN1nC7M=
	Public key's random art:
		+--[ RSA 2048]----+
		|            E+BB=|
		|           .+* =*|
		|          ..oo@.+|
		|         . o.= o.|
		|        S . . = .|
		|             + . |
		|                 |
		|                 |
		|                 |
		+-----------------+

Is the above information ok? (y/N): y


Signing certificate...
```

## Deleting request, moving client keys and installing rsyslog-gnutls 

`sudo rm *-request.pem`

`sudo -u root scp -i ~/.ssh/id_rsa CA.pem CLIENT-* root@172.28.171.52:/etc/ssl/rsyslog/`

`sudo apt isntall -y rsyslog-gnutls (on both server and client)`

## Server config

```
sudoedit /etc/rsyslog.cong

# Add
# Listen for TCP
$ModLoad imtcp
# Set gtls driver
$DefaultNetstreamDriver gtls
# Certs
$DefaultNetstreamDriverCAFile /etc/ssl/rsyslog/CA.pem
$DefaultNetstreamDriverCertFile /etc/ssl/rsyslog/SERVER-cert.pem
$DefaultNetstreamDriverKeyFile /etc/ssl/rsyslog/SERVER-key.pem
# Auth mode
$InputTCPServerStreamDriverAuthMode x509/name
# Only allow EXAMPLE.COM domain
$InputTCPServerStreamDriverPermittedPeer 172.28.171.52
# Only use TLS
$InputTCPServerStreamDriverMode 1 
# Listen on port 6514
# If you want to use other port configure selinux
$InputTCPServerRun 6514
```

`sudo service rsyslog restart`

Also added conf to separate incoming client logs to separate folders

```
## Split received logs into folders
$template TmplMsg, "/var/log/client_logs/%HOSTNAME%/%PROGRAMNAME%.log"
*.* action(type="omfile" dynaFile="TmplMsg")
```

## Client config

```
sudoedit /etc/rsyslog.conf

# Add
# Set gtls driver
$DefaultNetstreamDriver gtls
# Certs
$DefaultNetstreamDriverCAFile /etc/ssl/rsyslog/CA.pem
$DefaultNetstreamDriverCertFile /etc/ssl/rsyslog/CLIENT-cert.pem
$DefaultNetstreamDriverKeyFile /etc/ssl/rsyslog/CLIENT-key.pem
# Auth mode
$ActionSendStreamDriverAuthMode x509/name
# Only send log to SERVER.EXAMPLE.COM host
$ActionSendStreamDriverPermittedPeer 172.28.171.71
# Only use TLS
$ActionSendStreamDriverMode 1
# Forward everithing to SERVER.EXAMPLE.COM
# If you use hostnames instead of IP configure DNS or /etc/hosts
*.* @@172.28.171.71:6514
```

`sudo service rsyslog restart`

## Debugging

Got following error on server, and simiral on client

```
marras 08 14:17:55 testi rsyslogd[9219]: can not read file '/etc/ssl/rsyslog/SERVER-key.pem': 
Permission denied [v8.32.0 try http://www.rsyslog.com/e/2040 ]
```

Fixed with `sudo chmod 777 -R /etc/ssl/rsyslog/`

Next error on server

```
marras 08 14:20:37 testi rsyslogd[9264]: gnutls returned error on handshake: 
The TLS connection was non-properly terminated.  [v8.32.0 try http://www.rsyslog.com/e/2083 ]
```

According to https://stackoverflow.com/questions/32113065/gnutls-error-110-the-tls-connection-was-non-properly-terminated
this error is not concerning:
"That just means that the peer just closed the socket and did not do a proper TLS shutdown. 
Some broken clients or servers do this. Assuming that this message relates to a data transfer you can usually 
ignore this because the transfer was finished anyway, so no data got lost."
