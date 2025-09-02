## Task

1. If the issue is from the JIRA, use jira-mcp-snowflake mcp to fetch the JIRA issue
2. Give the issue root cause by analyzing it based on the provided logs/must-gather.
3. Could use deepwiki mcp to help you better understand and find the relevant context in the related codebase.
4. Do **not** send logs, must-gather data, or any sensitive information to deepwiki.
5. Try to give the solution based on the issue root cause

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

## Related GitHub Repositories

### openshift-online/maestro

The [openshift-online/maestro](https://github.com/openshift-online/maestro) has two components: maestro server and maestro agent, the maestro server publish the resource to maestro agent and subscribe to the resource status from maestro agent.

### open-cluster-management-io/ocm

The [open-cluster-management-io/ocm](https://github.com/open-cluster-management-io/ocm) is the code base for the OpenShift Cluster Management (OCM) project. the maestro agent reuses the ocm work agent's codebase (https://github.com/open-cluster-management-io/ocm/tree/main/pkg/work/spoke). 
