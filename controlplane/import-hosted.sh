#!/bin/bash

kubectl -n multicluster-controlplane get secrets multicluster-controlplane-kubeconfig -ojsonpath='{.data.kubeconfig}' | base64 -d > multicluster-controlplane.kubeconfig

NUMBER=1
for i in $(seq 1 "${NUMBER}"); do
  CLUSTER_NAME=hosted-cluster$i

  kubectl --kubeconfig multicluster-controlplane.kubeconfig create namespace $CLUSTER_NAME
  kubectl --kubeconfig multicluster-controlplane.kubeconfig -n $CLUSTER_NAME create secret generic managedcluster-kubeconfig --from-file kubeconfig=/home/centos/clusters/aws/cluster2-admin.kubeconfig
  cat <<EOF | kubectl --kubeconfig multicluster-controlplane.kubeconfig apply -f -
apiVersion: operator.open-cluster-management.io/v1
kind: Klusterlet
metadata:
  name: $CLUSTER_NAME
spec:
  deployOption:
    mode: Hosted
EOF
done
