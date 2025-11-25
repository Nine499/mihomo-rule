#!/bin/bash

# 网络规则集下载工具
# 用于下载各种网络代理规则集，支持重试机制和错误处理
# 适用于 GitHub Actions 环境和本地使用

# 设置基本参数
set -uo pipefail  # 遇到错误或未定义变量时退出，但不因管道错误退出
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # 获取脚本所在目录
LOG_FILE="$SCRIPT_DIR/download.log"  # 日志文件路径
MAX_RETRIES=3  # 最大重试次数
RETRY_DELAY=2  # 重试延迟(秒)
TIMEOUT=10  # 连接超时时间(秒)

# 初始化日志文件
echo "===== 下载开始于 $(date) =====" > "$LOG_FILE"

# 日志函数：同时输出到控制台和日志文件
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

# 下载函数：支持重试和错误处理
download_with_retry() {
    local url="$1"
    local output="$2"
    local success=false

    # 确保输出目录存在
    mkdir -p "$(dirname "$output")"

    for ((attempt=1; attempt<=MAX_RETRIES; attempt++)); do
        log "INFO" "尝试下载: $url (第 $attempt/$MAX_RETRIES 次)"

        if curl -fsSL --connect-timeout "$TIMEOUT" --retry 0 "$url" -o "$output"; then
            log "SUCCESS" "✅ 下载成功: $output"
            success=true
            break
        else
            log "WARNING" "❌ 下载失败: $url"
            if [ $attempt -lt $MAX_RETRIES ]; then
                log "INFO" "等待 ${RETRY_DELAY} 秒后重试..."
                sleep $RETRY_DELAY
            fi
        fi
    done

    if [ "$success" = false ]; then
        log "ERROR" "⚠️ 最终下载失败: $url"
        return 1
    fi

    return 0
}

# 下载任务配置
# 格式: "URL|输出路径|描述"
# 可以轻松添加或删除下载项，只需在此列表中修改
declare -a DOWNLOAD_TASKS=(
    "https://ruleset.skk.moe/Clash/ip/china_ip.txt|tmp/cnipv4.txt|中国IPv4地址列表"
    "https://ruleset.skk.moe/Clash/ip/china_ip_ipv6.txt|tmp/cnipv6.txt|中国IPv6地址列表"
    "https://core.telegram.org/resources/cidr.txt|tmp/tgip.txt|Telegram IP列表"
    "https://ruleset.skk.moe/Clash/domainset/cdn.txt|tmp/cdn_domain.txt|CDN域名列表"
    "https://ruleset.skk.moe/Clash/non_ip/cdn.txt|tmp/cdn_classical.txt|CDN经典规则"
    "https://ruleset.skk.moe/Clash/non_ip/global.txt|tmp/global.txt|全局规则"
    "https://ruleset.skk.moe/Clash/non_ip/domestic.txt|tmp/domestic.txt|国内规则"
    "https://ruleset.skk.moe/Clash/non_ip/lan.txt|tmp/lan_classical.txt|局域网经典规则"
    "https://ruleset.skk.moe/Clash/ip/lan.txt|tmp/lan_ip.txt|局域网IP规则"
)

# 统计变量
TOTAL_TASKS=${#DOWNLOAD_TASKS[@]}
SUCCESS_COUNT=0
FAILED_COUNT=0
FAILED_TASKS=()

# 显示任务总数
log "INFO" "开始执行 $TOTAL_TASKS 个下载任务..."

# 执行所有下载任务
for i in "${!DOWNLOAD_TASKS[@]}"; do
    task="${DOWNLOAD_TASKS[$i]}"
    IFS='|' read -r url output description <<< "$task"

    log "INFO" "处理任务 $((i+1))/$TOTAL_TASKS: $description"

    if download_with_retry "$url" "$output"; then
        ((SUCCESS_COUNT++))
    else
        ((FAILED_COUNT++))
        FAILED_TASKS+=("$description")
    fi

    # 显示进度
    log "INFO" "进度: $((i+1))/$TOTAL_TASKS 完成"
done

# 显示最终摘要
log "INFO" "===== 下载任务完成 ====="
log "INFO" "总任务数: $TOTAL_TASKS"
log "INFO" "成功: $SUCCESS_COUNT"
log "INFO" "失败: $FAILED_COUNT"

if [ $FAILED_COUNT -gt 0 ]; then
    log "WARNING" "失败的任务列表:"
    for task in "${FAILED_TASKS[@]}"; do
        log "WARNING" "- $task"
    done
fi

log "INFO" "详细日志已保存到: $LOG_FILE"
log "INFO" "🎉 所有下载任务处理完成！"

# 根据失败任务数设置退出码
# 0表示全部成功，1表示部分失败，2表示全部失败
if [ $SUCCESS_COUNT -eq $TOTAL_TASKS ]; then
    exit 0
elif [ $SUCCESS_COUNT -gt 0 ]; then
    exit 1
else
    exit 2
fi
