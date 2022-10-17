#!/bin/bash

kubectl get klusterlets | grep -v NAME | awk '{print $1}' | xargs kubectl patch klusterlets -p '{"metadata":{"finalizers": []}}' --type=merge
