#!/bin/bash
CURRENT_DIR="$(dirname "${BASH_SOURCE[0]}")"
PARENT_DIR="$(cd ../${CURRENT_DIR} && pwd)"
DEMO_DIR="$(cd ${CURRENT_DIR} && pwd)"

source "${PARENT_DIR}"/demo_magic
source "${PARENT_DIR}"/utils

comment "A gRPC server is introduced on the hub, the managedcluster agents will transport its resources over this gRPC server"
pe "kubectl -n open-cluster-management-hub get pods,svc"

# register cluster
comment "Deploy managedcluster agents using gRPC bootstrap config on a spoke cluster to register this cluster"
pe "kubectl -n open-cluster-management-agent get secrets bootstrap-secret -ojsonpath='{.data.config\.yaml}' | base64 -d"
pe "kubectl apply -k deploy/spoke"
pe "kubectl -n open-cluster-management-agent get pods -w"

comment "Get managedclusters on the hub"
pe "kubectl get managedclusters -w"
pe "kubectl get csr -w"

comment "Approve the managedcluster"
pe "kubectl patch managedcluster cluster1 -p='{\"spec\":{\"hubAcceptsClient\":true}}' --type=merge"
pe "kubectl get csr -l open-cluster-management.io/cluster-name=cluster1 | grep Pending | awk '{print \$1}' | xargs kubectl certificate approve"
pe "kubectl get managedclusters -w"
comment "After the managedcluster is registered, the work agent will connect to the hub over gRPC"
pe "kubectl -n open-cluster-management-agent get secrets -w"
pe "kubectl -n open-cluster-management-agent get secrets hub-kubeconfig-secret -ojsonpath='{.data.config\.yaml}' | base64 -d"
pe "kubectl -n open-cluster-management-agent get pods -w"

# apply a manifestwork
comment "Create a manifestwork"
pe "kubectl -n cluster1 apply -f manifests/nginx-replicas-1.yaml"
pe "kubectl -n cluster1 get manifestworks nginx -ojsonpath='{.status}' -w"
echo ""

comment "Update this manifestwork"
pe "kubectl -n cluster1 apply -f manifests/nginx-replicas-2.yaml"
pe "kubectl -n cluster1 get manifestworks nginx -ojsonpath='{.status}' -w"
echo ""

comment "Delete this manifestwork"
pe "kubectl -n cluster1 delete manifestworks nginx"
pe "kubectl -n cluster1 get manifestworks"

# deploy an addon
comment "Deploy an addon"
pe "kubectl apply -k deploy/addon/helloworld"
pe "kubectl get clustermanagementaddons"
pe "kubectl -n cluster1 get managedclusteraddon -w"
