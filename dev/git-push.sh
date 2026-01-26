#!/bin/bash
################################################################################
# Git 自动提交脚本
# 功能：自动添加、提交并推送 bot-mihomo 目录的更改到远程仓库
# 使用方法：./git-push.sh
################################################################################

# Git 配置
GIT_EMAIL="deceit-bucket-shy@duck.com"
GIT_USERNAME="Nine_Action_bot"
TARGET_DIR="bot-mihomo"

# 检查是否为 Git 仓库
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ 当前目录不是 Git 仓库"
    exit 1
fi

# 配置 Git 用户信息
git config --local user.email "$GIT_EMAIL"
git config --local user.name "$GIT_USERNAME"

# 检查目标目录
if [ ! -d "$TARGET_DIR" ]; then
    echo "❌ 目标目录不存在: $TARGET_DIR"
    echo "💡 请先运行 ./process-rule.sh 生成规则文件"
    exit 1
fi

# 添加文件到暂存区
git add "$TARGET_DIR" || exit 1

# 检查是否有更改
if git diff --cached --quiet 2>/dev/null; then
    echo "ℹ️  没有需要提交的更改"
    exit 0
fi

# 显示更改的文件
echo "📝 变更的文件："
git diff --cached --name-status | head -20
echo ""

# 提交更改
commit_msg="🤖 自动更新规则 $(date '+%Y-%m-%d %H:%M:%S')"
git commit -m "$commit_msg" || exit 1

echo "✅ 提交成功"

# 推送到远程仓库
echo "🚀 推送到远程仓库..."
if git push 2>/dev/null; then
    echo "✅ 推送成功"
else
    echo "❌ 推送失败"
    echo "💡 可能原因：网络问题、权限不足或需要先拉取远程更新"
    echo "💡 可以手动执行: git push"
    exit 1
fi
