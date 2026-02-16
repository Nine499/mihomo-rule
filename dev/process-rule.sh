#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

readonly INPUT_DIR="tmp"
readonly OUTPUT_DIR="bot-mihomo"

copy_rule() {
  local src="$1"
  local dst="$2"
  local name="$3"

  require_file "$src"
  cp "$src" "$dst"
  log_info "复制完成: $name ($(line_count "$dst") 行)"
}

merge_rules() {
  local dst="$1"
  local name="$2"
  shift 2
  local src

  for src in "$@"; do
    require_file "$src"
  done

  sort -u "$@" > "$dst"
  log_info "合并完成: $name ($(line_count "$dst") 行)"
}

main() {
  require_dir "$INPUT_DIR"

  mkdir -p "$OUTPUT_DIR/ip" "$OUTPUT_DIR/domain" "$OUTPUT_DIR/classical"

  merge_rules "$OUTPUT_DIR/ip/cn.txt" "中国 IP" "$INPUT_DIR/cnipv4.txt" "$INPUT_DIR/cnipv6.txt"
  copy_rule "$INPUT_DIR/tgip.txt" "$OUTPUT_DIR/ip/tgip.txt" "Telegram IP"

  copy_rule "$INPUT_DIR/cdn_domain.txt" "$OUTPUT_DIR/domain/cdn.txt" "CDN 域名"

  copy_rule "$INPUT_DIR/cdn_classical.txt" "$OUTPUT_DIR/classical/cdn.txt" "CDN 规则"
  copy_rule "$INPUT_DIR/global.txt" "$OUTPUT_DIR/classical/global.txt" "全球规则"
  copy_rule "$INPUT_DIR/domestic.txt" "$OUTPUT_DIR/classical/cn.txt" "国内规则"
  merge_rules "$OUTPUT_DIR/classical/lan.txt" "局域网规则" "$INPUT_DIR/lan_classical.txt" "$INPUT_DIR/lan_ip.txt"
  copy_rule "$INPUT_DIR/ai.txt" "$OUTPUT_DIR/classical/ai.txt" "AI 规则"

  rm -rf "$INPUT_DIR"
  log_info "处理完成"
}

main "$@"
