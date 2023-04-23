#!/bin/bash

hosted_cluster_name="hosted-test"
hosted_kubeconfig="/home/centos/clusters/aws/cluster2.kubeconfig"

# prepare managed cluster kubeconfig secret
kubectl delete namespace $hosted_cluster_name --ignore-not-found --wait
kubectl create namespace $hosted_cluster_name


kubectl -n $hosted_cluster_name create secret generic managedcluster-kubeconfig --from-file kubeconfig=$hosted_kubeconfig

# apply hosted klusterlet
cat <<EOF | kubectl apply -f -
apiVersion: operator.open-cluster-management.io/v1
kind: Klusterlet
metadata:
  name: $hosted_cluster_name
spec:
  deployOption:
    mode: Hosted
EOF
