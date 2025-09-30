#!/bin/bash

# 定义带重试机制的下载函数
download_with_retry() {
    local url="$1"
    local output="$2"
    local max_retries=3
    local delay=2

    mkdir -p "$(dirname "$output")"

    for ((i=1; i<=max_retries; i++)); do
        echo "尝试下载: $url (第 $i 次)"
        if curl -fsSL --connect-timeout 10 --retry 0 "$url" -o "$output"; then
            echo "✅ 下载成功: $output"
            return 0
        else
            echo "❌ 下载失败: $url"
            if [ $i -lt $max_retries ]; then
                echo "等待 ${delay} 秒后重试..."
                sleep $delay
            fi
        fi
    done

    echo "⚠️ 最终下载失败: $url"
    return 1
}

# 执行下载任务
download_with_retry "https://ruleset.skk.moe/Clash/ip/china_ip.txt" "tmp/cnipv4.txt"
download_with_retry "https://ruleset.skk.moe/Clash/ip/china_ip_ipv6.txt" "tmp/cnipv6.txt"
download_with_retry "https://core.telegram.org/resources/cidr.txt" "tmp/tgip.txt"
download_with_retry "https://ruleset.skk.moe/Clash/domainset/cdn.txt" "tmp/cdn_domain.txt"
download_with_retry "https://ruleset.skk.moe/Clash/non_ip/cdn.txt" "tmp/cdn_classical.txt"
download_with_retry "https://ruleset.skk.moe/Clash/non_ip/global.txt" "tmp/global.txt"
download_with_retry "https://ruleset.skk.moe/Clash/non_ip/domestic.txt" "tmp/domestic.txt"
download_with_retry "https://ruleset.skk.moe/Clash/non_ip/lan.txt" "tmp/lan_classical.txt"
download_with_retry "https://ruleset.skk.moe/Clash/ip/lan.txt" "tmp/lan_ip.txt"
