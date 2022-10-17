#!/bin/bash

kubectl get -n open-cluster-management-agent-addon applicationmanagers.agent.open-cluster-management.io | grep -v NAME | awk '{print $1}' | xargs kubectl -n open-cluster-management-agent-addon patch applicationmanagers.agent.open-cluster-management.io -p '{"metadata":{"finalizers": []}}' --type=merge

kubectl get -n open-cluster-management-agent-addon certpolicycontrollers.agent.open-cluster-management.io | grep -v NAME | awk '{print $1}' | xargs kubectl -n open-cluster-management-agent-addon patch certpolicycontrollers.agent.open-cluster-management.io -p '{"metadata":{"finalizers": []}}' --type=merge

kubectl get -n open-cluster-management-agent-addon iampolicycontrollers.agent.open-cluster-management.io | grep -v NAME | awk '{print $1}' | xargs kubectl -n open-cluster-management-agent-addon patch iampolicycontrollers.agent.open-cluster-management.io -p '{"metadata":{"finalizers": []}}' --type=merge

kubectl get -n open-cluster-management-agent-addon workmanagers.agent.open-cluster-management.io | grep -v NAME | awk '{print $1}' | xargs kubectl -n open-cluster-management-agent-addon patch workmanagers.agent.open-cluster-management.io -p '{"metadata":{"finalizers": []}}' --type=merge

kubectl get -n open-cluster-management-agent-addon policycontrollers.agent.open-cluster-management.io | grep -v NAME | awk '{print $1}' | xargs kubectl -n open-cluster-management-agent-addon patch policycontrollers.agent.open-cluster-management.io -p '{"metadata":{"finalizers": []}}' --type=merge

kubectl get -n open-cluster-management-agent-addon searchcollectors.agent.open-cluster-management.io | grep -v NAME | awk '{print $1}' | xargs kubectl -n open-cluster-management-agent-addon patch searchcollectors.agent.open-cluster-management.io -p '{"metadata":{"finalizers": []}}' --type=merge

kubectl get -n ui-helm2-ns helmreleases.apps.open-cluster-management.io | grep -v NAME | awk '{print $1}' | xargs kubectl -n ui-helm2-ns patch helmreleases.apps.open-cluster-management.io -p '{"metadata":{"finalizers": []}}' --type=merge
