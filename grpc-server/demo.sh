#!/bin/bash
CURRENT_DIR="$(dirname "${BASH_SOURCE[0]}")"
PARENT_DIR="$(cd ../${CURRENT_DIR} && pwd)"
DEMO_DIR="$(cd ${CURRENT_DIR} && pwd)"

source "${PARENT_DIR}"/demo_magic
source "${PARENT_DIR}"/utils

comment "A gRPC server is introduced on the hub, the klusterlet agents will transport resources over this gRPC server"
pe "kubectl -n open-cluster-management-hub get pods,svc"

# register cluster
comment "Deploy klusterlet agents using a gRPC bootstrap config on a spoke cluster to register the spoke cluster"
pe "kubectl -n open-cluster-management-agent get secrets bootstrap-secret -ojsonpath='{.data.config\.yaml}' | base64 -d"
pe "kubectl apply -k deploy/spoke"
pe "kubectl -n open-cluster-management-agent get pods -w"

comment "When the klusterlet registration agent start up, it will create ManagedCluster and CSR on the hub"
pe "kubectl get managedclusters -w"
pe "kubectl get csr -w"

comment "Accept the managedcluster"
pe "kubectl patch managedcluster cluster1 -p='{\"spec\":{\"hubAcceptsClient\":true}}' --type=merge"
pe "kubectl get csr -l open-cluster-management.io/cluster-name=cluster1 | grep Pending | awk '{print \$1}' | xargs kubectl certificate approve"
pe "kubectl get managedclusters -w"
comment "After the managedcluster is registered, a new hub gRPC config will be created on the managedcluster"
pe "kubectl -n open-cluster-management-agent get secrets -w"
pe "kubectl -n open-cluster-management-agent get secrets hub-kubeconfig-secret -ojsonpath='{.data.config\.yaml}' | base64 -d"
comment "The work agent connects to the hub over gRPC with the new config"
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
