#!/bin/bash

oc -n open-cluster-management get mch -o=jsonpath='{.items[0].status.currentVersion}{"\n"}'
