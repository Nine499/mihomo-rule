#!/bin/bash
# 网络规则下载脚本 - 小白友好版
# 用于下载各种网络代理规则集，支持自动重试
# 使用方法：直接运行 ./curl-rule.sh

echo "🌐 开始下载网络规则集..."
echo "📅 时间: $(TZ='Asia/Shanghai' date '+%Y-%m-%d %H:%M:%S')"

# 设置基本参数
MAX_RETRIES=3  # 下载失败时重试次数
TIMEOUT=15     # 网络超时时间(秒)

# 创建临时目录
mkdir -p tmp

# 简单的下载函数
download_file() {
    local url="$1"
    local output="$2"
    local desc="$3"

    echo "⬇️  正在下载: $desc"

    # 尝试下载，最多重试3次
    for ((i=1; i<=MAX_RETRIES; i++)); do
        if curl -fsSL --connect-timeout "$TIMEOUT" "$url" -o "$output"; then
            echo "✅ 下载成功: $desc"
            return 0
        else
            echo "❌ 第${i}次下载失败: $desc"
            if [ $i -lt $MAX_RETRIES ]; then
                echo "⏳ 等待3秒后重试..."
                sleep 3
            fi
        fi
    done

    echo "⚠️ 下载彻底失败: $desc"
    return 1
}

# 下载列表：URL|输出文件|描述
downloads=(
    "https://ruleset.skk.moe/Clash/ip/china_ip.txt|tmp/cnipv4.txt|中国IPv4地址"
    "https://ruleset.skk.moe/Clash/ip/china_ip_ipv6.txt|tmp/cnipv6.txt|中国IPv6地址"
    "https://core.telegram.org/resources/cidr.txt|tmp/tgip.txt|Telegram IP地址"
    "https://ruleset.skk.moe/Clash/domainset/cdn.txt|tmp/cdn_domain.txt|CDN域名列表"
    "https://ruleset.skk.moe/Clash/non_ip/cdn.txt|tmp/cdn_classical.txt|CDN规则"
    "https://ruleset.skk.moe/Clash/non_ip/global.txt|tmp/global.txt|全局规则"
    "https://ruleset.skk.moe/Clash/non_ip/domestic.txt|tmp/domestic.txt|国内规则"
    "https://ruleset.skk.moe/Clash/non_ip/lan.txt|tmp/lan_classical.txt|局域网规则"
    "https://ruleset.skk.moe/Clash/ip/lan.txt|tmp/lan_ip.txt|局域网IP"
)

# 统计变量
total=${#downloads[@]}
success=0
failed=0

echo "📋 准备下载 $total 个文件..."

# 开始下载所有文件
for i in "${!downloads[@]}"; do
    download="${downloads[$i]}"
    IFS='|' read -r url file desc <<< "$download"

    echo ""
    echo "📦 进度: $((i+1))/$total"

    if download_file "$url" "$file" "$desc"; then
        ((success++))
    else
        ((failed++))
    fi
done

# 显示结果统计
echo ""
echo "📊 下载完成统计:"
echo "✅ 成功: $success 个"
echo "❌ 失败: $failed 个"
echo "📁 文件保存在: tmp/ 目录"

if [ $failed -gt 0 ]; then
    echo "⚠️ 有文件下载失败，请检查网络连接"
    exit 1
else
    echo "🎉 所有文件下载成功！"
    exit 0
fi
