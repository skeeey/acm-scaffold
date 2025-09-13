#!/bin/bash

# Configurable parameters
NAMESPACE="maestro"
GREP_PATTERN="registered"
SKIP_PATTERN="maestro-db-"  # Pods containing this string will be skipped

echo "🔍 Searching logs in namespace '$NAMESPACE' for pattern '$GREP_PATTERN' (skipping pods with '$SKIP_PATTERN')..."
echo "========================================"

kubectl -n "$NAMESPACE" get pods

# Get all pod names, excluding those matching SKIP_PATTERN
PODS=$(kubectl -n "$NAMESPACE" get pods --no-headers 2>/dev/null | awk '{print $1}' | grep -v "$SKIP_PATTERN")

if [[ -z "$PODS" ]]; then
    echo "❌ No eligible pods found."
    exit 1
fi

FOUND=false
MATCHED_PODS=()  # Array to record pods that matched the pattern

# Iterate through each pod
for POD in $PODS; do
    echo "🔎 Checking pod: $POD"

    # Fetch logs and filter by pattern
    LOG_LINES=$(kubectl -n "$NAMESPACE" logs "$POD" 2>/dev/null | grep --color=never "$GREP_PATTERN")

    if [[ -n "$LOG_LINES" ]]; then
        FOUND=true
        MATCHED_PODS+=("$POD")  # Record matched pod name
        echo "----------------------------------------"
        while IFS= read -r line; do
            echo "   $line"
        done <<< "$LOG_LINES"
        echo "----------------------------------------"
        echo
    else
        echo "----------------------------------------"
        echo "⚠️  No matches found"
        echo "----------------------------------------"
    fi
done

# Final summary
if [[ "$FOUND" == false ]]; then
    echo "📭 Pattern '$GREP_PATTERN' not found in any pod logs."
else
    echo "🎉 Search completed. Matching pods:"
    for pod in "${MATCHED_PODS[@]}"; do
        echo "   • $pod"
    done
fi