#!/usr/bin/env bash

PWD="$(cd "$(dirname ${BASH_SOURCE[0]})" ; pwd -P)"
CERTS_DIR=$PWD/certs

mkdir -p ${CERTS_DIR}
chmod 700 ${CERTS_DIR}

curl -o ${CERTS_DIR}/AmazonRootCA1.pem https://www.amazontrust.com/repository/AmazonRootCA1.pem
chmod 644 ${CERTS_DIR}/AmazonRootCA1.pem
