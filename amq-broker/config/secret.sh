#!/bin/bash

kubectl -n amq-broker delete secret my-tls-secret --ignore-not-found
kubectl -n amq-broker create secret generic mqtt-tls-secret \
    --from-file=broker.ks=server-keystore.jks \
    --from-file=client.ts=client-ca-truststore.jks \
    --from-file=keyStorePassword=keytool.pw \
    --from-file=trustStorePassword=keytool.pw

kubectl -n amq-broker delete secret mqtt-jaas-config --ignore-not-found
cat <<EOF | kubectl -n amq-broker create -f -
apiVersion: v1
kind: Secret
metadata:
  name: mqtt-jaas-config
type: Opaque
stringData:
  login.config: |
    activemq {
        // ensure the operator can connect to the broker by referencing the existing properties config
        org.apache.activemq.artemis.spi.core.security.jaas.PropertiesLoginModule sufficient
            org.apache.activemq.jaas.properties.user="artemis-users.properties"
            org.apache.activemq.jaas.properties.role="artemis-roles.properties"
            baseDir="/home/jboss/amq-broker/etc";
        org.apache.activemq.artemis.spi.core.security.jaas.TextFileCertificateLoginModule required
          debug=true
          reload=true
          org.apache.activemq.jaas.textfiledn.user="users.properties"
          org.apache.activemq.jaas.textfiledn.role="roles.properties";
    };
  roles.properties: |
    group1=client1
  users.properties: |
    client1=CN=ActiveMQ Artemis Client, OU=Artemis, O=ActiveMQ, L=AMQ, S=AMQ, C=AMQ
EOF
