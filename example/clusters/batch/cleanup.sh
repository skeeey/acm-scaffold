#!/bin/bash

if [ "$1"x = "force"x ]; then
    kubectl get managedclusters -l perftest.open-cluster-management.io/managedcluster | grep -v NAME | awk '{print $1}' | xargs kubectl patch managedclusters -p '{"metadata":{"finalizers": []}}' --type=merge
fi

kubectl delete managedclusters -l perftest.open-cluster-management.io/managedcluster

kubectl delete ns -l cluster.open-cluster-management.io/managedCluster
