#!/bin/bash

echo "#### get klusterlets"
kubectl get crds klusterlets.operator.open-cluster-management.io
kubectl get klusterlets klusterlet

echo "#### show agent namespaces"
kubectl get ns open-cluster-management-agent
kubectl get ns open-cluster-management-agent-addon

echo "#### show pods"
kubectl -n open-cluster-management-agent get pods
kubectl -n open-cluster-management-agent-addon get pods

kubectl get appliedmanifestworks.work.open-cluster-management.io --all-namespaces
