#!/bin/bash

# 脚本信息
echo "🚀 开始执行 Git 自动提交脚本..."
echo "📅 时间: $(TZ='Asia/Shanghai' date '+%Y-%m-%d %H:%M:%S')"

# 设置 Git 配置
echo "⚙️  配置 Git 用户信息..."
git config --local user.email "deceit-bucket-shy@duck.com"
git config --local user.name "Nine_Action_bot"

# 检查是否在 Git 仓库中
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ 错误：当前目录不是 Git 仓库！"
    exit 1
fi

# 添加文件
echo "📁 添加 bot-mihomo/ 文件夹..."
git add bot-mihomo/

# 检查是否有变更
echo "🔍 检查是否有待提交的变更..."
if ! git diff --cached --quiet; then
    echo "📝 检测到变更，准备提交..."

    # 生成提交信息
    COMMIT_MSG="🤖 自动更新规则 $(TZ='Asia/Shanghai' date '+%Y-%m-%d %H:%M:%S')"
    echo "💬 提交信息: $COMMIT_MSG"

    # 执行提交
    if git commit -m "$COMMIT_MSG"; then
        echo "✅ 提交成功！"

        # 推送更改
        echo "🔄 正在推送到远程仓库..."
        if git push; then
            echo "🎉 推送成功！任务完成！"
        else
            echo "❌ 推送失败，请检查网络连接或权限"
            exit 1
        fi
    else
        echo "❌ 提交失败"
        exit 1
    fi
else
    echo "ℹ️  没有检测到变更，无需提交"
fi

echo "✨ 脚本执行完毕"
