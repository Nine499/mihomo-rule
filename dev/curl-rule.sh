set -euo pipefail  # 增强脚本安全性：遇到错误立即退出，未定义变量报错

# 定义下载函数，支持重试机制
download_with_retry() {
    local url="$1"
    local output="$2"
    local max_retries=3
    local delay=2

    mkdir -p "$(dirname "$output")"  # 确保输出目录存在

    for ((attempt=1; attempt<=max_retries; attempt++)); do
        echo "尝试下载: $url (第 $attempt 次)"
        if curl -fsSL --connect-timeout 10 --retry 0 "$url" -o "$output"; then
            echo "✅ 下载成功: $output"
            return 0
        else
            echo "❌ 下载失败: $url"
            if [ $attempt -lt $max_retries ]; then
                echo "等待 ${delay} 秒后重试..."
                sleep $delay
            fi
        fi
    done

    echo "⚠️  最终下载失败: $url"
    return 1
}

# 定义下载任务列表
download_tasks=(
    "https://ruleset.skk.moe/Clash/ip/china_ip.txt tmp/cnipv4.txt"
    "https://core.telegram.org/resources/cidr.txt tmp/tgip.txt"
    "https://ruleset.skk.moe/Clash/domainset/cdn.txt tmp/cdn_domain.txt"
    "https://ruleset.skk.moe/Clash/non_ip/cdn.txt tmp/cdn_classical.txt"
    "https://ruleset.skk.moe/Clash/non_ip/global.txt tmp/global.txt"
    "https://ruleset.skk.moe/Clash/non_ip/domestic.txt tmp/domestic.txt"
    "https://ruleset.skk.moe/Clash/non_ip/lan.txt tmp/lan_classical.txt"
    "https://ruleset.skk.moe/Clash/ip/lan.txt tmp/lan_ip.txt"
)

# 执行所有下载任务
for task in "${download_tasks[@]}"; do
    url="${task%% *}"       # 提取 URL
    output="${task#* }"     # 提取输出路径
    download_with_retry "$url" "$output"
done

echo "🎉 所有下载任务完成！"
