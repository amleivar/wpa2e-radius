# wpa2e-radius
Docker image to create a wpa2e with radius

# Create PKI, server key and n1 client key. All passwords are "password"

CA -> pki/ca.crt pki/dh.pem
Server -> pki/issued/server.crt pki/private/server.key
n1 -> pki/  pki/

```
cd EasyRSA-3.0.1/
mkdir -p pki/private
mkdir -p pki/reqs
./easyrsa gen-dh
./easyrsa build-ca
./easyrsa build-server-full server
./easyrsa build-client-full n1
```
