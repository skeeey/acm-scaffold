#!/bin/bash

if [ "$1"x = "recover"x ]; then
    oc patch operatorhub cluster --type json -p '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": false}]'
    oc delete imagecontentsourcepolicy brew-registry
    # oc delete catalogsource submariner-catalog -n openshift-marketplace
fi

oc patch operatorhub cluster --type json -p '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": true}]'

oc get secret/pull-secret -n openshift-config -o json | jq -r '.data.".dockerconfigjson"' | base64 -d > authfile

token=$(cat docker.token)
sudo podman login --authfile authfile --username "|shared-qe-temp.src5.75b4d5" --password ${token}

oc set data secret/pull-secret -n openshift-config --from-file=.dockerconfigjson=authfile

cat <<EOF | oc apply -f -
apiVersion: operator.openshift.io/v1alpha1
kind: ImageContentSourcePolicy
metadata:
  name: brew-registry
spec:
  repositoryDigestMirrors:
  - mirrors:
    - brew.registry.redhat.io
    source: registry.redhat.io
  - mirrors:
    - brew.registry.redhat.io
    source: registry.stage.redhat.io
  - mirrors:
    - brew.registry.redhat.io
    source: registry-proxy.engineering.redhat.com
EOF

# cat <<EOF | oc apply -f -
# apiVersion: operators.coreos.com/v1alpha1
# kind: CatalogSource
# metadata:
#   name: submariner-catalog
#   namespace: openshift-marketplace
# spec:
#   sourceType: grpc
#   image: brew.registry.redhat.io/rh-osbs/iib:86169
#   displayName: Submariner 0.9
#   publisher: grpc
# EOF
