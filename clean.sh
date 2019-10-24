# /usr/local/bin/bash

echo "#####################################################"
echo "cleaning directories"
echo "#####################################################"
rm -rf intermediate/intermediate-ca*
rm -rf spazzy.dev/spazzy.dev*

echo "#####################################################"
echo "generating certs..."
echo "#####################################################"

cfssl gencert \
-ca=ca/ca.pem \
-ca-key=ca/ca-key.pem \
-config intermediate/profiles.json  \
-profile intermediate-ca \
intermediate/config.json | cfssljson -bare intermediate/intermediate-ca

cfssl gencert \
-ca=intermediate/intermediate-ca.pem \
-ca-key=intermediate/intermediate-ca-key.pem \
-config intermediate/profiles.json \
-profile server \
spazzy.dev/config.json | cfssljson -bare spazzy.dev/spazzy.dev


echo "#####################################################"
echo "Adding cert to key chain"
echo "#####################################################"
sudo security add-trusted-cert -r trustRoot -k "${HOME}/Library/Keychains/login.keychain" intermediate/intermediate-ca.pem

echo "#####################################################"
echo "copying keys to server"
echo "#####################################################"
cp spazzy.dev/spazzy.dev-key.pem server/certs/
cp spazzy.dev/spazzy.dev.pem server/certs/
