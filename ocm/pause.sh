#!/bin/bash
export CTX_HUB_CLUSTER=kind-hub
export CTX_MANAGED_CLUSTER=kind-cluster1

kubectl --context ${CTX_HUB_CLUSTER} -n open-cluster-management scale deployment cluster-manager --replicas=0
kubectl --context ${CTX_MANAGED_CLUSTER} -n open-cluster-management scale deployment klusterlet --replicas=0
