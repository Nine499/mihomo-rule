#!/usr/bin/env bash
set -euo pipefail

# 下载列表：前面是下载链接，后面是文件名
downloads=(
  "https://ruleset.skk.moe/Clash/ip/china_ip.txt|cnipv4.txt"
  "https://ruleset.skk.moe/Clash/ip/china_ip_ipv6.txt|cnipv6.txt"
  "https://core.telegram.org/resources/cidr.txt|tgip.txt"
  "https://ruleset.skk.moe/Clash/domainset/cdn.txt|cdn_domain.txt"
  "https://ruleset.skk.moe/Clash/non_ip/cdn.txt|cdn_classical.txt"
  "https://ruleset.skk.moe/Clash/non_ip/global.txt|global.txt"
  "https://ruleset.skk.moe/Clash/non_ip/domestic.txt|domestic.txt"
  "https://ruleset.skk.moe/Clash/non_ip/ai.txt|ai.txt"
)

tmp_dir="./tmp-rule"
mkdir -p "$tmp_dir"

for entry in "${downloads[@]}"; do
  IFS='|' read -r url filename <<< "$entry"
  dest="$tmp_dir/$filename"
  echo "Downloading $url -> $dest"
  curl -fL -H "User-Agent: clash" -o "$dest" "$url"
done

echo "All files downloaded to $tmp_dir."
