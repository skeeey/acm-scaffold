#!/bin/bash

if [ "$1"x = "recover"x ]; then
    echo "recover ..."
    kubectl annotate mce multiclusterengine pause- --overwrite
    kubectl -n open-cluster-management annotate mch multiclusterhub mch-pause- --overwrite

    kubectl -n multicluster-engine delete -f ocm-controller-test.yaml
    kubectl -n open-cluster-management delete -f klusterlet-addon-controller-v2-test.yaml

    kubectl -n multicluster-engine scale deployment.v1.apps/ocm-controller --replicas=2
    kubectl -n open-cluster-management scale deployment.v1.apps/managedcluster-import-controller-v2 --replicas=2
     
    exit 0
fi

kubectl annotate mce multiclusterengine pause=true --overwrite
kubectl -n open-cluster-management annotate mch multiclusterhub mch-pause=true --overwrite

kubectl -n multicluster-engine scale deployment.v1.apps/ocm-controller --replicas=0
kubectl -n open-cluster-management scale deployment.v1.apps/klusterlet-addon-controller-v2 --replicas=0

kubectl -n multicluster-engine apply -f ocm-controller-test.yaml
kubectl -n open-cluster-management apply -f klusterlet-addon-controller-v2-test.yaml 
