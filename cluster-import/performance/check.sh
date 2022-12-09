#!/bin/bash

kubectl get ns | grep test | wc -l

kubectl get managedclusters

if [ "$1"x = "log"x ]; then
    kubectl -n multicluster-engine logs -f -l app=managedcluster-import-controller-v2-test --tail=-1
fi
