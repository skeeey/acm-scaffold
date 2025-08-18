---
link: https://access.redhat.com/support/cases/#/case/03926591
---

## Issue

The status of the addons on the managed cluster ocp-dev-01 is unknown. 

## Environment

The hub must-gather path: `/Users/wliu1/Downloads/must-gather-case-03926591/hub`

## Task

1. Give the issue root cause by analyzing it based on the provided must-gather.
2. Try to give the solution based on the issue root cause

## Tools

### omc command

You could use the `omc` command to inspect resources from a `must-gather` in the same way as they are retrieved with the `oc` command.

Usage
Point the `omc` to a `must-gather`. This can be a local extracted must-gather, a local tarball, or a remote tarball:

```sh
omc use </path/to/must-gather/>
# Use it like `oc`:
omc get clusterversion # show OpenShift cluster version
omc get pods -o wide -l app=etcd -n openshift-etcd
```

### deepwiki mcp

You cloud use deepwiki mcp to help you better understand and find the relevant context in the related codebase.

## GitHub Repositories

### stolostron/ocm

The [stolostron/ocm](https://github.com/stolostron/ocm) is forked from [open-cluster-management-io/ocm](https://github.com/open-cluster-management-io/ocm). Its branches correspond to the MCE/ACM versions - for example, the branch `backplane-2.9` corresponds to the MCE 2.9 and ACM 2.14.

### stolostron/managedcluster-import-controller

The [stolostron/managedcluster-import-controller](https://github.com/stolostron/managedcluster-import-controller) is the code base for `managedcluster-import-controller`, which supports importing and detaching `ManagedCluster` in MCE. Its branches correspond to the MCE/ACM versions - for example, the branch `backplane-2.9` corresponds to the MCE 2.9 and ACM 2.14.

### stolostron/klusterlet-addon-controller

The [stolostron/klusterlet-addon-controller](https://github.com/stolostron/klusterlet-addon-controller) is the code base for `klusterlet-addon-controller`, which supports the installation and termination of add-ons on ManagedClusters in ACM, including: work-manager, application, policy, and search. Its branches correspond to ACM versions — for example, the release-2.14 branch corresponds to ACM 2.14.

### stolostron/foundation-docs

The [stolostron/foundation-docs](https://github.com/stolostron/foundation-docs) maintains a collection of documentation and runbooks to help you troubleshoot the issue.
