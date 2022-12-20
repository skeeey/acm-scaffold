#!/bin/bash

CURRENT_DIR="$(dirname "${BASH_SOURCE[0]}")"
DEMO_DIR="$(cd ${CURRENT_DIR} && pwd)"

oc apply -f image-registry/image-content-source-policy.yaml

echo "Wait for all nodes restarting"
oc get nodes -w

auth_basic=$(cat auth_file)
oc -n openshift-config get secret pull-secret --template='{{index .data ".dockerconfigjson" | base64decode}}' >pull_secret.yaml
oc registry login --registry="quay.io:443" --auth-basic="$auth_basic" --to=pull_secret.yaml
oc set data secret/pull-secret -n openshift-config --from-file=.dockerconfigjson=pull_secret.yaml

echo "Wait for all nodes restarting"
kubectl get nodes -w

deploy_repo="${HOME}/deploy"

pushd ${deploy_repo}
export DOCKER_CONFIG=$(cat ${DEMO_DIR}/docker.token)
export QUAY_TOKEN=$(echo $DOCKER_CONFIG | base64 -d | sed "s/quay\.io/quay\.io:443/g" | base64 -w 0)
export COMPOSITE_BUNDLE=true
export DOWNSTREAM=true
export CUSTOM_REGISTRY_REPO="quay.io:443/acm-d"
./start.sh --watch
popd

