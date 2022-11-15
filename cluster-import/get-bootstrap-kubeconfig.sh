#!/bin/bash

cluster="cluster1"

kubectl -n ${cluster} get secrets ${cluster}-import -ojsonpath='{.data.import\.yaml}' | base64 -d > import.yaml
cat import.yaml | grep -w kubeconfig | awk '{print $2}' | tail -1 | sed 's/\"//g' | base64 -d > bootstrap.kubeconfig

#kubectl -n open-cluster-management-agent get secrets bootstrap-hub-kubeconfig -ojsonpath='{.data.kubeconfig}' | base64 -d > bootstrap.kubeconfig

cat bootstrap.kubeconfig | grep certificate-authority-data | awk '{print $2}' | base64 -d > bootstrap.ca
