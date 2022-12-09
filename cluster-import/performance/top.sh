#!/bin/bash

kubectl -n multicluster-engine get deploy managedcluster-import-controller-v2-test -ojsonpath='{.spec.template.spec.containers[0].resources}'
echo ""
kubectl -n multicluster-engine get pods -l app=managedcluster-import-controller-v2-test

kubectl -n multicluster-engine top pods -l app=managedcluster-import-controller-v2-test --use-protocol-buffers