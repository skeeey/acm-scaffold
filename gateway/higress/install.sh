#!/bin/bash

helm install higress higress/higress \
    -n higress-system --create-namespace \
    --set global.local=true \
    --set global.o11y.enabled=false \
    --set global.enableGatewayAPI=true \
    --set higress-core.gateway.replicas=1 \
    --set higress-core.gateway.service.type=NodePort
