#!/bin/bash

CURRENT_DIR="$(dirname "${BASH_SOURCE[0]}")"
PARENT_DIR="$(cd ../${CURRENT_DIR} && pwd)"
DEMO_DIR="$(cd ${CURRENT_DIR} && pwd)"

source "${PARENT_DIR}"/demo_magic
source "${PARENT_DIR}"/utils

comment "Manged clusters"
pe "oc get managedclusters"

comment "Group and users"
pe "oc get users,groups"

comment "Assign the view permission to kubevirtprojects for users"
pe "oc apply -f ${DEMO_DIR}/rbac/kubevirtprojects-view.yaml"

comment "Create ClusterPermissions in managed clusters"
pe "oc -n cluster1 apply -f ${DEMO_DIR}/clusterpermissions"
pe "oc -n cluster2 apply -f ${DEMO_DIR}/clusterpermissions"

comment "List the kubevirt projects by user0"
pe "oc get kubevirtprojects.clusterview.open-cluster-management.io --as user0"

comment "List the kubevirt projects by user1"
pe "oc get kubevirtprojects.clusterview.open-cluster-management.io --as user1 --as-group kubevirt-projects-view"

comment "List the kubevirt projects by admin"
pe "oc get kubevirtprojects.clusterview.open-cluster-management.io"
