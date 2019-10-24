# /usr/local/bin/bash

echo "#####################################################"
echo "cleaning directories"
echo "#####################################################"
rm -rf intermediate/intermediate-ca*

echo "#####################################################"
echo "generating certs..."
echo "#####################################################"

cfssl gencert \
-ca=ca/ca.pem \
-ca-key=ca/ca-key.pem \
-config config/profiles.json  \
-profile intermediate-ca \
intermediate/config.json | cfssljson -bare intermediate/intermediate-ca

echo "#####################################################"
echo "Adding cert to key chain"
echo "#####################################################"
sudo security add-trusted-cert -r trustRoot -k "${HOME}/Library/Keychains/login.keychain" intermediate/intermediate-ca.pem

