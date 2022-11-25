#!/bin/bash
CURRENT_DIR="$(dirname "${BASH_SOURCE[0]}")"
PARENT_DIR="$(cd ../${CURRENT_DIR} && pwd)"
DEMO_DIR="$(cd ${CURRENT_DIR} && pwd)"

source "${PARENT_DIR}"/demo_magic
source "${PARENT_DIR}"/utils

kubeconfig="$(cat ${DEMO_DIR}/kubeconfig_path)"
node1=$(kubectl get nodes -l node-role.kubernetes.io/worker | awk '{print $1}' | tail -1)
node2=$(kubectl --kubeconfig ${kubeconfig} get nodes -l node-role.kubernetes.io/worker | awk '{print $1}' | tail -1)
node3=$(kubectl --kubeconfig ${kubeconfig} get nodes -l node-role.kubernetes.io/worker | awk '{print $1}' | head -n 2 | tail -1)

echo "##### enable managed-serviceaccount add-on on the hub cluster"
kubectl patch multiclusterengine multiclusterengine --type=json -p='[{"op":"add","path":"/spec/overrides/components/-","value":{"name":"managedserviceaccount-preview","enabled":true}}]'

echo "##### add taint and label to node $node1 for local cluster"
kubectl taint nodes ${node1} dedicated=acm-addons:NoSchedule --overwrite
kubectl label nodes ${node1} dedicated=acm-addons --overwrite

echo "##### add taint and label to node $node2 for cluster1"
kubectl --kubeconfig ${kubeconfig} taint nodes ${node2} dedicated=acm-addons:NoSchedule --overwrite
kubectl --kubeconfig ${kubeconfig} label nodes ${node2} dedicated=acm-addons --overwrite

echo "##### add taint and label to node $node3 for managed-servcieaccount on cluster1"
kubectl --kubeconfig ${kubeconfig} taint nodes ${node3} dedicated=acm-managed-servcieaccount:NoSchedule --overwrite
kubectl --kubeconfig ${kubeconfig} label nodes ${node3} dedicated=acm-managed-servcieaccount --overwrite

clear

comment "There are two managed clusters"
pe "kubectl get managedclusters"

comment "There is a dedicated node  ${node1}  for server foundation add-ons on local-cluster"
pe "kubectl describe nodes ${node1} | grep Taints"
pe "kubectl get nodes ${node1} --show-labels"

comment "There is a dedicated node ${kubeconfig} for  server foundation add-ons on cluster1"
pe "kubectl --kubeconfig ${kubeconfig} describe nodes ${node2} | grep Taints"
pe "kubectl --kubeconfig ${kubeconfig} get nodes ${node2} --show-labels"

comment ">>> Case1: Add a global default addondeploymentconfig for server foundation add-ons <<<"
comment "create one AddOnDeploymentConfig in the open-cluster-management-hub namespce on the hub cluster"
pe "cat configs/global_config.yaml"
pe "kubectl -n open-cluster-management-hub apply -f configs/global_config.yaml"

comment "patch the ClusterManagementAddons for each add-on to specify the default config on the hub cluster"
kubectl patch clustermanagementaddons work-manager --type='json' -p='[{"op":"add", "path":"/spec/supportedConfigs", "value":[{"group":"addon.open-cluster-management.io","resource":"addondeploymentconfigs","defaultConfig":{"namespace":"open-cluster-management-hub","name":"global"}}]}]'
kubectl patch clustermanagementaddons cluster-proxy --type='json' -p='[{"op":"add", "path":"/spec/supportedConfigs", "value":[{"group":"proxy.open-cluster-management.io","resource":"managedproxyconfigurations","defaultConfig":{"name":"cluster-proxy"}},{"group":"addon.open-cluster-management.io","resource":"addondeploymentconfigs","defaultConfig":{"namespace":"open-cluster-management-hub","name":"global"}}]}]'
kubectl patch clustermanagementaddons managed-serviceaccount --type='json' -p='[{"op":"add", "path":"/spec/supportedConfigs", "value":[{"group":"addon.open-cluster-management.io","resource":"addondeploymentconfigs","defaultConfig":{"namespace":"open-cluster-management-hub","name":"global"}}]}]'
pe "kubectl get clustermanagementaddons work-manager -oyaml"
pe "kubectl get clustermanagementaddons cluster-proxy -oyaml"
pe "kubectl get clustermanagementaddons managed-serviceaccount -oyaml"

comment "each add-on will reference the global config in local-cluster"
pe "kubectl -n local-cluster get managedclusteraddons work-manager -ojsonpath='{.status.configReferences}'"
echo ""
pe "kubectl -n local-cluster get managedclusteraddons cluster-proxy -ojsonpath='{.status.configReferences}'"
echo ""

comment "each add-on will reference the global config in cluster1"
pe "kubectl -n cluster1 get managedclusteraddons work-manager -ojsonpath='{.status.configReferences}'"
echo ""
pe "kubectl -n cluster1 get managedclusteraddons cluster-proxy -ojsonpath='{.status.configReferences}'"
echo ""

comment "each add-on should run on the dedicated  on the local-cluster"
pe "kubectl -n open-cluster-management-agent-addon get pods -l component=work-manager -ojsonpath='{range .items[*]}{.metadata.name}{\"\\t\"}{.spec.nodeName}{\"\\n\"}{end}'"
pe "kubectl -n open-cluster-management-agent-addon get pods -l open-cluster-management.io/addon=cluster-proxy -ojsonpath='{range .items[*]}{.metadata.name}{\"\\t\"}{.spec.nodeName}{\"\\n\"}{end}'"
comment "each add-on should run on the dedicated  on the cluster1"
pe "kubectl --kubeconfig ${kubeconfig} -n open-cluster-management-agent-addon get pods -l component=work-manager -ojsonpath='{range .items[*]}{.metadata.name}{\"\\t\"}{.spec.nodeName}{\"\\n\"}{end}'"
pe "kubectl --kubeconfig ${kubeconfig} -n open-cluster-management-agent-addon get pods -l open-cluster-management.io/addon=cluster-proxy -ojsonpath='{range .items[*]}{.metadata.name}{\"\\t\"}{.spec.nodeName}{\"\\n\"}{end}'"

comment "enable the managed-serviceaccount on the cluster1"
pe "kubectl -n cluster1 apply -f addons/managed-serviceaccount.yaml"

comment "the managed-serviceaccount will reference the global config by default"
pe "kubectl -n cluster1 get managedclusteraddons managed-serviceaccount -ojsonpath='{.status.configReferences}'"
echo ""

comment "the managed-serviceaccount should run on the dedicated node on the cluster1"
pe "kubectl --kubeconfig ${kubeconfig} -n open-cluster-management-agent-addon get pods -l addon-agent=managed-serviceaccount -ojsonpath='{range .items[*]}{.metadata.name}{\"\\t\"}{.spec.nodeName}{\"\\n\"}{end}'"

comment ">>> Case2: Specify a config for managed-serviceaccount to override its global default config on the cluster1 <<<"

comment "there is a dedicated node ${node3} for managed-serviceaccount on cluster1"
pe "kubectl --kubeconfig ${kubeconfig} describe nodes ${node3} | grep Taints"
pe "kubectl --kubeconfig ${kubeconfig} get nodes ${node3} --show-labels"

comment "create a AddOnDeploymentConfig in the cluster1 namespce for managed-serviceaccount on the hub cluster"
pe "cat configs/cluster1_config.yaml"
pe "kubectl -n cluster1 apply -f configs/cluster1_config.yaml"

comment "patch the ManagedClusterAddOn for managed-serviceaccount to specify the config on the hub cluster"
kubectl -n cluster1 patch managedclusteraddons managed-serviceaccount --type='json' -p='[{"op":"add", "path":"/spec/configs", "value":[{"group":"addon.open-cluster-management.io","resource":"addondeploymentconfigs","namespace":"cluster1","name":"cluster1"}]}]'
pe "kubectl -n cluster1 get managedclusteraddons managed-serviceaccount -oyaml"

comment "the managed-serviceaccount will reference the new config"
pe "kubectl -n cluster1 get managedclusteraddons managed-serviceaccount -ojsonpath='{.status.configReferences}'"
echo ""

comment "the managed-serviceaccount should run on the dedicated node that is specified by new config on the cluster1"
pe "kubectl --kubeconfig ${kubeconfig} -n open-cluster-management-agent-addon get pods -l addon-agent=managed-serviceaccount -ojsonpath='{range .items[*]}{.metadata.name}{\"\\t\"}{.spec.nodeName}{\"\\n\"}{end}'"
echo ""
