#!/bin/bash

REPO="github.com/skeeey/sdk-go"
BRANCH="${1:-main}"

echo "Fetching latest commit from $REPO branch: $BRANCH"

# 获取 commit SHA
SHA=$(git ls-remote https://$REPO.git $BRANCH | cut -f1)

if [ -z "$SHA" ]; then
    echo "Error: branch not found or repo inaccessible"
    exit 1
fi

# 获取 commit 时间（通过 GitHub API）
TIMESTAMP=$(curl -s "https://api.github.com/repos/${REPO/github.com\//}/commits/$SHA" | jq -r '.commit.committer.date' 2>/dev/null)

if [ "$TIMESTAMP" = "null" ]; then
    echo "Warning: Can't fetch timestamp via API. Use current time."
    TIMESTAMP=$(date -u +"%Y%m%d%H%M%S")
else
    # 转换 2025-09-11T03:26:10Z => 20250911032610
    TIMESTAMP=$(echo $TIMESTAMP | sed 's/[-T:]//g; s/Z$//')
fi

PSEUDO="v0.0.0-${TIMESTAMP}-${SHA:0:12}"

echo "✅ Pseudo-version: $PSEUDO"
echo "Use in go.mod:"
echo "replace open-cluster-management.io/sdk-go => $REPO $PSEUDO"