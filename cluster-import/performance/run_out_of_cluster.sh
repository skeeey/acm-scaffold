#!/bin/bash

time=$(date '+%Y%m%d%H%M%S')

namespace=multicluster-engine

manager=${HOME}/go/src/github.com/stolostron/managedcluster-import-controller/_output/manager

cpuprofile="cpu.${time}.profile"
memprofile="mem.${time}.profile"

tracefile="output.${time}.trace"

kubectl annotate mce multiclusterengine pause=true --overwrite
kubectl -n $namespace scale deployment.v1.apps/managedcluster-import-controller-v2 --replicas=0

yaml=$(kubectl -n multicluster-engine get deploy managedcluster-import-controller-v2 -ojson)

operator=$(echo ${yaml} | jq -r '.spec.template.spec.containers[0].env[] | select(.name | test("REGISTRATION_OPERATOR_IMAGE")).value')
registration=$(echo ${yaml} | jq -r '.spec.template.spec.containers[0].env[] | select(.name | test("REGISTRATION_IMAGE")).value')
work=$(echo ${yaml} | jq -r '.spec.template.spec.containers[0].env[] | select(.name | test("WORK_IMAGE")).value')

export REGISTRATION_OPERATOR_IMAGE=$operator
export REGISTRATION_IMAGE=$registration
export WORK_IMAGE=$work
${manager} --kubeconfig=${KUBECONFIG} \
    --leader-election-namespace=${namespace} \
    --tracefile="${tracefile}"
    # --cpuprofile="${cpuprofile}" \
    # --memprofile="${memprofile}"

unset REGISTRATION_OPERATOR_IMAGE
unset REGISTRATION_IMAGE
unset WORK_IMAGE
