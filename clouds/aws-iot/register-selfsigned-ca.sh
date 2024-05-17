#!/usr/bin/env bash

PWD="$(cd "$(dirname ${BASH_SOURCE[0]})" ; pwd -P)"
CERTS_DIR=$PWD/certs

mkdir -p certs

chmod 700 certs

# TODO
# A CA certificate can be registered in DEFAULT mode by only one account in a Region.
# A CA certificate can be registered in SNI_ONLY mode by multiple accounts in a Region (TODO).

# get a registration code from AWS IoT
registrationCode=$(aws iot get-registration-code | jq -r '.registrationCode')
csrSub="/C=US/O=OCM/CN=${registrationCode}"

# generate ca
openssl genrsa -out $CERTS_DIR/root_ca.key 2048
openssl req -x509 -new -nodes -subj /C=US/O=OCM/CN=ocm-root-ca \
    -key $CERTS_DIR/root_ca.key \
    -sha256 -days 1024 \
    -out $CERTS_DIR/root_ca.pem

# generate verification csr
openssl genrsa -out $CERTS_DIR/verification_cert_key.key 2048
openssl req -new -key $CERTS_DIR/verification_cert_key.key -subj ${csrSub} -out $CERTS_DIR/verification_cert.csr

# generate verification cert
openssl x509 -req -CAcreateserial -days 365 -sha256 \
    -in $CERTS_DIR/verification_cert.csr \
    -CA $CERTS_DIR/root_ca.pem \
    -CAkey $CERTS_DIR/root_ca.key \
    -out $CERTS_DIR/verification_cert.pem

# register the CA certificate with AWS IoT
aws iot register-ca-certificate \
    --ca-certificate file://$CERTS_DIR/root_ca.pem \
    --verification-cert file://$CERTS_DIR/verification_cert.pem

# activate the CA certificate
certificateId=""
aws iot update-ca-certificate --certificate-id ${certificateId} --new-status ACTIVE
