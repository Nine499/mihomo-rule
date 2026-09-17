#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG="$SCRIPT_DIR/config/sources.conf"

source "$SCRIPT_DIR/lib/git-ops.sh"
source "$SCRIPT_DIR/lib/report.sh"

readonly REPORT_TITLE='## Rule 更新报告'
readonly NO_CHANGE_MESSAGE='所有规则文件均无变化,未创建 commit,未执行 push。'

# 从配置文件读取所有目标文件名
get_targets() {
  local line target
  while IFS= read -r line; do
    [[ -z "$line" || "$line" == \#* ]] && continue
    target="${line%%|*}"
    printf '%s\n' "$target"
  done < "$CONFIG"
}

main() {
  local -a targets
  mapfile -t targets < <(get_targets)

  git_stage "${targets[@]}"
  git_configure_bot_identity

  local report="$REPORT_TITLE"$'\n\n'
  report+=$'| 文件 | 状态 | 新增 | 删除 |\n'
  report+=$'|---|---|---:|---:|\n'

  local changed=0 binary=0 total_add=0 total_del=0
  local file stats added deleted

  for file in "${targets[@]}"; do
    stats="$(git_diff_stat "$file")"
    if [[ -z "$stats" ]]; then
      report+="$(report_row "$file" '无变化' 0 0)"
      continue
    fi

    changed=$((changed + 1))
    IFS=$'\t' read -r added deleted _ <<< "$stats"

    if [[ "$added" == '-' ]]; then
      binary=$((binary + 1))
      report+="$(report_row "$file" '已更新(二进制)' '-' '-')"
      continue
    fi

    report+="$(report_row "$file" '已更新' "$added" "$deleted")"
    total_add=$((total_add + added))
    total_del=$((total_del + deleted))
  done

  local unchanged=$(( ${#targets[@]} - changed ))
  report+=$'\n'
  report+="**统计:** 检查 ${#targets[@]} 个文件,更新 $changed 个,未变化 $unchanged 个;新增 $total_add 行,删除 $total_del 行。"
  emit "$report"

  if [[ "$changed" -eq 0 ]]; then
    emit $'\n**结果:** '"$NO_CHANGE_MESSAGE"
    exit 0
  fi

  local msg
  msg="$(date '+%Y-%m-%d %H:%M:%S') | ${changed} files changed, +${total_add}/-${total_del}"
  [[ "$binary" -gt 0 ]] && msg+=" (${binary} binary)"

  if git_commit "$msg" "${targets[@]}"; then
    emit $'\n**结果:** 已创建 commit,正在 push。'
  else
    emit $'\n**结果:** commit 失败,未执行 push。'
    exit 1
  fi

  if git_push; then
    emit $'\n**Push:** 已完成。'
  else
    emit $'\n**Push:** 失败。'
    exit 1
  fi
}

main "$@"
