#!/bin/bash

kubectl delete klusterlets --all

kubectl delete crds klusterlets.operator.open-cluster-management.io

kubectl delete namespaces open-cluster-management-agent

kubectl delete ns open-cluster-management-agent-addon
