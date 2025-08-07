#!/bin/bash

CURRENT_DIR="$(dirname "${BASH_SOURCE[0]}")"
PARENT_DIR="$(cd ../${CURRENT_DIR} && pwd)"
DEMO_DIR="$(cd ${CURRENT_DIR} && pwd)"

cluster_name="kind"

# prepare kube bootstrap kubeconfig
cp ${HOME}/.kube/config ${DEMO_DIR}/config/bootstrap.kubeconfig
cluster_ip=$(kubectl get svc kubernetes -n default -o jsonpath="{.spec.clusterIP}")
kubectl --kubeconfig ${DEMO_DIR}/config/bootstrap.kubeconfig config set clusters.kind-${cluster_name}.server https://${cluster_ip}

# prepare namespace
kubectl create ns open-cluster-management-agent
kubectl create ns open-cluster-management-agent-addon

# prepare certs
rm -rf $DEMO_DIR/self-certs
mkdir -p $DEMO_DIR/self-certs

kubectl apply -f $DEMO_DIR/deploy/bootstrap

kubectl -n open-cluster-management-hub get cm ca-bundle-configmap -ojsonpath='{.data.ca-bundle\.crt}' > $DEMO_DIR/self-certs/ca.crt

kubectl -n open-cluster-management-hub get secrets signer-secret -ojsonpath="{.data.tls\.crt}" | base64 -d > $DEMO_DIR/self-certs/signer.crt
kubectl -n open-cluster-management-hub get secrets signer-secret -ojsonpath="{.data.tls\.key}" | base64 -d > $DEMO_DIR/self-certs/signer.key

openssl genpkey -algorithm RSA -out $DEMO_DIR/self-certs/client.key -pkeyopt rsa_keygen_bits:2048
openssl req -new -key $DEMO_DIR/self-certs/client.key -out $DEMO_DIR/self-certs/client.csr -subj "/CN=grpc-client"
openssl x509 -req \
  -in $DEMO_DIR/self-certs/client.csr \
  -CA $DEMO_DIR/self-certs/signer.crt \
  -CAkey $DEMO_DIR/self-certs/signer.key \
  -CAcreateserial \
  -out $DEMO_DIR/self-certs/client.crt \
  -days 365 \
  -sha256 \
  -extfile $DEMO_DIR/config/ext.conf

kubectl -n open-cluster-management-agent delete secret bootstrap-hub-kubeconfig --ignore-not-found
kubectl -n open-cluster-management-agent create secret generic bootstrap-hub-kubeconfig \
    --from-file=kubeconfig=$DEMO_DIR/config/bootstrap.kubeconfig \
    --from-file=config.yaml=$DEMO_DIR/config/grpc-config-incluster.yaml \
    --from-file=ca.crt=$DEMO_DIR/self-certs/ca.crt \
    --from-file=client.crt=$DEMO_DIR/self-certs/client.crt \
    --from-file=client.key=$DEMO_DIR/self-certs/client.key
