#!/bin/bash

kubectl delete namespaces open-cluster-management-agent open-cluster-management-agent-addon --wait=false
kubectl get crds | grep open-cluster-management.io | awk '{print $1}' | xargs oc delete crds --wait=false
kubectl get crds | grep open-cluster-management.io | awk '{print $1}' | xargs oc patch crds --type=merge -p '{"metadata":{"finalizers": []}}'
