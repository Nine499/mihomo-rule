#!/usr/bin/env bash
set -e

git config user.name "Nine_Action_bot"
git config user.email "deceit-bucket-shy@duck.com"

# 只 add node/providers 下所有 .yaml
find node/providers -type f -name "*.yaml" -print0 | xargs -0 git add

# add bot-mihomo 文件夹所有内容
git add bot-mihomo

# 有变更才提交
if ! git diff --cached --quiet; then
  git commit -m "更新规则文件 $(date '+%Y-%m-%d %H:%M:%S')"
  git push
else
  echo "no changes"
fi
