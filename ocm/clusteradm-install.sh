#!/bin/bash

export CTX_HUB_CLUSTER=kind-hub
export CTX_MANAGED_CLUSTER=kind-cluster1

clusteradm init --wait --context ${CTX_HUB_CLUSTER} --output-join-command-file join.sh

sh -c "$(cat join.sh) cluster1 --force-internal-endpoint-lookup --context ${CTX_MANAGED_CLUSTER}"

clusteradm accept --clusters cluster1 --context ${CTX_HUB_CLUSTER}

kubectl get managedclusters -w --context ${CTX_HUB_CLUSTER}
