#!/bin/bash

counts=$1
clustername="local-cluster"

echo "$counts manifestworks will be created"

for((i=0;i<$counts;i++));
do
  echo "${clustername}/perftest-${clustername}-work-${i} is created at $(date '+%Y-%m-%dT%H:%M:%SZ')"
  
  cat <<EOF | kubectl apply -f -
apiVersion: work.open-cluster-management.io/v1
kind: ManifestWork
metadata:
  name: perftest-${clustername}-work-${i}
  namespace: ${clustername}
  labels:
    perftest.open-cluster-management.io/work: "true"
spec:
  workload:
    manifests:
    - apiVersion: v1
      kind: ConfigMap
      metadata:
        name: perftest-${clustername}-work-${i}
        namespace: default
      data:
        test-data: "I'm a test configmap"
EOF

    sleep 1
done
