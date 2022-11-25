#!/bin/bash

kubectl -n cluster1 delete managedclusteraddons.addon.open-cluster-management.io managed-serviceaccount

kubectl patch clustermanagementaddons managed-serviceaccount --type='json' -p='[{"op":"remove", "path":"/spec/supportedConfigs"}]'
kubectl patch clustermanagementaddons work-manager --type='json' -p='[{"op":"remove", "path":"/spec/supportedConfigs"}]'

kubectl -n open-cluster-management-hub delete -f configs/global_config.yaml
kubectl -n cluster1 delete -f configs/cluster1_config.yaml

kubectl edit clustermanagementaddons cluster-proxy
