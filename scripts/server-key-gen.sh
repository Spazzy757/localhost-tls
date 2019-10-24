# /usr/local/bin/bash

server=$1
if [ -z ${server} ]
then
    echo ERROR: host not provided!
    exit 1 # terminate and indicate error
fi

mkdir -p ${server}/
cat  <<- EOF > ${server}/config.json
{
  "CN": "${server}",
	"key": {
	       "algo": "rsa",
		     "size": 2048
	},
  "hosts": [
           "${server}",
           "127.0.0.1"
    ]
}
EOF


echo "#####################################################"
echo "cleaning directories"
echo "#####################################################"
rm -rf ${server}/${server}*

echo "#####################################################"
echo "generating certs in dir ${server}/..."
echo "#####################################################"

cfssl gencert \
      -ca=intermediate/intermediate-ca.pem \
      -ca-key=intermediate/intermediate-ca-key.pem \
      -config config/profiles.json \
      -profile server \
      ${server}/config.json | cfssljson -bare ${server}/${server}

