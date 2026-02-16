#!/usr/bin/env bash

log_info() { printf '[INFO] %s\n' "$*"; }
log_warn() { printf '[WARN] %s\n' "$*"; }
log_error() { printf '[ERROR] %s\n' "$*"; }

die() {
  log_error "$*"
  exit 1
}

require_file() {
  local file="$1"
  [[ -f "$file" ]] || die "找不到文件: $file"
}

require_dir() {
  local dir="$1"
  [[ -d "$dir" ]] || die "找不到目录: $dir"
}

line_count() {
  local file="$1"
  require_file "$file"
  wc -l < "$file"
}
