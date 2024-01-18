#!/bin/bash

ns=multicluster-engine

if [ "$1"x = "recover"x ]; then
    echo "recover ..."
    kubectl annotate mce multiclusterengine pause- --overwrite
    kubectl -n $ns delete -f managedcluster-import-controller-v2-test.yaml
    kubectl -n $ns scale deployment.v1.apps/managedcluster-import-controller-v2 --replicas=2
    kubectl -n $ns get pods -l app=managedcluster-import-controller-v2 -w
    exit 0
fi

if [ "$1"x = "restart"x ]; then
    echo "restart ..."
    kubectl delete -f managedcluster-import-controller-v2-test.yaml
    sleep 1
    kubectl apply -f managedcluster-import-controller-v2-test.yaml
    kubectl -n $ns get pods -l app=managedcluster-import-controller-v2-test -w
    exit 0
fi

kubectl -n $ns get deploy managedcluster-import-controller-v2 -o yaml > managedcluster-import-controller-v2-test.yaml

kubectl annotate mce multiclusterengine pause=true --overwrite
kubectl -n $ns scale deployment.v1.apps/managedcluster-import-controller-v2 --replicas=0

echo ">>> 1. rename 'managedcluster-import-controller-v2' to 'managedcluster-import-controller-v2-test' in managedcluster-import-controller-v2-test.yaml"
echo ">>> 2. replace the image in managedcluster-import-controller-v2-test.yaml"
read

kubectl -n $ns apply -f managedcluster-import-controller-v2-test.yaml
kubectl -n $ns get pods -l app=managedcluster-import-controller-v2-test -w
echo ""
kubectl -n multicluster-engine get deploy managedcluster-import-controller-v2-test -ojsonpath='{.spec.template.spec.containers[0].image}'
echo ""