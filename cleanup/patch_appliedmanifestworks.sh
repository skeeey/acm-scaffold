#!/bin/bash

kubectl get appliedmanifestworks | grep -v NAME | awk '{print $1}' | xargs kubectl patch appliedmanifestworks -p '{"metadata":{"finalizers": []}}' --type=merge

