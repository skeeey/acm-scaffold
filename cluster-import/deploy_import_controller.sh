#!/bin/bash

ns=multicluster-engine

if [ "$1"x = "recover"x ]; then
    echo "recover ..."
    kubectl annotate mce multiclusterengine pause- --overwrite
    kubectl -n $ns delete -f managedcluster-import-controller-v2-test.yaml
    kubectl -n $ns scale deployment.v1.apps/managedcluster-import-controller-v2 --replicas=2
    kubectl -n $ns get pods -w
    exit 0
fi

if [ "$1"x = "restart"x ]; then
    echo "restart ..."
    kubectl delete -f managedcluster-import-controller-v2-test.yaml
    sleep 1
    kubectl apply -f managedcluster-import-controller-v2-test.yaml
    exit 0
fi

kubectl -n $ns get deploy managedcluster-import-controller-v2 -o yaml > managedcluster-import-controller-v2-test.yaml

echo ">>> replace the image in managedcluster-import-controller-v2-test.yaml"
read

kubectl annotate mce multiclusterengine pause=true --overwrite
kubectl -n $ns scale deployment.v1.apps/managedcluster-import-controller-v2 --replicas=0
kubectl -n $ns apply -f managedcluster-import-controller-v2-test.yaml

kubectl -n $ns get pods -w

echo ""
kubectl -n multicluster-engine get deploy managedcluster-import-controller-v2-test -ojsonpath='{.spec.template.spec.containers[0].image}'
echo ""