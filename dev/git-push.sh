#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

# 这个脚本只提交 bot-mihomo/ 的变更，并推送到当前分支。

readonly TARGET_DIR="bot-mihomo"
readonly DEFAULT_GIT_USERNAME="Nine_Action_bot"
readonly DEFAULT_GIT_EMAIL="deceit-bucket-shy@duck.com"

info() { log_info "$*"; }
err() { log_error "$*"; }

main() {
  local commit_msg git_username git_email current_branch

  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    err "当前目录不是 Git 仓库"
    exit 1
  fi

  if [[ ! -d "$TARGET_DIR" ]]; then
    err "找不到目录: $TARGET_DIR"
    err "请先运行 ./dev/process-rule.sh"
    exit 1
  fi

  if git diff --cached --name-only | grep -vE "^${TARGET_DIR}/" >/dev/null; then
    err "暂存区存在非 ${TARGET_DIR}/ 的文件，请先清理暂存区"
    exit 1
  fi

  git add "$TARGET_DIR"

  if git diff --cached --name-only | grep -vE "^${TARGET_DIR}/" >/dev/null; then
    err "暂存区存在非 ${TARGET_DIR}/ 的文件，请先清理暂存区"
    exit 1
  fi

  if git diff --cached --quiet; then
    info "没有可提交的变更"
    exit 0
  fi

  git_username="${GIT_USERNAME:-$DEFAULT_GIT_USERNAME}"
  git_email="${GIT_EMAIL:-$DEFAULT_GIT_EMAIL}"

  commit_msg="auto: update rules $(date '+%Y-%m-%d %H:%M:%S')"
  git -c user.name="$git_username" -c user.email="$git_email" commit -m "$commit_msg"
  info "提交成功: $commit_msg"

  current_branch="$(git branch --show-current)"
  if [[ -z "$current_branch" ]]; then
    err "无法识别当前分支"
    exit 1
  fi

  git push origin "$current_branch"
  info "推送成功"
}

main "$@"
