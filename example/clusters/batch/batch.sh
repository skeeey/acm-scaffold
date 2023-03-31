#!/bin/bash

counts=$1

echo "$counts managed cluters will be created"

for((i=0;i<$counts;i++));
do
  echo "perftest-$i is created at $(date '+%Y-%m-%dT%H:%M:%SZ')"
  
  cat <<EOF | kubectl apply -f -
apiVersion: cluster.open-cluster-management.io/v1
kind: ManagedCluster
metadata:
  name: perftest-$i
  labels:
    perftest.open-cluster-management.io/managedcluster: "true"
spec:
  hubAcceptsClient: true
EOF

    sleep 1
done
