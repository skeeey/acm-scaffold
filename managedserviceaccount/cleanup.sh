#!/bin/bash
CURRENT_DIR="$(dirname "${BASH_SOURCE[0]}")"
DEMO_DIR="$(cd ${CURRENT_DIR} && pwd)"

source "${DEMO_DIR}"/demo_magic
source "${DEMO_DIR}"/utils

export KUBECONFIG=hub.kubeconfig 

oc delete -f managedserviceaccount.yaml
oc delete -f managed-serviceaccount-addon.yaml

pe "oc patch multiclusterengine multiclusterengine-sample --type=json -p='[{\"op\":\"add\", \"path\":\"/spec/overrides/components/-\",\"value\":{\"name\":\"managedserviceaccount-preview\",\"enabled\":false}}]'"

