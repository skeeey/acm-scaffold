#!/bin/bash
CURRENT_DIR="$(dirname "${BASH_SOURCE[0]}")"
PARENT_DIR="$(cd ../${CURRENT_DIR} && pwd)"
DEMO_DIR="$(cd ${CURRENT_DIR} && pwd)"

source "${PARENT_DIR}"/demo_magic
source "${PARENT_DIR}"/utils

comment "The managed clusters"
pe "kubectl get managedclusters"

comment "The add-ons"
pe "kubectl get clustermanagementaddons"
pe "kubectl -n open-cluster-management get pods"

comment "Case1: using AddOnDeploymentConfig to configure node selector and tolerations for helloworld add-on"
pe "kubectl get clustermanagementaddons helloworld -oyaml"
pe "kubectl -n cluster1 get managedclusteraddons helloworld -oyaml"

comment "create a addondeploymentconfig"
pe "cat configs/addondeploymentconfig.yaml"
pe "kubectl -n cluster1 apply -f configs/addondeploymentconfig.yaml"

comment "configure the addon with the addondeploymentconfig"
pe "kubectl -n cluster1 patch managedclusteraddons helloworld --type='json' -p='[{\"op\":\"add\", \"path\":\"/spec/supportConfigs\", \"value\":[{\"group\":\"addon.open-cluster-management.io\",\"resource\":\"addondeploymentconfigs\",\"namespace\":\"cluster1\",\"name\":\"deploy-config\"}]}]'"

pe "kubectl -n cluster1 get managedclusteraddons helloworld -ojsonpath='{.status.configReferences}'"
echo ""

pe "kubectl -n default get deploy helloworld-agent -ojsonpath='{.spec.template.spec.nodeSelector}'" 
echo ""
pe "kubectl -n default get deploy helloworld-agent -ojsonpath='{.spec.template.spec.tolerations}'"
echo ""

comment "Case2: update the configuration of helloworld"
pe "cat configs/addondeploymentconfig_update.yaml"
pe "kubectl -n cluster1 apply -f configs/addondeploymentconfig_update.yaml"

pe "kubectl -n cluster1 get managedclusteraddons helloworld -ojsonpath='{.status.configReferences}'"
echo ""

pe "kubectl -n default get deploy helloworld-agent -ojsonpath='{.spec.template.spec.nodeSelector}'"
echo ""

comment "Case3: configure ManagedClusterAddOn with mutiple configs"
pe "kubectl get clustermanagementaddons helloworldhelm -oyaml"

pe "cat configs/configmap.yaml"
pe "kubectl -n cluster1 apply -f configs/configmap.yaml"

pe "cat addons/helloworld_helm_addon_cr.yaml"
pe "kubectl -n cluster1 apply -f addons/helloworld_helm_addon_cr.yaml"

pe "kubectl -n cluster1 get managedclusteraddons helloworldhelm -ojsonpath='{.status.configReferences}'"
echo ""

pe "kubectl -n open-cluster-management-agent-addon get deploy helloworldhelm-agent -ojsonpath='{.spec.template.spec.containers[0].image}'"
echo ""
pe "kubectl -n open-cluster-management-agent-addon get deploy helloworldhelm-agent -ojsonpath='{.spec.template.spec.containers[0].imagePullPolicy}'"
echo ""
pe "kubectl -n open-cluster-management-agent-addon get deploy helloworldhelm-agent -ojsonpath='{.spec.template.spec.nodeSelector}'"
echo ""
pe "kubectl -n open-cluster-management-agent-addon get deploy helloworldhelm-agent -ojsonpath='{.spec.template.spec.tolerations}'"
echo ""

