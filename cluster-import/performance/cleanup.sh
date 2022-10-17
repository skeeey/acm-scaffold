#!/bin/bash

kubectl get managedclusters | grep test | awk '{print $1}' | xargs kubectl delete managedclusters
