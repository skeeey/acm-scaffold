#!/bin/bash

CURRENT_DIR="$(dirname "${BASH_SOURCE[0]}")"
PARENT_DIR="$(cd ../${CURRENT_DIR} && pwd)"
DEMO_DIR="$(cd ${CURRENT_DIR} && pwd)"

oc delete -f ${DEMO_DIR}/rbac/kubevirtprojects-view.yaml
oc -n cluster1 delete -f ${DEMO_DIR}/clusterpermissions
oc -n cluster2 delete -f ${DEMO_DIR}/clusterpermissions
