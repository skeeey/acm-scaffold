#!/bin/bash

set -e

server_host="$(cat server.host)"

KEY_PASS="$(cat keytool.pw)"
STORE_PASS="$(cat keytool.pw)"
CA_VALIDITY=365000
VALIDITY=36500
LOCAL_CLIENT_NAMES="dns:localhost,ip:127.0.0.1"
LOCAL_SERVER_NAMES="dns:${server_host},dns:localhost,dns:localhost.localdomain,dns:artemis.localtest.me,ip:127.0.0.1"

# Clean up existing files
# -----------------------
rm -f *.crt *.csr openssl-* *.jceks *.jks *.p12 *.pem *.pemcfg

# Create a key and self-signed certificate for the CA, to sign server certificate requests and use for trust:
# ----------------------------------------------------------------------------------------------------
keytool -storetype pkcs12 -keystore server-ca-keystore.p12 -storepass $STORE_PASS -keypass $KEY_PASS -alias server-ca -genkey -keyalg "RSA" -keysize 2048 -dname "CN=ActiveMQ Artemis Server Certification Authority, OU=Artemis, O=ActiveMQ" -validity $CA_VALIDITY -ext bc:c=ca:true
keytool -storetype pkcs12 -keystore server-ca-keystore.p12 -storepass $STORE_PASS -alias server-ca -exportcert -rfc > server-ca.crt
openssl pkcs12 -in server-ca-keystore.p12 -nodes -nocerts -out server-ca.pem -password pass:$STORE_PASS

# Create trust store with the server CA cert:
# -------------------------------------------------------
keytool -storetype pkcs12 -keystore server-ca-truststore.p12 -storepass $STORE_PASS -keypass $KEY_PASS -importcert -alias server-ca -file server-ca.crt -noprompt
keytool -importkeystore -srckeystore server-ca-truststore.p12 -destkeystore server-ca-truststore.jceks -srcstoretype pkcs12 -deststoretype jceks -srcstorepass securepass -deststorepass securepass
keytool -importkeystore -srckeystore server-ca-truststore.p12 -destkeystore server-ca-truststore.jks -srcstoretype pkcs12 -deststoretype jks -srcstorepass securepass -deststorepass securepass

# Create a key pair for the server, and sign it with the CA:
# ----------------------------------------------------------
keytool -storetype pkcs12 -keystore server-keystore.p12 -storepass $STORE_PASS -keypass $KEY_PASS -alias server -genkey -keyalg "RSA" -keysize 2048 -dname "CN=ActiveMQ Artemis Server, OU=Artemis, O=ActiveMQ, L=AMQ, S=AMQ, C=AMQ" -validity $VALIDITY -ext bc=ca:false -ext eku=sA -ext "san=dns:server.artemis.activemq,$LOCAL_SERVER_NAMES"

keytool -storetype pkcs12 -keystore server-keystore.p12 -storepass $STORE_PASS -alias server -certreq -file server.csr
keytool -storetype pkcs12 -keystore server-ca-keystore.p12 -storepass $STORE_PASS -alias server-ca -gencert -rfc -infile server.csr -outfile server.crt -validity $VALIDITY -ext bc=ca:false -ext eku=sA -ext "san=dns:server.artemis.activemq,$LOCAL_SERVER_NAMES"

keytool -storetype pkcs12 -keystore server-keystore.p12 -storepass $STORE_PASS -keypass $KEY_PASS -importcert -alias server-ca -file server-ca.crt -noprompt
keytool -storetype pkcs12 -keystore server-keystore.p12 -storepass $STORE_PASS -keypass $KEY_PASS -importcert -alias server -file server.crt

keytool -importkeystore -srckeystore server-keystore.p12 -destkeystore server-keystore.jceks -srcstoretype pkcs12 -deststoretype jceks -srcstorepass securepass -deststorepass securepass
keytool -importkeystore -srckeystore server-keystore.p12 -destkeystore server-keystore.jks -srcstoretype pkcs12 -deststoretype jks -srcstorepass securepass -deststorepass securepass

# Create a key and self-signed certificate for the CA, to sign client certificate requests and use for trust:
# ----------------------------------------------------------------------------------------------------
keytool -storetype pkcs12 -keystore client-ca-keystore.p12 -storepass $STORE_PASS -keypass $KEY_PASS -alias client-ca -genkey -keyalg "RSA" -keysize 2048 -dname "CN=ActiveMQ Artemis Client Certification Authority, OU=Artemis, O=ActiveMQ" -validity $CA_VALIDITY -ext bc:c=ca:true
keytool -storetype pkcs12 -keystore client-ca-keystore.p12 -storepass $STORE_PASS -alias client-ca -exportcert -rfc > client-ca.crt
openssl pkcs12 -in client-ca-keystore.p12 -nodes -nocerts -out client-ca.pem -password pass:$STORE_PASS

# Create trust store with the client CA cert:
# -------------------------------------------------------
keytool -storetype pkcs12 -keystore client-ca-truststore.p12 -storepass $STORE_PASS -keypass $KEY_PASS -importcert -alias client-ca -file client-ca.crt -noprompt
keytool -importkeystore -srckeystore client-ca-truststore.p12 -destkeystore client-ca-truststore.jceks -srcstoretype pkcs12 -deststoretype jceks -srcstorepass securepass -deststorepass securepass
keytool -importkeystore -srckeystore client-ca-truststore.p12 -destkeystore client-ca-truststore.jks -srcstoretype pkcs12 -deststoretype jks -srcstorepass securepass -deststorepass securepass

# Create a key pair for the client, and sign it with the CA:
# ----------------------------------------------------------
keytool -storetype pkcs12 -keystore client-keystore.p12 -storepass $STORE_PASS -keypass $KEY_PASS -alias client -genkey -keyalg "RSA" -keysize 2048 -dname "CN=ActiveMQ Artemis Client, OU=Artemis, O=ActiveMQ, L=AMQ, S=AMQ, C=AMQ" -validity $VALIDITY -ext bc=ca:false -ext eku=cA -ext "san=dns:client.artemis.activemq,$LOCAL_CLIENT_NAMES"

keytool -storetype pkcs12 -keystore client-keystore.p12 -storepass $STORE_PASS -alias client -certreq -file client.csr
keytool -storetype pkcs12 -keystore client-ca-keystore.p12 -storepass $STORE_PASS -alias client-ca -gencert -rfc -infile client.csr -outfile client.crt -validity $VALIDITY -ext bc=ca:false -ext eku=cA -ext "san=dns:client.artemis.activemq,$LOCAL_CLIENT_NAMES"

keytool -storetype pkcs12 -keystore client-keystore.p12 -storepass $STORE_PASS -keypass $KEY_PASS -importcert -alias client-ca -file client-ca.crt -noprompt
keytool -storetype pkcs12 -keystore client-keystore.p12 -storepass $STORE_PASS -keypass $KEY_PASS -importcert -alias client -file client.crt

keytool -importkeystore -srckeystore client-keystore.p12 -destkeystore client-keystore.jceks -srcstoretype pkcs12 -deststoretype jceks -srcstorepass securepass -deststorepass securepass
keytool -importkeystore -srckeystore client-keystore.p12 -destkeystore client-keystore.jks -srcstoretype pkcs12 -deststoretype jks -srcstorepass securepass -deststorepass securepass

# PEM versions
## separate private and public cred pem files combined for the keystore via prop
keytool -storetype pkcs12 -keystore server-ca-keystore.p12 -storepass $STORE_PASS -alias server-ca -exportcert -rfc > server-ca.crt
openssl pkcs12 -in client-keystore.p12 -out client-cert.pem -clcerts -nokeys -password pass:$STORE_PASS
openssl pkcs12 -in client-keystore.p12 -out client-key.pem -nocerts -nodes -password pass:$STORE_PASS


# Clean up working files
# -----------------------
rm -f *.crt *.csr openssl-*
