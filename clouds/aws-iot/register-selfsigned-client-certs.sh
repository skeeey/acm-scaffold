PWD="$(cd "$(dirname ${BASH_SOURCE[0]})" ; pwd -P)"
CERTS_DIR=$PWD/certs

mkdir -p certs
chmod 700 certs

rootCA=$CERTS_DIR/root_ca.pem
rootKey=$CERTS_DIR/root_ca.key
clientID="cluster1"
clientCertDir=${CERTS_DIR}/${clientID}
csrSub="/C=US/O=OCM/CN=${clientID}"

mkdir -p ${clientCertDir}

# create a client certificate with self signed CA
openssl genrsa -out ${clientCertDir}/${clientID}.key 2048
openssl req -new -key ${clientCertDir}/${clientID}.key -subj ${csrSub} -out ${clientCertDir}/${clientID}.csr
openssl x509 -req -sha256 -days 365 -CAcreateserial -CA ${rootCA} -CAkey ${rootKey} \
    -in ${clientCertDir}/${clientID}.csr \
    -out ${clientCertDir}/${clientID}.crt

aws iot register-certificate --set-as-active \
    --certificate-pem file://${clientCertDir}/${clientID}.crt \
    --ca-certificate-pem file://${rootCA}

# ARN: Amazon Resource Name
# https://docs.aws.amazon.com/IAM/latest/UserGuide/reference-arns.html
# arn:partition:service:region:account-id:resource-id
# arn:partition:service:region:account-id:resource-type/resource-id
# arn:partition:service:region:account-id:resource-type:resource-id
