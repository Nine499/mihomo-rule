#!/usr/bin/env bash
# 报告模块：生成规则更新的 Markdown 报告，同时输出到终端与 GitHub Step Summary

# 输出一行内容：打印到 stdout，并在 GITHUB_STEP_SUMMARY 存在时追加写入
emit() {
  local content="$1"
  printf '%s\n' "$content"
  [[ -n "${GITHUB_STEP_SUMMARY:-}" ]] && printf '%s\n' "$content" >> "$GITHUB_STEP_SUMMARY"
}

# 生成报告表格的一行
report_row() {
  local file="$1" status="$2" added="$3" deleted="$4"
  printf '| `%s` | %s | %s | %s |\n' "$file" "$status" "$added" "$deleted"
}
