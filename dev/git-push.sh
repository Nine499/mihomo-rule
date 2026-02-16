#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

# 这个脚本只提交 bot-mihomo/ 的变更，并推送到当前分支。

readonly TARGET_DIR="bot-mihomo"
readonly GIT_EMAIL="deceit-bucket-shy@duck.com"
readonly GIT_USERNAME="Nine_Action_bot"

info() { log_info "$*"; }
err() { log_error "$*"; }

main() {
  local commit_msg

  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    err "当前目录不是 Git 仓库"
    exit 1
  fi

  if [[ ! -d "$TARGET_DIR" ]]; then
    err "找不到目录: $TARGET_DIR"
    err "请先运行 ./dev/process-rule.sh"
    exit 1
  fi

  git config --local user.email "$GIT_EMAIL"
  git config --local user.name "$GIT_USERNAME"

  git add "$TARGET_DIR"

  if git diff --cached --quiet; then
    info "没有可提交的变更"
    exit 0
  fi

  info "本次变更："
  git diff --cached --stat

  commit_msg="auto: update rules $(date '+%Y-%m-%d %H:%M:%S')"
  git commit -m "$commit_msg"
  info "提交成功: $commit_msg"

  git push
  info "推送成功"
}

main "$@"
