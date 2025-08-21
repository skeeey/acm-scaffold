# Troubleshooting JIRA Issues with must-gather Using Claude

In our daily work,  when we handle a JIRA issue, we often require analyzing [must-gather data](https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/support/gathering-cluster-data) to identify root causes. This process can be tedious—digging through logs, yaml resources, and searching the codebase.

In this blog, I’ll show you how to use Claude as a troubleshooting assistant.

By connecting Claude to JIRA and must-gather data, we can let it:

- Fetch the JIRA issue directly.
- Analyze must-gather data offline.
- Cross-reference code context for potential solutions.

Let’s walk through a real example.

## Step 1: Give Claude the Tools

Claude alone doesn’t know about JIRA or must-gather. We need to give it “eyes and ears” via MCP tools.

- JIRA MCP – fetches JIRA issue details.

    ```sh
    # use this link https://issues.redhat.com/servicedesk/customer/portal/2/create/45
    # to request your sonwflake token.
    claude mcp add --transport=sse --header="X-Snowflake-Token: your-sonwflake-token" jira-mcp-snowflake https://jira-mcp-snowflake.mcp-playground-poc.devshift.net/sse
    ```


- DeepWiki MCP – helps Claude understand the codebase.

    ```sh
    claude mcp add --transport sse deepwiki https://mcp.deepwiki.com/sse
    ```

- [`omc` command](https://github.com/gmeghnag/omc) – lets Claude (and you) inspect must-gather like `oc`.

## Step 2: Guide Claude with a Prompt

Claude works best with a clear task definition. We can write a simple `Claude.md` file:

```md
## Task

1. Use jira-mcp-snowflake mcp to fetch the JIRA issue
2. Give the issue root cause by analyzing it based on the provided must-gather.
3. Try to give the solution based on the issue root cause

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

## Related GitHub Repositories

put your related github repositories here

```

Here is an [example](./foundation/Claude.md)

## Step 3: Pick your JIRA Issue

Suppose you’re investigating a JIRA issue XXX-12345, you’d download the `must-gather` and start manually inspecting logs — but we’ll let Claude assist.

```sh
claude
╭───────────────────────────────────────────────────────────────────────────────╮
│ ✻ Welcome to Claude Code!                                                     │
│                                                                               │
│   /help for help, /status for your current setup                              │
│                                                                               │
│   cwd: /Users/xxx/claud-workspace                                             │
╰───────────────────────────────────────────────────────────────────────────────╯

╭─────────────────────────────────────────────────────────────────────────────────────────────╮
│ > troubeshooting the jira issue XXX-12345, the must-gather locate in /Users/xxx/must-gather                                                            │
╰─────────────────────────────────────────────────────────────────────────────────────────────╯

```

### Demo

- Troubleshooting the JIRA issue [ACM-12962](https://issues.redhat.com/browse/ACM-12962), [demo link](https://drive.google.com/file/d/1Llle4B1v-X6jVUb7ZDvQ-Ks0COvI04_s/view?usp=sharing)
- Troubleshooting the JIRA issue [ACM-13222](https://issues.redhat.com/browse/ACM-13222), [demo link](https://drive.google.com/file/d/1uTEognU1Z48_wYO36XTh4LtgAneOounZ/view?usp=sharing)
