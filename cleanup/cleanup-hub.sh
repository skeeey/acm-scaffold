#!/bin/bash

echo "########## clean up hub crds ...."
kubectl get crds | grep submariner | awk '{print $1}' | xargs kubectl delete crds

kubectl delete crds serviceimports.multicluster.x-k8s.io

kubectl get crds | grep hive | awk '{print $1}' | xargs kubectl delete crds

kubectl delete crds observatoria.core.observatorium.io

kubectl get crds | grep open-cluster-management | awk '{print $1}' | xargs kubectl delete crds

echo "##########  patch local-cluster"
kubectl get roles -n local-cluster | grep -v NAME | awk '{print $1}' | xargs kubectl -n local-cluster patch roles -p '{"metadata":{"finalizers": []}}' --type=merge
kubectl get rolebindings -n local-cluster | grep -v NAME | awk '{print $1}' | xargs kubectl -n local-cluster patch rolebindings -p '{"metadata":{"finalizers": []}}' --type=merge

echo "########## patch hub resources"
kubectl get multiclusterhubs | grep -v NAME | awk '{print $1}' | xargs kubectl patch multiclusterhubs -p '{"metadata":{"finalizers": []}}' --type=merge
kubectl get clustermanagers | grep -v NAME | awk '{print $1}' | xargs kubectl patch clustermanagers -p '{"metadata":{"finalizers": []}}' --type=merge
kubectl get managedclustersets | grep -v NAME | awk '{print $1}' | xargs kubectl patch managedclustersets -p '{"metadata":{"finalizers": []}}' --type=merge
kubectl get multiclusterobservabilities | grep -v NAME | awk '{print $1}' | xargs kubectl patch multiclusterobservabilities -p '{"metadata":{"finalizers": []}}' --type=merge

echo "########## delete webhooks"
kubectl get validatingwebhookconfigurations | grep open-cluster-management.io | awk '{print $1}' | xargs kubectl delete validatingwebhookconfigurations
kubectl get mutatingwebhookconfigurations | grep open-cluster-management.io | awk '{print $1}' | xargs kubectl delete mutatingwebhookconfigurations
kubectl delete mutatingwebhookconfigurations hypershift.openshift.io ocm-mutating-webhook
kubectl delete validatingwebhookconfigurations ocm-validating-webhook 

echo "########## delete apiservices"
kubectl get apiservices | grep False | awk '{print $1}' | xargs kubectl delete apiservices

echo "########## delete namespaces"
kubectl delete namespace open-cluster-management-observability --ignore-not-found
kubectl delete namespace hive --ignore-not-found
kubectl delete namespace default-broker --ignore-not-found
