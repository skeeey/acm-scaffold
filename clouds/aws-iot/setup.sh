#!/usr/bin/env bash

PWD="$(cd "$(dirname ${BASH_SOURCE[0]})" ; pwd -P)"
CERTS_DIR=$PWD/certs
POLICIES_DIR=$PWD/policies

region="us-east-1"

source_id="maestro"
consumer_id="cluster1"

source_cert_dir=${CERTS_DIR}/source
consumer_cert_dir=${CERTS_DIR}/consumers

mkdir -p ${source_cert_dir}
mkdir -p ${consumer_cert_dir}

# Get AWS IoT broker endpoint
host=$(aws iot describe-endpoint --endpoint-type iot:Data-ATS | jq -r '.endpointAddress')
port=8883

echo "AWS IOT broke: $host:8883"

# Download AWS IoT broker severing CA
curl -o ${CERTS_DIR}/AmazonRootCA1.pem https://www.amazontrust.com/repository/AmazonRootCA1.pem
chmod 600 ${CERTS_DIR}/AmazonRootCA1.pem

# Generated clients certs for AWS IoT clients
maestro_cert_arn=$(aws iot create-keys-and-certificate \
    --set-as-active \
    --certificate-pem-outfile "${source_cert_dir}/${source_id}.crt" \
    --public-key-outfile "${source_cert_dir}/${source_id}.public.key" \
    --private-key-outfile "${source_cert_dir}/${source_id}.private.key" | jq -r '.certificateArn')
echo "mastro arn: $maestro_cert_arn"

consumer_cert_arn=$(aws iot create-keys-and-certificate \
    --set-as-active \
    --certificate-pem-outfile "${consumer_cert_dir}/${consumer_id}.crt" \
    --public-key-outfile "${consumer_cert_dir}/${consumer_id}.public.key" \
    --private-key-outfile "${consumer_cert_dir}/${consumer_id}.private.key" | jq -r '.certificateArn')
echo "consumer arn: $consumer_cert_arn"

chmod 600 ${source_cert_dir}/*
chmod 600 ${consumer_cert_dir}/*

# Attach policies for AWS IoT clients
aws_account=$(aws sts get-caller-identity --output json | jq -r '.Account')

cat $POLICIES_DIR/source.template.json | sed "s/{region}/${region}/g" | sed "s/{aws_account}/${aws_account}/g" > $POLICIES_DIR/source.json
cat $POLICIES_DIR/consumer.template.json | sed "s/{region}/${region}/g" | sed "s/{aws_account}/${aws_account}/g" | sed "s/{consumer_id}/${consumer_id}/g" > $POLICIES_DIR/consumer.json

# policy_name=$(aws iot create-policy --policy-name ${source_id} --policy-document "file://${POLICIES_DIR}/source.json" | jq -r '.policyName')
aws iot attach-policy --policy-name ${source_id} --target ${maestro_cert_arn}
echo "policy $policy_name is created"

# policy_name=$(aws iot create-policy --policy-name ${consumer_id} --policy-document "file://${POLICIES_DIR}/consumer.json" | jq -r '.policyName')
aws iot attach-policy --policy-name ${consumer_id} --target ${consumer_cert_arn}
echo "policy $policy_name is created"

kubectl -n maestro delete secrets mqtt-creds --ignore-not-found
kubectl -n maestro create secret generic mqtt-creds \
    --from-file=ca.crt="${CERTS_DIR}/AmazonRootCA1.pem" \
    --from-file=client.crt="${source_cert_dir}/maestro.crt" \
    --from-file=client.key="${source_cert_dir}/maestro.private.key"
cat << EOF | kubectl -n maestro apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: maestro-mqtt
stringData:
  config.yaml: |
    brokerHost: ${host}:${port}
    caFile: /secrets/mqtt-creds/ca.crt
    clientCertFile: /secrets/mqtt-creds/client.crt
    clientKeyFile: /secrets/mqtt-creds/client.key
    topics:
      sourceEvents: sources/maestro/consumers/+/sourceevents
      agentEvents: \$share/statussubscribers/sources/maestro/consumers/+/agentevents
EOF

kubectl -n maestro-agent delete secrets maestro-agent-mqtt-creds --ignore-not-found
kubectl -n maestro-agent create secret generic maestro-agent-mqtt-creds \
    --from-file=ca.crt="${CERTS_DIR}/AmazonRootCA1.pem" \
    --from-file=client.crt="${consumer_cert_dir}/cluster1.crt" \
    --from-file=client.key="${consumer_cert_dir}/cluster1.private.key"
