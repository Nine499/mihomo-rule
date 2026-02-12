#!/bin/bash
set -euo pipefail

# 这个脚本负责把 tmp/ 的下载结果整理到 bot-mihomo/。
# 缺文件会记为失败，最后统一给出统计。

readonly INPUT_DIR="tmp"
readonly OUTPUT_DIR="bot-mihomo"

info() { printf '[INFO] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*"; }
err() { printf '[ERROR] %s\n' "$*"; }

copy_rule() {
  local src="$1"
  local dst="$2"
  local name="$3"

  if [[ ! -f "$src" ]]; then
    warn "跳过: $name (缺少文件 $(basename "$src"))"
    return 1
  fi

  cp "$src" "$dst"
  info "复制完成: $name ($(wc -l < "$dst") 行)"
  return 0
}

merge_rules() {
  local dst="$1"
  local name="$2"
  shift 2
  local src

  for src in "$@"; do
    if [[ ! -f "$src" ]]; then
      warn "跳过: $name (缺少文件 $(basename "$src"))"
      return 1
    fi
  done

  sort -u "$@" > "$dst"
  info "合并完成: $name ($(wc -l < "$dst") 行)"
  return 0
}

main() {
  local success failed

  if [[ ! -d "$INPUT_DIR" ]]; then
    err "找不到输入目录: $INPUT_DIR"
    err "请先运行 ./dev/curl-rule.sh"
    exit 1
  fi

  mkdir -p "$OUTPUT_DIR/ip" "$OUTPUT_DIR/domain" "$OUTPUT_DIR/classical"

  success=0
  failed=0

  merge_rules "$OUTPUT_DIR/ip/cn.txt" "中国 IP" "$INPUT_DIR/cnipv4.txt" "$INPUT_DIR/cnipv6.txt" && success=$((success + 1)) || failed=$((failed + 1))
  copy_rule "$INPUT_DIR/tgip.txt" "$OUTPUT_DIR/ip/tgip.txt" "Telegram IP" && success=$((success + 1)) || failed=$((failed + 1))

  copy_rule "$INPUT_DIR/cdn_domain.txt" "$OUTPUT_DIR/domain/cdn.txt" "CDN 域名" && success=$((success + 1)) || failed=$((failed + 1))

  copy_rule "$INPUT_DIR/cdn_classical.txt" "$OUTPUT_DIR/classical/cdn.txt" "CDN 规则" && success=$((success + 1)) || failed=$((failed + 1))
  copy_rule "$INPUT_DIR/global.txt" "$OUTPUT_DIR/classical/global.txt" "全球规则" && success=$((success + 1)) || failed=$((failed + 1))
  copy_rule "$INPUT_DIR/domestic.txt" "$OUTPUT_DIR/classical/cn.txt" "国内规则" && success=$((success + 1)) || failed=$((failed + 1))
  merge_rules "$OUTPUT_DIR/classical/lan.txt" "局域网规则" "$INPUT_DIR/lan_classical.txt" "$INPUT_DIR/lan_ip.txt" && success=$((success + 1)) || failed=$((failed + 1))
  copy_rule "$INPUT_DIR/ai.txt" "$OUTPUT_DIR/classical/ai.txt" "AI 规则" && success=$((success + 1)) || failed=$((failed + 1))

  rm -rf "$INPUT_DIR"
  info "处理完成: 成功 $success / 失败 $failed"

  if [[ "$failed" -gt 0 ]]; then
    err "有文件处理失败，请重新下载后再试"
    exit 1
  fi
}

main "$@"
