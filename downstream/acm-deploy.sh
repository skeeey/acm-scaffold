#!/bin/bash

deploy_repo="/home/centos/deploy"

export DOCKER_CONFIG=$(cat docker.token)
export QUAY_TOKEN=$(echo $DOCKER_CONFIG | base64 -d | sed "s/quay\.io/quay\.io:443/g" | base64 -w 0)

export COMPOSITE_BUNDLE=true
export DOWNSTREAM=true

export CUSTOM_REGISTRY_REPO="quay.io:443/acm-d"

pushd ${deploy_repo}
kubectl apply -k addons/downstream
./start.sh --watch
popd

