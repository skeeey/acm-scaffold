#!/bin/bash

set -o nounset
set -o pipefail

KUBECTL=${KUBECTL:-kubectl}

rm -rf registration-operator

echo "############  Cloning registration-operator"
git clone https://github.com/open-cluster-management-io/registration-operator.git

echo "############  Deploying hub"
$KUBECTL apply -k registration-operator/deploy/cluster-manager/config
if [ $? -ne 0 ]; then
 echo "############  Failed to deploy clustermanager operator"
 exit 1
fi
$KUBECTL apply -k registration-operator/deploy/cluster-manager/config/samples
if [ $? -ne 0 ]; then
 echo "############  Failed to deploy clustermanager"
 exit 1
fi

echo "############  Deploying klusterlet"
$KUBECTL apply -k registration-operator/deploy/klusterlet/config
if [ $? -ne 0 ]; then
 echo "############  Failed to deploy klusterlet operator"
 exit 1
fi
$KUBECTL config view --minify --flatten > registration-operator/deploy/klusterlet/config/samples/bootstrap/hub-kubeconfig
context=$(kubectl config current-context --kubeconfig registration-operator/deploy/klusterlet/config/samples/bootstrap/hub-kubeconfig)
clusterip=$(kubectl get svc kubernetes -n default -o jsonpath='{.spec.clusterIP}')
kubectl config set clusters.${context}.server https://${clusterip} --kubeconfig registration-operator/deploy/klusterlet/config/samples/bootstrap/hub-kubeconfig
kubectl get ns open-cluster-management-agent || kubectl create ns open-cluster-management-agent
$KUBECTL apply -k registration-operator/deploy/klusterlet/config/samples/bootstrap
$KUBECTL apply -k registration-operator/deploy/klusterlet/config/samples
if [ $? -ne 0 ]; then
 echo "############  Failed to deploy klusterlet"
 exit 1
fi

for i in {1..7}; do
  echo "############$i  Checking cluster-manager-registration-controller"
  RUNNING_POD=$($KUBECTL -n open-cluster-management-hub get pods | grep cluster-manager-registration-controller | grep -c "Running")
  if [ "${RUNNING_POD}" -ge 1 ]; then
    break
  fi

  if [ $i -eq 7 ]; then
    echo "!!!!!!!!!!  the cluster-manager-registration-controller is not ready within 3 minutes"
    $KUBECTL -n open-cluster-management-hub get pods

    exit 1
  fi
  sleep 30
done

for i in {1..7}; do
  echo "############$i  Checking cluster-manager-registration-webhook"
  RUNNING_POD=$($KUBECTL -n open-cluster-management-hub get pods | grep cluster-manager-registration-webhook | grep -c "Running")
  if [ "${RUNNING_POD}" -ge 1 ]; then
    break
  fi

  if [ $i -eq 7 ]; then
    echo "!!!!!!!!!!  the cluster-manager-registration-webhook is not ready within 3 minutes"
    $KUBECTL -n open-cluster-management-hub get pods
    exit 1
  fi
  sleep 30s
done

for i in {1..7}; do
  echo "############$i  Checking klusterlet-registration-agent"
  RUNNING_POD=$($KUBECTL -n open-cluster-management-agent get pods | grep klusterlet-registration-agent | grep -c "Running")
  if [ ${RUNNING_POD} -ge 1 ]; then
    break
  fi

  if [ $i -eq 7 ]; then
    echo "!!!!!!!!!!  the klusterlet-registration-agent is not ready within 3 minutes"
    $KUBECTL -n open-cluster-management-agent get pods
    exit 1
  fi
  sleep 30
done

echo "############  Approve managed cluster"
sleep 5
kubectl patch managedcluster cluster1 -p='{"spec":{"hubAcceptsClient":true}}' --type=merge
kubectl get csr -l open-cluster-management.io/cluster-name=cluster1 | grep Pending | awk '{print $1}' | xargs kubectl certificate approve

echo "############  All-in-one env is installed successfully!!"

echo "############  Cleanup"
rm -rf registration-operator

echo "############  Finished installation!!!"
