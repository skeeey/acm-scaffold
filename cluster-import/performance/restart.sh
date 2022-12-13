#!/bin/bash

kubectl -n multicluster-engine delete pods -l app=managedcluster-import-controller-v2-test --force --grace-period=0
