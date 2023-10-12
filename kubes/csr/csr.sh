#!/bin/bash

#go install github.com/cloudflare/cfssl/cmd/...@latest

cat <<EOF | cfssl genkey - | cfssljson -bare server
{
  "hosts": [
    "my-svc.my-namespace.svc.cluster.local",
    "10.0.34.2"
  ],
  "CN": "my-svc",
  "key": {
    "algo": "ecdsa",
    "size": 256
  },
  "names": [
    {
      "C": "CN",
      "ST": "Shaaxi",
      "L": "Xian",
      "O": "test",
      "OU": "test"
    }
  ]
}
EOF

# kubernetes.io/kube-apiserver-client
cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: my-svc
spec:
  request: $(cat server.csr | base64 | tr -d '\n')
  signerName: test.io/test
  usages:
  - digital signature
  - key encipherment
  - server auth
EOF
