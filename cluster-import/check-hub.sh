#!/bin/bash

cluster_name=${1-"local-cluster"}

echo "#### managedcluster-import-controller"
kubectl -n open-cluster-management get pods -l component=managedcluster-import-controller

echo "#### show cluster"
kubectl get managedcluster $cluster_name
kubectl get ns $cluster_name

echo "#### show works"
kubectl -n $cluster_name get manifestworks

echo "#### show addons"
kubectl -n $cluster_name get managedclusteraddons
