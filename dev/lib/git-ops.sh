#!/usr/bin/env bash
# Git 操作模块：机器人身份、暂存、提交、推送封装

git_configure_bot_identity() {
  git config user.name 'Nine_Action_bot'
  git config user.email 'deceit-bucket-shy@duck.com'
}

# 暂存指定文件（-A 同时捕获新增、修改与删除）
git_stage() {
  git add -A -- "$@"
}

# 获取暂存区中某文件相对上一提交的 numstat（新增\t删除\t文件名）；无变化返回空
git_diff_stat() {
  git diff --cached --numstat -- "$1"
}

git_commit() {
  local message="$1"
  shift
  git commit -m "$message" -- "$@"
}

git_push() {
  git push
}
