#!/usr/bin/env bash
set -euo pipefail

readonly TARGET_FILES=(telegram.ip chinaIP.ip LAN.classical)
readonly REPORT_TITLE='## Rule 更新报告'
readonly NO_CHANGE_MESSAGE='所有规则文件均无变化，未创建 commit，未执行 push。'

emit() {
  local content="$1"

  printf '%s\n' "$content"
  if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]] && ! printf '%s\n' "$content" >> "$GITHUB_STEP_SUMMARY"; then
    printf 'warning: 无法写入 GITHUB_STEP_SUMMARY\n' >&2
  fi
}

append_row() {
  local file="$1"
  local status="$2"
  local added="$3"
  local deleted="$4"

  report+="| \`$file\` | $status | $added | $deleted |"$'\n'
}

# 只暂存生成文件；-A 也能捕获已删除文件。
git add -A -- "${TARGET_FILES[@]}"

report="$REPORT_TITLE"$'\n\n'
report+=$'| 文件 | 状态 | 新增 | 删除 |\n'
report+=$'|---|---|---:|---:|\n'
changed_count=0
binary_count=0
total_added=0
total_deleted=0

for file in "${TARGET_FILES[@]}"; do
  stats="$(git diff --cached --numstat -- "$file")"
  if [[ -z "$stats" ]]; then
    append_row "$file" '无变化' 0 0
    continue
  fi

  IFS=$'\t' read -r added deleted _ <<< "$stats"
  changed_count=$((changed_count + 1))

  if [[ "$added" == '-' || "$deleted" == '-' ]]; then
    binary_count=$((binary_count + 1))
    append_row "$file" '已更新（二进制）' '-' '-'
    continue
  fi

  append_row "$file" '已更新' "$added" "$deleted"
  total_added=$((total_added + added))
  total_deleted=$((total_deleted + deleted))
done

unchanged_count=$(( ${#TARGET_FILES[@]} - changed_count ))
report+=$'\n'
report+="**统计：** 检查 ${#TARGET_FILES[@]} 个文件，更新 ${changed_count} 个文件，未变化 ${unchanged_count} 个文件；新增 ${total_added} 行，删除 ${total_deleted} 行。"
emit "$report"

git config user.name 'Nine_Action_bot'
git config user.email 'deceit-bucket-shy@duck.com'

if [[ "$changed_count" -eq 0 ]]; then
  emit $'\n**结果：** '"$NO_CHANGE_MESSAGE"
  exit 0
fi

commit_message="$(date '+%Y-%m-%d %H:%M:%S') | ${changed_count} files changed, +${total_added}/-${total_deleted}"
if [[ "$binary_count" -gt 0 ]]; then
  commit_message+=" (${binary_count} binary)"
fi

if git commit -m "$commit_message" -- "${TARGET_FILES[@]}"; then
  emit $'\n**结果：** 已创建 commit，正在 push。'
else
  emit $'\n**结果：** commit 失败，未执行 push。'
  exit 1
fi

if git push; then
  emit $'\n**Push：** 已完成。'
else
  emit $'\n**Push：** 失败。'
  exit 1
fi
