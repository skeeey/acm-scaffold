#!/bin/bash

retry="5"

cluster="$1"

server=""
token=""

kubeconfig=""

#labels: "cluster.open-cluster-management.io/restore-auto-import-secret": "true"

kubectl -n $cluster delete secret auto-import-secret --ignore-not-found

if [ -n "$server" ]; then
    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: auto-import-secret
  namespace: "$cluster"
  annotations:
    "managedcluster-import-controller.open-cluster-management.io/keeping-auto-import-secret": "true"
type: Opaque
stringData:
  autoImportRetry: "${retry}"
  server: "${server}"
  token: "${token}"
EOF
    exit $?
fi



if [ -n "$kubeconfig" ]; then
    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: auto-import-secret
  namespace: "$cluster"
  annotations:
    "managedcluster-import-controller.open-cluster-management.io/keeping-auto-import-secret": "true"
type: Opaque
stringData:
  autoImportRetry: "${retry}"
  kubeconfig: "${kubeconfig}"
EOF
    exit $?
fi
