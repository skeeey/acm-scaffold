#!/bin/bash

if [ -n "${1}" ]; then
   echo "disable local-cluster"
   kubectl -n open-cluster-management patch multiclusterhubs multiclusterhub -p '{"spec":{"disableHubSelfManagement":true}}' --type=merge
   exit 0
fi

echo "enable local-cluster"
kubectl -n open-cluster-management patch multiclusterhubs multiclusterhub -p '{"spec":{"disableHubSelfManagement":false}}' --type=merge
