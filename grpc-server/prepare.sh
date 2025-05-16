#!/bin/bash

CURRENT_DIR="$(dirname "${BASH_SOURCE[0]}")"
PARENT_DIR="$(cd ../${CURRENT_DIR} && pwd)"
DEMO_DIR="$(cd ${CURRENT_DIR} && pwd)"

cluster_name="grpc-svr-demo"

# prepare demo cluster
kind delete cluster --name ${cluster_name}
kind create cluster --name ${cluster_name}

# load images
kind load docker-image quay.io/open-cluster-management/addon-manager --name ${cluster_name}
kind load docker-image quay.io/open-cluster-management/placement:latest --name ${cluster_name}
kind load docker-image quay.io/open-cluster-management/registration:latest --name ${cluster_name}
kind load docker-image quay.io/open-cluster-management/work:latest --name ${cluster_name}

# prepare kube bootstrap kubeconfig
cp ${HOME}/.kube/config ${DEMO_DIR}/config/bootstrap.kubeconfig
cluster_ip=$(kubectl get svc kubernetes -n default -o jsonpath="{.spec.clusterIP}")
kubectl --kubeconfig ${DEMO_DIR}/config/bootstrap.kubeconfig config set clusters.kind-${cluster_name}.server https://${cluster_ip}

# prepare namespace
kubectl create ns open-cluster-management
kubectl create ns open-cluster-management-hub
kubectl create ns open-cluster-management-agent
kubectl create ns open-cluster-management-agent-addon

# prepare certs
go run ${PARENT_DIR}/certs/gen/main.go --dns-names="cluster-manager-grpc-service.open-cluster-management-hub,localhost" --ip-addresses="${cluster_ip},127.0.0.1"

kubectl -n open-cluster-management-hub create secret generic grpc-secret \
    --from-file=ca.crt=$DEMO_DIR/self-certs/ca.crt \
    --from-file=ca.key=$DEMO_DIR/self-certs/ca.key \
    --from-file=server.crt=$DEMO_DIR/self-certs/server.crt \
    --from-file=server.key=$DEMO_DIR/self-certs/server.key

kubectl -n open-cluster-management-agent create secret generic bootstrap-secret \
    --from-file=kubeconfig=$DEMO_DIR/config/bootstrap.kubeconfig \
    --from-file=config.yaml=$DEMO_DIR/config/grpc-config.yaml \
    --from-file=ca.crt=$DEMO_DIR/self-certs/ca.crt \
    --from-file=client.crt=$DEMO_DIR/self-certs/client.crt \
    --from-file=client.key=$DEMO_DIR/self-certs/client.key

# prepare hub components
kubectl apply -k deploy/hub

