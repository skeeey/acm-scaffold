#!/bin/bash

if [ "$1"x = "force"x ]; then
    kubectl get managedclusters | grep -v NAME | awk '{print $1}' | xargs kubectl patch managedclusters -p '{"metadata":{"finalizers": []}}' --type=merge
fi

kubectl get managedclusters | grep test | awk '{print $1}' | xargs kubectl delete managedclusters 

kubectl delete ns -l cluster.open-cluster-management.io/managedCluster
