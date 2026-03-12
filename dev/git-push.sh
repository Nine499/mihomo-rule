#!/usr/bin/env bash
set -e

# add 必要文件
git add telegram.ip chinaIP.ip

# 增加用户信息
git config user.name "Nine_Action_bot"
git config user.email "deceit-bucket-shy@duck.com"

# 有变更才提交
if ! git diff --cached --quiet; then
  git commit -m "$(date '+%Y-%m-%d %H:%M:%S')"
  git push
else
  echo "no changes"
fi
