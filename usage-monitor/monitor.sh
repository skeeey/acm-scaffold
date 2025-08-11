#!/bin/bash

# ================= 配置区 =================
# 要监控的 Label Selector（格式：key=value,key=value）
LABEL_SELECTOR="component=kube-apiserver"

# 命名空间
NAMESPACE="kube-system"

# 采样间隔（秒）
INTERVAL=30

# 输出日志文件
LOG_FILE="pod_usage.log"
# =========================================

echo "Starting pod usage monitor with label selector: $LABEL_SELECTOR"
echo "Namespace: $NAMESPACE"
echo "Interval: ${INTERVAL}s"
echo "Log file: $LOG_FILE"
echo "Press Ctrl+C to stop."
echo "----------------------------------------" >> "$LOG_FILE"
echo "Monitoring started at $(date)" >> "$LOG_FILE"
echo "time,pod_name,cpu_cores,memory_mb" >> "$LOG_FILE"

# 检查依赖
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl not found"
    exit 1
fi

# 主循环
while true; do
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # 获取带 label 的 kubectl top 输出
    output=$(kubectl top pods -n "$NAMESPACE" -l "$LABEL_SELECTOR" --no-headers 2>&1)
    if [ $? -ne 0 ]; then
        echo "[$timestamp] Error: Failed to get metrics - $output" | tee -a "$LOG_FILE"
        sleep $INTERVAL
        continue
    fi

    # 检查是否有匹配的 Pod
    if [ -z "$output" ]; then
        echo "[$timestamp] Warning: No pod found matching label '$LABEL_SELECTOR' in namespace '$NAMESPACE'" | tee -a "$LOG_FILE"
        sleep $INTERVAL
        continue
    fi

    # 解析每一行（每个 Pod）
    echo "$output" | while read -r pod_name cpu_usage memory_usage rest; do
        # 跳过空行
        [ -z "$pod_name" ] && continue

        # 标准化 CPU（如 100m → 0.1）
        if [[ "$cpu_usage" == *"m"* ]]; then
            cpu_std=$(echo "$cpu_usage" | sed 's/m$//' | awk '{print $1 * 0.001}')
        else
            cpu_std="$cpu_usage"
        fi

        # 标准化内存（Mi → MB 数值相同，K → MB）
        if [[ "$memory_usage" == *"Mi"* ]]; then
            memory_mb=$(echo "$memory_usage" | sed 's/Mi$//')
        elif [[ "$memory_usage" == *"Ki"* ]]; then
            memory_mb=$(echo "$memory_usage" | sed 's/Ki$//' | awk '{print $1 * 0.001}')
        else
            memory_mb="$memory_usage"
        fi

        # 输出：时间, Pod名, CPU(核), 内存(MB)
        printf "%s,%s,%.3f,%.1f\n" "$timestamp" "$pod_name" "$cpu_std" "$memory_mb" | tee -a "$LOG_FILE"
    done

    sleep $INTERVAL
done
