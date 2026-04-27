
#!/bin/bash

kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml
kubectl wait --for condition=established crd/gateways.gateway.networking.k8s.io --timeout=30s


