#!/bin/bash

counts=$1

echo "$counts managed cluters will be created"

for((i=0;i<$counts;i++));
do
  echo "perftest-hosted-$i is created at $(date '+%Y-%m-%dT%H:%M:%SZ')"
  
  cat <<EOF | kubectl apply -f -
apiVersion: cluster.open-cluster-management.io/v1
kind: ManagedCluster
metadata:
  annotations:
    open-cluster-management/created-via: other
    import.open-cluster-management.io/klusterlet-deploy-mode: Hosted
    import.open-cluster-management.io/hosting-cluster-name: local-cluster
    import.open-cluster-management.io/klusterlet-namespace: open-cluster-management-perftest-hosted-$i-agent
    addon.open-cluster-management.io/disable-automatic-installation: "true"
  labels:
    name: perftest-hosted-$i
    perftest.open-cluster-management.io/managedcluster: "true"
  name: perftest-hosted-$i
spec:
  hubAcceptsClient: true
EOF

    sleep 5
done
