#!/bin/bash
CURRENT_DIR="$(dirname "${BASH_SOURCE[0]}")"
PARENT_DIR="$(cd ../${CURRENT_DIR} && pwd)"
DEMO_DIR="$(cd ${CURRENT_DIR} && pwd)"

source "${PARENT_DIR}"/demo_magic
source "${PARENT_DIR}"/utils

kubectl patch clustermanagementaddons work-manager --type='json' -p='[{"op":"add", "path":"/spec/supportedConfigs", "value":[{"group":"addon.open-cluster-management.io","resource":"addondeploymentconfigs"}]}]'