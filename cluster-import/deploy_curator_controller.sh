#!/bin/bash

if [ "$1"x = "recover"x ]; then
    echo "recover ..."
    kubectl annotate mce multiclusterengine pause- --overwrite

    kubectl -n multicluster-engine delete -f cluster-curator-controller-test.yaml

    kubectl -n multicluster-engine scale deployment.v1.apps/cluster-curator-controller --replicas=2
    exit 0
fi

kubectl annotate mce multiclusterengine pause=true --overwrite

kubectl -n multicluster-engine get deploy cluster-curator-controller -o yaml > cluster-curator-controller-test.yaml

kubectl -n multicluster-engine scale deployment.v1.apps/cluster-curator-controller --replicas=0

echo ">>> replace the image in cluster-curator-controller-test.yaml"
read

kubectl -n multicluster-engine apply -f cluster-curator-controller-test.yaml
