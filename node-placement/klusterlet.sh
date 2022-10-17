#!/bin/bash
CURRENT_DIR="$(dirname "${BASH_SOURCE[0]}")"
PARENT_DIR="$(cd ../${CURRENT_DIR} && pwd)"
DEMO_DIR="$(cd ${CURRENT_DIR} && pwd)"

source "${PARENT_DIR}"/demo_magic
source "${PARENT_DIR}"/utils

comment "The nodes of my OCP cluster"
pe "kubectl get nodes"

node_name=$(kubectl get nodes -l node-role.kubernetes.io/worker | awk '{print $1}' | tail -1)

comment "I want to dedicate the node \"$node_name\" for klusterlet and addons"

read

comment "Add a taint to this node to exclude users other than acm users"
pe "kubectl taint nodes ${node_name} dedicated=acm:NoSchedule --overwrite"
comment "Add a label to this node to ensure that this node is only for acm users"
pe "kubectl label nodes ${node_name} dedicated=acm --overwrite"

comment "I add the nodeSelector and tolerations annotations to the managed cluster when I import this cluster"
echo "    open-cluster-management/nodeSelector: '{\"dedicated\":\"acm\"}'"
echo "    open-cluster-management/tolerations: '[{\"key\":\"dedicated\",\"operator\":\"Equal\",\"value\":\"acm\",\"effect\":\"NoSchedule\"}]'"

read

comment "the node placement of klusterlet"
pe "kubectl get klusterlet klusterlet -ojsonpath='{.spec.nodePlacement}'"
echo ""
comment "the klusterlet agents are deploy on the node \"$node_name\""
pe "kubectl -n open-cluster-management-agent get pods -ojsonpath='{range .items[*]}{.metadata.name}{\"\\t\"}{.spec.nodeName}{\"\\n\"}{end}'"

