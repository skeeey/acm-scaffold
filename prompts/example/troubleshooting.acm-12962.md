---
link: https://issues.redhat.com/browse/ACM-12962
---

## Issue

The `local-cluster` status is unknown.

## Environment

The MCE version: `2.5.5`
The hub must-gather path: `/Users/wliu1/Downloads/must-gather-acm-12962`
The managed cluster must-gather path: `/Users/wliu1/Downloads/must-gather-acm-12962`

## Task

1. Give the issue root cause by analyzing it based on the provided must-gather.
2. Try to give the solution based on the issue root cause
3. If necessary, you can pull the corresponding code for further analysis.

## Tools

### ocm command

You could use the `omc` command to inspect resources from a `must-gather` in the same way as they are retrieved with the `oc` command.

#### Usage
Point the `omc` to a `must-gather`. This can be a local extracted must-gather, a local tarball, or a remote tarball:

```sh
omc use </path/to/must-gather/>
# Use it like `oc`:
omc get clusterversion
omc get pods -o wide -l app=etcd -n openshift-etcd
```

### deepwiki mcp

You cloud use deepwiki mcp to get architecture diagrams, documentation, and links to source code to help you understand codebases quickly.

## Code Repositories

### stolostron/ocm

The [stolostron/ocm](https://github.com/stolostron/ocm) is forked from [open-cluster-management-io/ocm](https://github.com/open-cluster-management-io/ocm), its branches correspond to the MCE versions, e.g. the branch `backplane-2.9` correspond to the MCE 2.9

### stolostron/managedcluster-import-controller

The [stolostron/managedcluster-import-controller](https://github.com/stolostron/managedcluster-import-controller) is the code base for `managedcluster-import-controller` which supports import, detach of ManagedCluster for MCE. its branches correspond to the MCE versions, e.g. the branch `backplane-2.9` correspond to the MCE 2.9
