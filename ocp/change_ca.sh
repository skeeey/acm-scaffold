#!/bin/bash

api_server_url="api.local"
subjectName="subjectAltName = DNS:${api_server_url}"
patch="'{\"spec\":{\"servingCerts\":{\"namedCertificates\":[{\"names\": [\"${api_server}\"],\"servingCertificate\":{\"name\":\"skeeeyca\"}}]}}}'"

/usr/bin/openssl11 req -nodes -x509 -newkey rsa:4096 -days 365 \
    -keyout key.pem -out cert.pem \
    -addext "${subjectName}" \
    -subj "/C=CN/ST=AA/L=AA/O=OCM/CN=OCM"

oc delete secret skeeeyca -n openshift-config
oc create secret tls skeeeyca --cert=cert.pem --key=key.pem -n openshift-config

oc patch apiserver cluster --type=merge -p ${patch}

oc get clusteroperators kube-apiserver -w
