#!/bin/bash

# Create directories if they don't exist
mkdir -p certificates

# Set default values
DAYS=3650  # 10 years
KEY_SIZE=4096
COUNTRY="US"
STATE="State"
LOCALITY="City"
ORGANIZATION="OpenTAKServer"
ORGANIZATIONAL_UNIT="Development"
COMMON_NAME="opentakserver.local"
EMAIL="opentakserver@gmail.com"

# Generate CA private key and certificate
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:$KEY_SIZE -out certificates/ca.key

openssl req -x509 -new -nodes \
    -key certificates/ca.key \
    -sha256 -days $DAYS \
    -out certificates/ca.pem \
    -subj "/C=$COUNTRY/ST=$STATE/L=$LOCALITY/O=$ORGANIZATION/OU=$ORGANIZATIONAL_UNIT/CN=$COMMON_NAME/emailAddress=$EMAIL"

# Generate server private key
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:$KEY_SIZE -out certificates/key.pem

# Generate server CSR
openssl req -new \
    -key certificates/key.pem \
    -out certificates/server.csr \
    -subj "/C=$COUNTRY/ST=$STATE/L=$LOCALITY/O=$ORGANIZATION/OU=$ORGANIZATIONAL_UNIT/CN=$COMMON_NAME/emailAddress=$EMAIL"

# Generate server certificate
openssl x509 -req \
    -in certificates/server.csr \
    -CA certificates/ca.pem \
    -CAkey certificates/ca.key \
    -CAcreateserial \
    -out certificates/cert.pem \
    -days $DAYS \
    -sha256 \
    -extfile <(printf "subjectAltName=DNS:$COMMON_NAME,DNS:localhost,IP:127.0.0.1")

# Generate client certificate and key
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:$KEY_SIZE -out certificates/client.key

openssl req -new \
    -key certificates/client.key \
    -out certificates/client.csr \
    -subj "/C=$COUNTRY/ST=$STATE/L=$LOCALITY/O=$ORGANIZATION/OU=Client/CN=client.$COMMON_NAME/emailAddress=$EMAIL"

openssl x509 -req \
    -in certificates/client.csr \
    -CA certificates/ca.pem \
    -CAkey certificates/ca.key \
    -CAcreateserial \
    -out certificates/client.pem \
    -days $DAYS \
    -sha256

# Generate P12 file for client
openssl pkcs12 -export \
    -out certificates/client.p12 \
    -inkey certificates/client.key \
    -in certificates/client.pem \
    -certfile certificates/ca.pem \
    -passout pass:atakatak

# Clean up CSR files
rm certificates/*.csr

# Set permissions
chmod 600 certificates/*.key certificates/*.pem certificates/*.p12

# Create hash symlinks for CA certificate
HASH=$(openssl x509 -hash -noout -in certificates/ca.pem)
cd certificates && ln -sf ca.pem $HASH.0 && cd ..

echo "Generated certificates in ./certificates:"
echo "- ca.pem: Certificate Authority certificate"
echo "- ca.key: Certificate Authority private key"
echo "- cert.pem: Server certificate"
echo "- key.pem: Server private key"
echo "- client.pem: Client certificate"
echo "- client.key: Client private key"
echo "- client.p12: Client PKCS#12 bundle (password: atakatak)"