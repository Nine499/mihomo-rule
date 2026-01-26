#!/bin/bash
################################################################################
# 网络规则下载脚本
# 功能：从多个 URL 下载网络规则文件到 tmp 目录
# 使用方法：./curl-rule.sh
################################################################################

# 下载配置
MAX_RETRIES=3          # 最大重试次数
TIMEOUT=15             # 连接超时（秒）
TEMP_DIR="tmp"         # 临时目录

# 初始化计数器
success_count=0
failed_count=0

# 创建临时目录
mkdir -p "$TEMP_DIR" || exit 1

# 下载单个文件
download_file() {
    local url="$1"
    local output="$2"
    local num="$3"
    local total="$4"

    echo "[$num/$total] 下载 $(basename "$output")"

    # 重试下载
    for ((retry=1; retry<=MAX_RETRIES; retry++)); do
        if curl -fsSL --connect-timeout "$TIMEOUT" "$url" -o "$output" 2>/dev/null; then
            echo "✅ 下载成功"
            ((success_count++))
            return 0
        fi
        echo "⚠️  第 $retry 次失败"
    done

    echo "❌ 下载失败: $(basename "$output")"
    ((failed_count++))
    return 1
}

# 下载列表（URL|输出文件）
downloads=(
    "https://ruleset.skk.moe/Clash/ip/china_ip.txt|tmp/cnipv4.txt"
    "https://ruleset.skk.moe/Clash/ip/china_ip_ipv6.txt|tmp/cnipv6.txt"
    "https://core.telegram.org/resources/cidr.txt|tmp/tgip.txt"
    "https://ruleset.skk.moe/Clash/domainset/cdn.txt|tmp/cdn_domain.txt"
    "https://ruleset.skk.moe/Clash/non_ip/cdn.txt|tmp/cdn_classical.txt"
    "https://ruleset.skk.moe/Clash/non_ip/global.txt|tmp/global.txt"
    "https://ruleset.skk.moe/Clash/non_ip/domestic.txt|tmp/domestic.txt"
    "https://ruleset.skk.moe/Clash/non_ip/lan.txt|tmp/lan_classical.txt"
    "https://ruleset.skk.moe/Clash/ip/lan.txt|tmp/lan_ip.txt"
)

# 开始下载
echo "🌐 开始下载规则集"
echo ""

total=${#downloads[@]}
for i in "${!downloads[@]}"; do
    IFS='|' read -r url file <<< "${downloads[$i]}"
    download_file "$url" "$file" $((i+1)) "$total"
    echo ""
done

# 输出统计
echo "📊 下载完成"
echo "✅ 成功: $success_count | ❌ 失败: $failed_count | 📦 总数: $total"
echo ""

# 提示下一步
if [ $failed_count -eq 0 ]; then
    echo "✅ 所有文件下载成功，可以运行 ./process-rule.sh 处理"
else
    echo "⚠️  部分文件下载失败，检查网络后重新运行此脚本"
fi
