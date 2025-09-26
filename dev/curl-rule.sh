# 设置最大重试次数
MAX_RETRIES=3

# 创建临时目录
mkdir -p tmp

# 定义下载函数，包含重试逻辑
download_with_retry() {
    local url="$1"
    local output="$2"
    local retry_count=0

    until curl -fsSL -o "$output" "$url" || [ $retry_count -ge $MAX_RETRIES ]; do
        retry_count=$((retry_count + 1))
        echo "下载失败: $url (尝试 $retry_count/$MAX_RETRIES)"
        if [ $retry_count -lt $MAX_RETRIES ]; then
            echo "等待 2 秒后重试..."
            sleep 2
        fi
    done

    if [ $retry_count -ge $MAX_RETRIES ]; then
        echo "错误: 下载 $url 失败，已达到最大重试次数 $MAX_RETRIES。"
        # 可选：退出脚本
        # exit 1
    else
        echo "成功下载: $url"
    fi
}

# 下载规则文件
echo "开始下载规则..."
download_with_retry "https://ruleset.skk.moe/Clash/ip/china_ip.txt" "tmp/cnipv4.txt"
download_with_retry "https://ruleset.skk.moe/Clash/ip/china_ip_ipv6.txt" "tmp/cnipv6.txt"
download_with_retry "https://core.telegram.org/resources/cidr.txt" "tmp/tgip.txt"
download_with_retry "https://ruleset.skk.moe/Clash/non_ip/ai.txt" "tmp/ai.txt"
download_with_retry "https://ruleset.skk.moe/Clash/domainset/cdn.txt" "tmp/cdn1.txt"
download_with_retry "https://ruleset.skk.moe/Clash/non_ip/cdn.txt" "tmp/cdn2.txt"
download_with_retry "https://ruleset.skk.moe/Clash/non_ip/global.txt" "tmp/global.txt"
download_with_retry "https://ruleset.skk.moe/Clash/non_ip/domestic.txt" "tmp/domestic.txt"
download_with_retry "https://ruleset.skk.moe/Clash/non_ip/lan.txt" "tmp/lan1.txt"
download_with_retry "https://ruleset.skk.moe/Clash/ip/lan.txt" "tmp/lan2.txt"
echo "下载完成。"
