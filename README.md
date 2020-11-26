# Setting Up TLS for Local Testing

A repo that setups TLS locally so you are able to have tls using `localhost` or `127.0.0.1` using Cloud Flares [cfssl](https://github.com/cloudflare/cfssl) tool

For a less manual approach use [mkcert](https://github.com/FiloSottile/mkcert)

## Generating the CA:

```bash
cfssl gencert -initca ca/config.json | cfssljson -bare ./certs/ca
```

## Add CA to Keychain 

### MAC
```bash
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain certs/ca.pem
```

### Debian

```bash
openssl x509 -outform der -in certs/ca.pem -out certs/ca.crt
sudo cp certs/ca.crt /usr/local/share/ca-certificate

sudo update-ca-certificates
```

## Generate Certificates for Localhost

```bash
cfssl gencert -ca=certs/ca.pem -ca-key=certs/ca-key.pem localhost/config.json | cfssljson -bare certs/localhost
```

All your certifcates should now be in the [certs](./certs) directory

## Testing

To keep things simple I have created a Caddyfile in [server](./server) directory, you will need to [install caddy](https://caddyserver.com/docs/download) before running these steps.

### To Run the Server
This server will use the localhost certs generated previously
```bash
caddy run -config server/Caddyfile
```

### Verify Certificates are Working

```bash
$ curl -v https://localhost
*   Trying ::1:443...
* Connected to localhost (::1) port 443 (#0)
* ALPN, offering http/1.1
* TLS 1.2 connection using TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
* Server certificate: localhost
* Server certificate: Spazzy Root CA
> GET / HTTP/1.1
> Host: localhost
> User-Agent: curl/7.71.1
> Accept: */*
>
* Mark bundle as not supporting multiuse
< HTTP/1.1 200 OK
< Server: Caddy
< Date: Wed, 25 Nov 2020 10:51:46 GMT
< Content-Length: 13
<
* Connection #0 to host localhost left intact
Hello, world!
```
As you can see above the certificates are valid


## Intermediate  CA's (Just for fun)

### Creating the Intermediate CA

```bash
cfssl gencert  -ca certs/ca.pem -ca-key certs/ca-key.pem intermediate/config.json | cfssljson -bare certs/intermediate
```

### Add Intermediate CA to Keychain 
You need to have both the intermediate and the root CA in your keychain

#### MAC
```bash
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain certs/intermediate.pem
```
#### Debian

```bash
openssl x509 -outform der -in certs/ca.pem -out certs/ca.crt
sudo cp certs/ca.crt /usr/local/share/ca-certificate

sudo update-ca-certificates
```

### Generate Certificates for Localhost with Intermediate CA

```bash
cfssl gencert -ca=certs/intermediate.pem -ca-key=certs/intermediate-key.pem localhost/config.json | cfssljson -bare certs/localhost
```

### To Run the Server
This server will use the localhost certs generated previously
```bash
caddy run -config server/Caddyfile
```

### Verify Certificates are Working

```bash
*   Trying ::1:443...
* Connected to localhost (::1) port 443 (#0)
* ALPN, offering http/1.1
* TLS 1.2 connection using TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
* Server certificate: localhost
* Server certificate: (LOCAL) CA
* Server certificate: (LOCAL) ROOT CA
> GET / HTTP/1.1
> Host: localhost
> User-Agent: curl/7.71.1
> Accept: */*
>
* Mark bundle as not supporting multiuse
< HTTP/1.1 200 OK
< Server: Caddy
< Date: Wed, 25 Nov 2020 11:52:01 GMT
< Content-Length: 13
<
* Connection #0 to host localhost left intact
Hello, world!
```
As you can see above the certificates are valid
