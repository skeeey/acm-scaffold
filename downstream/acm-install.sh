#!/bin/bash

set -o errexit

CURRENT_DIR="$(dirname "${BASH_SOURCE[0]}")"
PARENT_DIR="$(cd ../${CURRENT_DIR} && pwd)"

source "${PARENT_DIR}"/utils

oc create namespace open-cluster-management

oc -n open-cluster-management apply -f operator-group.yaml

oc -n open-cluster-management apply -f subscription.2.4.yaml

wait_command "oc -n open-cluster-management apply -f multiclusterhub.yaml"

oc -n open-cluster-management get mch -o=jsonpath='{.items[0].status.phase}{"\n"}'

oc -n open-cluster-management get routes
