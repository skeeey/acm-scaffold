#!/bin/bash

rm -f *.pem *.csr *.json

cfssl gencert -initca cfsslconfig/ca.json | cfssljson -bare ca

cat << EOF > cert.json
{
  "CN": "cluser1",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
     {
        "O": "ACM",
        "OU": "ACM Dev"
      }
  ],
  "hosts": [
    "localhost"
  ]
}
EOF

cfssl gencert -ca ca.pem -ca-key ca-key.pem -config cfsslconfig/profile.json -profile=peer cert.json | cfssljson -bare peer
# cfssl gencert -ca ca.pem -ca-key ca-key.pem -config cfsslconfig/profile.json -profile=server cert.json | cfssljson -bare server
# cfssl gencert -ca ca.pem -ca-key ca-key.pem -config cfsslconfig/profile.json -profile=client cert.json | cfssljson -bare client


kubectl -n amq-broker create secret generic my-tls-secret \
    --from-file=broker.ks=broker.ks \
    --from-file=client.ts=broker.ks \
    --from-literal=keyStorePassword=testtest \
    --from-literal=trustStorePassword=testest