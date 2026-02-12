#!/bin/bash
set -euo pipefail

# ============================================================================
# 网络规则下载脚本
# 功能：并行下载多个规则文件，支持重试和校验
# ============================================================================

# ----------------------------------------------------------------------------
# 配置区域 - 修改这里即可
# ----------------------------------------------------------------------------
readonly MAX_RETRIES=3
readonly TIMEOUT=30
readonly TEMP_DIR="tmp"
readonly PARALLEL_JOBS=5  # 并行下载数

# 下载列表：URL|输出文件|描述
readonly DOWNLOADS=(
    "https://ruleset.skk.moe/Clash/ip/china_ip.txt|tmp/cnipv4.txt|中国 IPv4"
    "https://ruleset.skk.moe/Clash/ip/china_ip_ipv6.txt|tmp/cnipv6.txt|中国 IPv6"
    "https://core.telegram.org/resources/cidr.txt|tmp/tgip.txt|Telegram IP"
    "https://ruleset.skk.moe/Clash/domainset/cdn.txt|tmp/cdn_domain.txt|CDN 域名"
    "https://ruleset.skk.moe/Clash/non_ip/cdn.txt|tmp/cdn_classical.txt|CDN 规则"
    "https://ruleset.skk.moe/Clash/non_ip/global.txt|tmp/global.txt|全球规则"
    "https://ruleset.skk.moe/Clash/non_ip/domestic.txt|tmp/domestic.txt|国内规则"
    "https://ruleset.skk.moe/Clash/non_ip/lan.txt|tmp/lan_classical.txt|局域网规则"
    "https://ruleset.skk.moe/Clash/ip/lan.txt|tmp/lan_ip.txt|局域网 IP"
    "https://ruleset.skk.moe/Clash/non_ip/ai.txt|tmp/ai.txt|AI 规则"
)

# ----------------------------------------------------------------------------
# 函数定义
# ----------------------------------------------------------------------------

log_info()  { echo -e "\033[32m[INFO]\033[0m $*"; }
log_warn()  { echo -e "\033[33m[WARN]\033[0m $*"; }
log_error() { echo -e "\033[31m[ERROR]\033[0m $*"; }

# 校验文件有效性
validate_file() {
    local file="$1"
    
    # 检查文件是否存在且非空
    if [[ ! -s "$file" ]]; then
        log_warn "文件为空或不存在: $file"
        return 1
    fi
    
    # 检查是否为 HTML 错误页（简单检测）
    if head -1 "$file" | grep -qiE '<!doctype|<html|<head'; then
        log_warn "文件疑似 HTML 错误页: $file"
        return 1
    fi
    
    return 0
}

# 下载单个文件
download_file() {
    local url="$1"
    local output="$2"
    local desc="$3"
    
    for ((retry = 1; retry <= MAX_RETRIES; retry++)); do
        if curl -fsSL --connect-timeout "$TIMEOUT" --max-time 120 "$url" -o "$output" 2>/dev/null; then
            if validate_file "$output"; then
                log_info "下载成功 [$desc] ($(wc -l < "$output") 行)"
                return 0
            fi
        fi
        log_warn "第 $retry/$MAX_RETRIES 次重试: $desc"
        sleep $((retry * 2))
    done
    
    log_error "下载失败: $desc"
    return 1
}

# ----------------------------------------------------------------------------
# 主流程
# ----------------------------------------------------------------------------

echo ""
echo "=========================================="
echo "       开始下载规则文件"
echo "=========================================="
echo ""

# 创建临时目录
mkdir -p "$TEMP_DIR"

# 并行下载
total=${#DOWNLOADS[@]}
pids=()
results=()

for i in "${!DOWNLOADS[@]}"; do
    IFS='|' read -r url file desc <<< "${DOWNLOADS[$i]}"
    
    # 控制并行数量
    while [[ ${#pids[@]} -ge $PARALLEL_JOBS ]]; do
        wait -n
        pids=($(jobs -p 2>/dev/null || true))
    done
    
    # 后台下载
    (
        if download_file "$url" "$file" "$desc"; then
            echo "1" > "$TEMP_DIR/.result_$i"
        else
            echo "0" > "$TEMP_DIR/.result_$i"
        fi
    ) &
    pids+=($!)
done

# 等待所有下载完成
wait

# 统计结果
success=0
failed=0
for i in "${!DOWNLOADS[@]}"; do
    if [[ -f "$TEMP_DIR/.result_$i" ]] && [[ $(cat "$TEMP_DIR/.result_$i") == "1" ]]; then
        success=$((success + 1))
    else
        failed=$((failed + 1))
    fi
    rm -f "$TEMP_DIR/.result_$i"
done

echo ""
echo "=========================================="
echo " 下载完成: 成功 $success / 失败 $failed / 总数 $total"
echo "=========================================="
echo ""

if [[ $failed -gt 0 ]]; then
    log_warn "部分文件下载失败，请检查网络后重试"
    exit 1
fi

log_info "所有文件下载成功"
