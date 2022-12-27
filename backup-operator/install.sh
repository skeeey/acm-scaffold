#!/bin/bash
CURRENT_DIR="$(dirname "${BASH_SOURCE[0]}")"
PARENT_DIR="$(cd ../${CURRENT_DIR} && pwd)"

source "${PARENT_DIR}"/utils

kubectl patch MultiClusterHub multiclusterhub -n open-cluster-management --type=json -p='[{"op": "add", "path": "/spec/overrides/components/-","value":{"name":"cluster-backup","enabled":true}}]'

wait_command "kubectl -n open-cluster-management-backup get deploy openshift-adp-controller-manager"
wait_command "kubectl -n open-cluster-management-backup get deploy cluster-backup-chart-clusterbackup"

kubectl -n open-cluster-management-backup rollout status deploy openshift-adp-controller-manager --timeout=120s
kubectl -n open-cluster-management-backup rollout status deploy cluster-backup-chart-clusterbackup --timeout=120s

kubectl -n open-cluster-management-backup delete secret cloud-credentials --ignore-not-found
kubectl -n open-cluster-management-backup create secret generic cloud-credentials --from-file cloud=${HOME}/.aws/default-credentials

kubectl apply -f dpa.yaml

kubectl -n open-cluster-management-backup get dataprotectionapplication.oadp.openshift.io/dpa -ojsonpath='{.status.conditions}' -w
