#!/bin/bash

clustername="local-cluster"

if [ "$1"x = "force"x ]; then
    kubectl -n $clustername get manifestworks -l perftest.open-cluster-management.io/work | grep -v NAME | awk '{print $1}' | xargs kubectl -n $clustername patch manifestworks -p '{"metadata":{"finalizers": []}}' --type=merge
fi

counts=1000
for((i=0;i<$counts;i++));
do
    time kubectl -n $clustername delete manifestworks perftest-${clustername}-work-${i}
done
