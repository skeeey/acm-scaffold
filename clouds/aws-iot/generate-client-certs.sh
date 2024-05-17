PWD="$(cd "$(dirname ${BASH_SOURCE[0]})" ; pwd -P)"
CERTS_DIR=$PWD/certs

mkdir -p ${CERTS_DIR}
chmod 700 ${CERTS_DIR}

clientID="maestro"
clientCertDir=${CERTS_DIR}/${clientID}

mkdir -p ${clientCertDir}

# prepare client certs
aws iot create-keys-and-certificate \
    --set-as-active \
    --certificate-pem-outfile "${clientCertDir}/${clientID}.crt" \
    --public-key-outfile "${clientCertDir}/${clientID}.public.key" \
    --private-key-outfile "${clientCertDir}/${clientID}.private.key"

chmod 644 ${clientCertDir}/*
chmod 600 ${clientCertDir}/${clientID}.private.key
