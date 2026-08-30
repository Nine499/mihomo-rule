#!/usr/bin/env bash
set -euo pipefail

readonly CHINA_IPV4_URL='https://ruleset.skk.moe/Clash/ip/china_ip.txt'
readonly TELEGRAM_IP_URL='https://core.telegram.org/resources/cidr.txt'
readonly LAN_IP_URL='https://ruleset.skk.moe/Clash/ip/lan.txt'
readonly LAN_DOMAIN_URL='https://ruleset.skk.moe/Clash/non_ip/lan.txt'
readonly ADS_DOMAIN_URL='https://github.com/TG-Twilight/AWAvenue-Ads-Rule/raw/refs/heads/main/Filters/AWAvenue-Ads-Rule-Clash.yaml'
readonly ANTI_AD_DOMAIN_URL='https://github.com/privacy-protection-tools/anti-AD/raw/refs/heads/master/discretion/dns.txt'

main() {
  local script_dir
  local tmp_dir
  script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
  tmp_dir="$(mktemp -d)"
  trap 'rm -rf -- "${tmp_dir:-}"' EXIT

  # 先完整下载到临时目录，全部成功后再覆盖仓库文件。
  bash "$script_dir/download-yq.sh" "$tmp_dir/yq"
  curl -fsSL -o "$tmp_dir/ads.yaml" "$ADS_DOMAIN_URL"
  curl -fsSL -o "$tmp_dir/anti-ad.txt" "$ANTI_AD_DOMAIN_URL"
  curl -fsSL -o "$tmp_dir/chinaIP-ipv4" "$CHINA_IPV4_URL"
  curl -fsSL -o "$tmp_dir/telegram.ip" "$TELEGRAM_IP_URL"
  curl -fsSL -o "$tmp_dir/lan-ip" "$LAN_IP_URL"
  curl -fsSL -o "$tmp_dir/lan-domain" "$LAN_DOMAIN_URL"
  "$tmp_dir/yq" -r '.payload[]' "$tmp_dir/ads.yaml" > "$tmp_dir/ads.domain"
  cat "$tmp_dir/anti-ad.txt" >> "$tmp_dir/ads.domain"
  [[ -s "$tmp_dir/ads.domain" ]]
  mv "$tmp_dir/chinaIP-ipv4" "$tmp_dir/chinaIP.ip"
  cat "$tmp_dir/lan-ip" "$tmp_dir/lan-domain" > "$tmp_dir/LAN.classical"

  mv "$tmp_dir/chinaIP.ip" chinaIP.ip
  mv "$tmp_dir/telegram.ip" telegram.ip
  mv "$tmp_dir/LAN.classical" LAN.classical
  mv "$tmp_dir/ads.domain" ads.domain
}

main "$@"
