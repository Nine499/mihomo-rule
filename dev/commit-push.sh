#!/bin/bash

MSG="自动更新"
FILES=(
  chinaIP.ip
  LAN.classical
  telegram.ip
)

git add "${FILES[@]}"

if git diff --cached --quiet; then
    echo "没有文件更新"
    exit 0
fi

git config user.name  "Nine_Action_bot"
git config user.email "deceit-bucket-shy@duck.com"

git commit -m "$MSG"
git push

echo "文件已更新"
