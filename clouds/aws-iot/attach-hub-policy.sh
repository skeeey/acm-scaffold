#!/usr/bin/env bash

PWD="$(cd "$(dirname ${BASH_SOURCE[0]})" ; pwd -P)"
POLICIES_DIR=$PWD/policies

source="maestro"
policyName="hub-${source}-policy"
certificateArn=""

aws iot create-policy --policy-name ${policyName} --policy-document "file://${POLICIES_DIR}/policy.hub.json"

aws iot attach-policy --policy-name ${policyName} --target ${certificateArn}

# aws iot attach-thing-principal \
#     --thing-name "PubSubTestThing" \
#     --principal ${certificateArn}
