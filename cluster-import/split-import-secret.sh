#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

cluster_name="$1"

kubectl -n $cluster_name get secrets "${cluster_name}-import" -o=jsonpath='{.data.import\.yaml}' | base64 -d > import.yaml

rm -f splitted-import*.yaml

csplit import.yaml /---/ -n2 -s {*} -f splitted-import -b "%02d.yaml"

cat splitted-import08.yaml | grep kubeconfig | grep -v bootstrap-hub-kubeconfig | awk '{print $2}' | sed 's/\"//g' | base64 -d > "${cluster_name}-bootstrap-hub-kubeconfig.yaml"
