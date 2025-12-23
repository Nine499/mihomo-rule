#!/bin/bash
# Git 自动提交脚本 - 小白友好版
# 自动提交并推送 bot-mihomo/ 目录的更改
# 使用方法：直接运行 ./git-push.sh

echo "🚀 开始 Git 自动提交..."
echo "📅 时间: $(TZ='Asia/Shanghai' date '+%Y-%m-%d %H:%M:%S')"

# 配置 Git 用户信息（用于自动提交）
git config --local user.email "deceit-bucket-shy@duck.com"
git config --local user.name "Nine_Action_bot"

# 检查当前目录是否为 Git 仓库
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ 错误：当前目录不是 Git 仓库！"
    exit 1
fi

# 添加 bot-mihomo/ 目录到暂存区
echo "📁 添加文件到 Git..."
git add bot-mihomo/

# 检查是否有需要提交的更改
if git diff --cached --quiet; then
    echo "ℹ️  没有发现新的更改，无需提交"
    exit 0
fi

echo "📝 检测到文件更改，准备提交..."

# 生成带时间戳的提交信息
commit_msg="🤖 自动更新规则 $(TZ='Asia/Shanghai' date '+%Y-%m-%d %H:%M:%S')"
echo "💬 提交信息: $commit_msg"

# 执行提交
if git commit -m "$commit_msg"; then
    echo "✅ 提交成功！"

    # 推送到远程仓库
    echo "🔄 正在推送到远程仓库..."
    if git push; then
        echo "🎉 推送成功！所有操作完成！"
    else
        echo "❌ 推送失败，请检查网络连接或 Git 权限"
        exit 1
    fi
else
    echo "❌ 提交失败"
    exit 1
fi

echo "✨ 脚本执行完成"
