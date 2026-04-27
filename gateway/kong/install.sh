#!/bin/bash

kubectl apply -f plugins/my-header/plugin.yaml

helm install kong kong/kong \
    --namespace kong --create-namespace \
    --set ingressController.installCRDs=false \
    --set database=off \
    --set proxy.type=NodePort \
    --set admin.enabled=true \
    --set admin.type=NodePort \
    --set env.plugins="bundled\,my-header" \
    --set env.lua_package_path="/opt/?.lua;/opt/?/init.lua;;" \
    --set "deployment.userDefinedVolumes[0].name=kong-plugin-my-header" \
    --set "deployment.userDefinedVolumes[0].configMap.name=kong-plugin-my-header" \
    --set "deployment.userDefinedVolumeMounts[0].name=kong-plugin-my-header" \
    --set "deployment.userDefinedVolumeMounts[0].mountPath=/opt/kong/plugins/my-header" \
    --set "deployment.userDefinedVolumeMounts[0].readOnly=true"
