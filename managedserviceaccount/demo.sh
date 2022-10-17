#!/bin/bash
CURRENT_DIR="$(dirname "${BASH_SOURCE[0]}")"
PARENT_DIR="$(cd ../${CURRENT_DIR} && pwd)"
DEMO_DIR="$(cd ${CURRENT_DIR} && pwd)"

source "${PARENT_DIR}"/demo_magic
source "${PARENT_DIR}"/utils

export KUBECONFIG=hub.kubeconfig 

comment "Enable ManagedServiceAccount add-on on the hub cluster"
pe "oc patch multiclusterengine multiclusterengine-sample --type=json -p='[{\"op\":\"add\", \"path\":\"/spec/overrides/components/-\",\"value\":{\"name\":\"managedserviceaccount-preview\",\"enabled\":true}}]'"
pe "oc -n multicluster-engine get pods -w"
pe "oc get managedclusters"

comment "Deploy the ManagedServiceAccount add-on to the cluster1"
pe "cat managed-serviceaccount-addon.yaml"
pe "oc apply -f managed-serviceaccount-addon.yaml"
pe "oc -n cluster1 get managedclusteraddons -w"

comment "Create a ManagedServiceAccount in the cluster1 namespace"
pe "cat managedserviceaccount.yaml"
pe "oc apply -f managedserviceaccount.yaml"
pe "oc get managedserviceaccount demo-sa -n cluster1 -o yaml"
pe "oc get secret demo-sa -o=jsonpath='{.data}' -n cluster1 -o yaml"

comment "Use this token to list default namespace configmaps in cluster1"
pe "oc get secret demo-sa -n cluster1 -o=jsonpath='{.data.ca\.crt}' | base64 -d > cluster_ca.crt"
token=$(oc get secret demo-sa -n cluster1 -o=jsonpath='{.data.token}' | base64 -d)
kubeapi="https://127.0.0.1:35139"
pe "curl --cacert cluster_ca.crt -H \"Authorization: Bearer $token\" $kubeapi/api/v1/namespaces/default/configmaps/"
pe "cat demo-rbac.yaml"
pe "kubectl apply -f demo-rbac.yaml --kubeconfig cluster1_admin.kubeconfig"
pe "curl --cacert cluster_ca.crt -H \"Authorization: Bearer $token\" $kubeapi/api/v1/namespaces/default/configmaps/"

