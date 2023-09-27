#!/bin/bash

echo "########## clean up olm"
kubectl delete subs -n multicluster-engine --all
kubectl delete subs -n open-cluster-management --all

kubectl delete csv -n multicluster-engine --all
kubectl delete csv -n open-cluster-management --all

kubectl delete catsrc -n openshift-marketplace acm-custom-registry --ignore-not-found
kubectl delete catsrc -n openshift-marketplace multiclusterengine-catalog --ignore-not-found

kubectl delete og -n multicluster-engine --all
kubectl delete og -n open-cluster-management --all

kubectl delete operatorconditions -n multicluster-engine --all
kubectl delete operatorconditions -n open-cluster-management --all

kubectl get csv,catsrc,subs,ip,og,operatorconditions --all-namespaces

echo "########## clean up hub crds ...."
kubectl get crds | grep submariner | awk '{print $1}' | xargs kubectl delete crds
kubectl get crds | grep hive | awk '{print $1}' | xargs kubectl delete crds
kubectl get crds | grep open-cluster-management | awk '{print $1}' | xargs kubectl delete crds
kubectl delete crds serviceimports.multicluster.x-k8s.io
kubectl delete crds observatoria.core.observatorium.io
kubectl get crds | grep -v openshift.io | grep -v coreos.com | grep -v metal3 | grep -v k8s | grep -v cncf

echo "##########  patch local-cluster"
kubectl get roles -n local-cluster | grep -v NAME | awk '{print $1}' | xargs kubectl -n local-cluster patch roles -p '{"metadata":{"finalizers": []}}' --type=merge
kubectl get rolebindings -n local-cluster | grep -v NAME | awk '{print $1}' | xargs kubectl -n local-cluster patch rolebindings -p '{"metadata":{"finalizers": []}}' --type=merge

echo "########## patch hub resources"
kubectl get multiclusterhubs | grep -v NAME | awk '{print $1}' | xargs kubectl patch multiclusterhubs -p '{"metadata":{"finalizers": []}}' --type=merge
kubectl get searches | grep -v NAME | awk '{print $1}' | xargs kubectl patch searches -p '{"metadata":{"finalizers": []}}' --type=merge
kubectl get clustermanagers | grep -v NAME | awk '{print $1}' | xargs kubectl patch clustermanagers -p '{"metadata":{"finalizers": []}}' --type=merge
kubectl get managedclustersets | grep -v NAME | awk '{print $1}' | xargs kubectl patch managedclustersets -p '{"metadata":{"finalizers": []}}' --type=merge
kubectl get multiclusterobservabilities | grep -v NAME | awk '{print $1}' | xargs kubectl patch multiclusterobservabilities -p '{"metadata":{"finalizers": []}}' --type=merge

echo "########## delete webhooks"
kubectl get validatingwebhookconfigurations | grep open-cluster-management.io | awk '{print $1}' | xargs kubectl delete validatingwebhookconfigurations
kubectl get mutatingwebhookconfigurations | grep open-cluster-management.io | awk '{print $1}' | xargs kubectl delete mutatingwebhookconfigurations
kubectl delete mutatingwebhookconfigurations hypershift.openshift.io ocm-mutating-webhook
kubectl delete validatingwebhookconfigurations ocm-validating-webhook application-webhook-validator multicluster-observability-operator multiclusterengines.multicluster.openshift.io multiclusterhub-operator-validating-webhook
kubectl get mutatingwebhookconfigurations
kubectl get validatingwebhookconfigurations

echo "########## delete apiservices"
kubectl delete apiservices v1.operator.open-cluster-management.io
kubectl delete apiservices v1beta1.app.k8s.io
kubectl get apiservices | grep False | awk '{print $1}' | xargs kubectl delete apiservices
kubectl get apiservices

echo "########## delete namespaces"
kubectl delete namespace open-cluster-management-observability --ignore-not-found
kubectl delete namespace hive --ignore-not-found
kubectl delete namespace default-broker --ignore-not-found
kubectl delete namespace multicluster-engine --ignore-not-found
kubectl delete namespace open-cluster-management --ignore-not-found
kubectl get namespace

