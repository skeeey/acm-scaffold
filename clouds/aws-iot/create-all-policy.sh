#!/usr/bin/env bash

PWD="$(cd "$(dirname ${BASH_SOURCE[0]})" ; pwd -P)"
POLICIES_DIR=$PWD/policies

policyName="all-policy"

aws iot create-policy --policy-name ${policyName} --policy-document "file://${POLICIES_DIR}/all.json"

