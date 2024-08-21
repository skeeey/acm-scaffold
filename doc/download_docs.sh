#!/usr/bin/env bash

version="2.11"
base="https://docs.redhat.com/en-us/documentation/red_hat_advanced_cluster_management_for_kubernetes/${version}/pdf"

parts=(about release_notes access_control web_console install clusters multicluster_global_hub networking business_continuity gitOps applications governance observability health_metrics add-ons troubleshooting)

for part in ${parts[@]}
do
    url="${base}/${part}/Red_Hat_Advanced_Cluster_Management_for_Kubernetes-${version}-${part}-en-US.pdf"
    wget $url
done

