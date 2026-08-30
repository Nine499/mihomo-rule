#!/usr/bin/env bash
set -euo pipefail

readonly CHINA_IPV4_URL='https://ruleset.skk.moe/Clash/ip/china_ip.txt'
readonly TELEGRAM_IP_URL='https://core.telegram.org/resources/cidr.txt'
readonly LAN_IP_URL='https://ruleset.skk.moe/Clash/ip/lan.txt'
readonly LAN_DOMAIN_URL='https://ruleset.skk.moe/Clash/non_ip/lan.txt'

main() {
  local tmp_dir
  tmp_dir="$(mktemp -d)"
  trap 'rm -rf -- "${tmp_dir:-}"' EXIT

  # 先完整下载到临时目录，全部成功后再覆盖仓库文件。
  curl -fsSL -o "$tmp_dir/chinaIP-ipv4" "$CHINA_IPV4_URL"
  curl -fsSL -o "$tmp_dir/telegram.ip" "$TELEGRAM_IP_URL"
  curl -fsSL -o "$tmp_dir/lan-ip" "$LAN_IP_URL"
  curl -fsSL -o "$tmp_dir/lan-domain" "$LAN_DOMAIN_URL"
  mv "$tmp_dir/chinaIP-ipv4" "$tmp_dir/chinaIP.ip"
  cat "$tmp_dir/lan-ip" "$tmp_dir/lan-domain" > "$tmp_dir/LAN.classical"

  mv "$tmp_dir/chinaIP.ip" chinaIP.ip
  mv "$tmp_dir/telegram.ip" telegram.ip
  mv "$tmp_dir/LAN.classical" LAN.classical
}

main "$@"
