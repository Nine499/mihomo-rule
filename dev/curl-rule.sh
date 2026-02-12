#!/bin/bash
set -euo pipefail

# 这个脚本只做一件事：把规则文件下载到 tmp/ 目录。
# 如果某个文件下载失败，会自动重试，最终失败会退出并返回非 0。

readonly TEMP_DIR="tmp"
readonly MAX_RETRIES=3
readonly CONNECT_TIMEOUT=30
readonly MAX_TIME=120

# 每一行格式：URL|输出文件|说明
readonly DOWNLOADS=(
  "https://ruleset.skk.moe/Clash/ip/china_ip.txt|$TEMP_DIR/cnipv4.txt|中国 IPv4"
  "https://ruleset.skk.moe/Clash/ip/china_ip_ipv6.txt|$TEMP_DIR/cnipv6.txt|中国 IPv6"
  "https://core.telegram.org/resources/cidr.txt|$TEMP_DIR/tgip.txt|Telegram IP"
  "https://ruleset.skk.moe/Clash/domainset/cdn.txt|$TEMP_DIR/cdn_domain.txt|CDN 域名"
  "https://ruleset.skk.moe/Clash/non_ip/cdn.txt|$TEMP_DIR/cdn_classical.txt|CDN 规则"
  "https://ruleset.skk.moe/Clash/non_ip/global.txt|$TEMP_DIR/global.txt|全球规则"
  "https://ruleset.skk.moe/Clash/non_ip/domestic.txt|$TEMP_DIR/domestic.txt|国内规则"
  "https://ruleset.skk.moe/Clash/non_ip/lan.txt|$TEMP_DIR/lan_classical.txt|局域网规则"
  "https://ruleset.skk.moe/Clash/ip/lan.txt|$TEMP_DIR/lan_ip.txt|局域网 IP"
  "https://ruleset.skk.moe/Clash/non_ip/ai.txt|$TEMP_DIR/ai.txt|AI 规则"
)

info() { printf '[INFO] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*"; }
err() { printf '[ERROR] %s\n' "$*"; }

is_valid_file() {
  local file="$1"
  local first_line

  if [[ ! -s "$file" ]]; then
    return 1
  fi

  IFS= read -r first_line < "$file" || true
  if [[ "$first_line" =~ [Hh][Tt][Mm][Ll] || "$first_line" =~ [Dd][Oo][Cc][Tt][Yy][Pp][Ee] ]]; then
    return 1
  fi

  return 0
}

download_one() {
  local url="$1"
  local output="$2"
  local name="$3"
  local attempt

  for attempt in $(seq 1 "$MAX_RETRIES"); do
    if curl -fsSL \
      --connect-timeout "$CONNECT_TIMEOUT" \
      --max-time "$MAX_TIME" \
      "$url" -o "$output"; then
      if is_valid_file "$output"; then
        info "下载成功: $name ($(wc -l < "$output") 行)"
        return 0
      fi
    fi

    warn "下载失败，重试 $attempt/$MAX_RETRIES: $name"
    sleep "$attempt"
  done

  err "下载失败: $name"
  return 1
}

main() {
  local total success failed
  local item url output name

  mkdir -p "$TEMP_DIR"

  total=${#DOWNLOADS[@]}
  success=0
  failed=0

  info "开始下载规则文件，总数: $total"

  for item in "${DOWNLOADS[@]}"; do
    IFS='|' read -r url output name <<< "$item"

    if download_one "$url" "$output" "$name"; then
      success=$((success + 1))
    else
      failed=$((failed + 1))
    fi
  done

  info "下载完成: 成功 $success / 失败 $failed / 总数 $total"

  if [[ "$failed" -gt 0 ]]; then
    err "有文件下载失败，请稍后重试"
    exit 1
  fi
}

main "$@"
