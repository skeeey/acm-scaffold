#!/bin/bash

kubectl patch MultiClusterHub multiclusterhub -n open-cluster-management --type=json -p='[{"op": "add", "path": "/spec/overrides/components/-","value":{"name":"cluster-backup","enabled":true}}]'

kubectl delete secret cloud-credentials --namespace open-cluster-management-backup --ignore-not-found
kubectl create secret generic cloud-credentials --namespace open-cluster-management-backup --from-file cloud=/home/centos/.aws/default-credentials

kubectl apply -f dpa.yaml
