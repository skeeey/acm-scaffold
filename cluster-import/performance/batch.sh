#!/bin/bash

counts=$1

echo "$counts managed cluters will be created"

cluster_counts=$(kubectl get managedcluster | wc -l)

index=$(($cluster_counts - 1))
for((i=0;i<$counts;i++));
do
  echo "test-$index is created at $(date '+%Y-%m-%dT%H:%M:%SZ')"
  
  cat <<EOF | kubectl apply -f -
apiVersion: cluster.open-cluster-management.io/v1
kind: ManagedCluster
metadata:
  name: test-$index
spec:
  hubAcceptsClient: true
EOF

    index=$(($index + 1))

    sleep 5
done
