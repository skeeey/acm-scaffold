#!/bin/bash

if [ -n "${1}" ]; then
    kubectl annotate mce multiclusterengine imageOverridesCM- --overwrite
    kubectl -n multicluster-engine delete configmap import-controlle-image-config
    sleep 5
    kubectl -n multicluster-engine get deploy managedcluster-import-controller-v2 -ojsonpath='{.spec.template.spec.containers[0].image}'
    exit 0
fi

image_digest=""

cat <<EOF | kubectl apply -f -
apiVersion: v1
data:
  manifest.json: |-
    [
      {
        "image-name": "managedcluster-import-controlle",
        "image-remote": "quay.io/skeeey",
        "image-digest": "$image_digest",
        "image-key": "managedcluster_import_controller"
      }
    ]
kind: ConfigMap
metadata:
  name: import-controlle-image-config
  namespace: multicluster-engine
EOF

kubectl annotate mce multiclusterengine --overwrite imageOverridesCM=import-controlle-image-config

sleep 5

kubectl -n multicluster-engine get deploy managedcluster-import-controller-v2 -ojsonpath='{.spec.template.spec.containers[0].image}'
