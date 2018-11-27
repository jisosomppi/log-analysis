## OpenSSL key creation
echo "Enter a strong password for your root CA:"
#stty -echo
read ssl_pass
#stty echo

# Create OpenSSL keys for Nginx
echo "Generating OpenSSL keys for Nginx..."
# Calculate Diffie-Hellman parameters for stronger encryption
openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048 2> /dev/null
# Create root CA key
openssl genrsa -des3 -out localCA.key -passout pass:$ssl_pass 2048 
# Create root CA certificate
openssl req -x509 -new -nodes -key localCA.key -sha256 -days 1825 -out localCA.pem -passin pass:$ssl_pass -subj "/C=FI/ST=Uusimaa/L=Helsinki/O=Haaga-Helia/OU=Logserver/CN=logserver.local"
openssl x509 -in localCA.pem -inform PEM -out localCA.crt
# Create a new key for the log server
openssl genrsa -out logserver.local.key 2048
# Make a certificate signature request (CSR)
openssl req -new -key logserver.local.key -out logserver.local.csr -subj "/C=FI/ST=Uusimaa/L=Helsinki/O=Haaga-Helia/OU=Logserver/CN=logserver.local"

# Create ext file for additional certificate information (alternative names)
echo -e "authorityKeyIdentifier=keyid,issuer\n\
basicConstraints=CA:FALSE\n\
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment\n\
subjectAltName = @alt_names\n\n\
[alt_names]\n\
DNS.1 = logserver.local\n\
DNS.2 = http://logserver.local\n\
DNS.3 = https://logserver.local" >> logserver.local.ext

# Sign the CSR
openssl x509 -req -in logserver.local.csr -CA localCA.pem -CAkey localCA.key -CAcreateserial -out logserver.local.crt -days 1825 -sha256 -extfile logserver.local.ext -passin pass:$ssl_pass

# Convert certificate into PKCS12 for Firefox import
# CURRENTLY BROKEN
# openssl pkcs12 -export -out logserver.local.pfx -inkey logserver.local.key -in logserver.local.crt -certfile localCA.crt

## Copy certificates to /etc/ssl
#cp logserver.local.crt /etc/ssl/certs/
#cp logserver.local.key /etc/ssl/private/

# Reformat key for firefox & enter into database
#openssl pkcs12 -export -out localCA.pfx -inkey localCA.key -in localCA.crt -passin $ssl_pass -passout pass:$ssl_pass
#pk12util -i localCA.pfx -d .mozilla/firefox/rbyzigek.default/ -W $ssl_pass
