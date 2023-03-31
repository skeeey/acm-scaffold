#!/bin/bash

counts=$1
clustername="cluster1"

echo "$counts manifestworks will be created"

work_counts=$(kubectl -n $clustername get manifestworks | wc -l)

index=$(($work_counts - 1))
for((i=0;i<$counts;i++));
do
  echo "perftest-${clustername}-work-${index} is created at $(date '+%Y-%m-%dT%H:%M:%SZ')"
  
  cat <<EOF | kubectl apply -f -
apiVersion: work.open-cluster-management.io/v1
kind: ManifestWork
metadata:
  name: perftest-${clustername}-work-${index}
spec:
  workload:
    manifests:
    - apiVersion: v1
      kind: ConfigMap
      metadata:
        name: perftest-${clustername}-work-${index}
        namespace: default
      data:
        test-data: "I'm a test configmap"
EOF

    index=$(($index + 1))

    sleep 1
done
