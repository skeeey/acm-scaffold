#!/bin/bash

cluster_name="cluster1"

kubectl -n $cluster_name get secrets "${cluster_name}-import" -o=jsonpath='{.data.crdsv1\.yaml}' | base64 -d > klusterlet.crdsv1.yaml

kubectl -n $cluster_name get secrets "${cluster_name}-import" -o=jsonpath='{.data.import\.yaml}' | base64 -d > import.yaml

kubeconfig="$(cat kubeconfig_path)"
echo "Apply the klusterlet.crdsv1.yaml and import.yaml to the managed cluster ${kubeconfig}"

kubectl --kubeconfig ${kubeconfig} apply -f klusterlet.crdsv1.yaml
kubectl --kubeconfig ${kubeconfig} apply -f import.yaml
