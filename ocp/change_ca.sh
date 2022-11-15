#!/bin/bash

api_server_url=$(cat api_server_url)
echo "$api_server_url"
# subjectName="subjectAltName = DNS:${api_server_url}"
# /usr/bin/openssl11 req -nodes -x509 -newkey rsa:4096 -days 365 \
#     -keyout key.pem -out cert.pem \
#     -addext "${subjectName}" \
#     -subj "/C=CN/ST=AA/L=AA/O=OCM/CN=OCM"

patch="'{\"spec\":{\"servingCerts\":{\"namedCertificates\":[{\"names\":[\"${api_server_url}\"],\"servingCertificate\":{\"name\":\"skeeeyca\"}}]}}}'"


echo $patch
oc delete secret skeeeyca -n openshift-config --ignore-not-found
oc create secret tls skeeeyca --cert=cert.pem --key=key.pem -n openshift-config

oc patch apiserver cluster --type=merge -p ${patch}

oc get clusteroperators kube-apiserver -w
