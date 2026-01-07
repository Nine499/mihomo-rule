#!/bin/bash
################################################################################
# Git 自动提交脚本
# 功能：自动添加、提交并推送 bot-mihomo 目录的更改到远程仓库
# 使用方法：./git-push.sh
# 特点：失败时记录错误但不退出，最后统一报告所有错误
################################################################################

# 显示开始信息
echo "=========================================="
echo "🚀 开始 Git 提交和推送"
echo "⏰ 时间: $(TZ='Asia/Shanghai' date '+%Y-%m-%d %H:%M:%S')"
echo "=========================================="
echo ""

################################################################################
# 配置参数区域
################################################################################

# Git 用户信息配置
GIT_EMAIL="deceit-bucket-shy@duck.com"
GIT_USERNAME="Nine_Action_bot"

# 要提交的目录
TARGET_DIR="bot-mihomo"

################################################################################
# 初始化变量
################################################################################

# 错误信息数组
error_messages=()

# 操作成功标志
has_changes=false
commit_success=false
push_success=false

################################################################################
# 函数定义区域
################################################################################

# 函数：检查是否为 Git 仓库
# 返回：0=是 Git 仓库, 1=不是 Git 仓库
check_git_repository() {
    echo "🔍 检查 Git 仓库状态..."

    if git rev-parse --git-dir > /dev/null 2>&1; then
        echo "✅ 当前目录是 Git 仓库"
        echo ""

        # 显示远程仓库信息
        local remote_url=$(git config --get remote.origin.url 2>/dev/null)
        if [ -n "$remote_url" ]; then
            echo "📌 远程仓库: $remote_url"
            echo ""
        fi

        return 0
    else
        local error_msg="❌ 当前目录不是 Git 仓库 | 请在 Git 仓库目录中运行此脚本"
        error_messages+=("$error_msg")
        echo "⚠️  当前目录不是 Git 仓库"
        echo "💡 请在 Git 仓库根目录中运行此脚本"
        echo ""
        return 1
    fi
}

# 函数：配置 Git 用户信息
# 返回：0=成功, 1=失败
configure_git_user() {
    echo "👤 配置 Git 用户信息..."
    echo "   邮箱: $GIT_EMAIL"
    echo "   用户名: $GIT_USERNAME"
    echo ""

    # 配置邮箱
    if git config --local user.email "$GIT_EMAIL" 2>/dev/null; then
        echo "✅ Git 邮箱配置成功"
    else
        local error_msg="❌ Git 邮箱配置失败 | 邮箱: $GIT_EMAIL"
        error_messages+=("$error_msg")
        echo "⚠️  Git 邮箱配置失败"
        echo ""
        return 1
    fi

    # 配置用户名
    if git config --local user.name "$GIT_USERNAME" 2>/dev/null; then
        echo "✅ Git 用户名配置成功"
    else
        local error_msg="❌ Git 用户名配置失败 | 用户名: $GIT_USERNAME"
        error_messages+=("$error_msg")
        echo "⚠️  Git 用户名配置失败"
        echo ""
        return 1
    fi

    echo ""
    return 0
}

# 函数：添加文件到暂存区
# 返回：0=成功, 1=失败
add_files_to_staging() {
    echo "📁 添加文件到暂存区..."
    echo "   目标目录: $TARGET_DIR"
    echo ""

    # 检查目标目录是否存在
    if [ ! -d "$TARGET_DIR" ]; then
        local error_msg="❌ 目标目录不存在 | 目录: $TARGET_DIR | 请先运行 ./process-rule.sh"
        error_messages+=("$error_msg")
        echo "⚠️  目标目录不存在: $TARGET_DIR"
        echo "💡 请先运行 ./process-rule.sh 生成规则文件"
        echo ""
        return 1
    fi

    # 添加文件到暂存区
    if git add "$TARGET_DIR" 2>/dev/null; then
        echo "✅ 文件添加到暂存区成功"
        echo ""
        return 0
    else
        local error_msg="❌ 添加文件到暂存区失败 | 目录: $TARGET_DIR"
        error_messages+=("$error_msg")
        echo "⚠️  添加文件到暂存区失败"
        echo "💡 原因: 可能是权限不足或目录不存在"
        echo ""
        return 1
    fi
}

# 函数：检查是否有更改需要提交
# 返回：0=有更改, 1=无更改
check_for_changes() {
    echo "🔍 检查是否有更改..."

    if git diff --cached --quiet 2>/dev/null; then
        echo "ℹ️  没有需要提交的更改"
        echo "💡 暂存区为空，无需提交"
        echo ""
        return 1
    else
        echo "✅ 检测到更改，准备提交"

        # 显示更改的文件列表
        echo ""
        echo "📝 更改的文件列表："
        git diff --cached --name-status | while read status file; do
            case "$status" in
                M) echo "   📝 修改: $file" ;;
                A) echo "   ➕ 新增: $file" ;;
                D) echo "   ❌ 删除: $file" ;;
                R) echo "   🔄 重命名: $file" ;;
                *) echo "   📄 其他: $file" ;;
            esac
        done
        echo ""

        has_changes=true
        return 0
    fi
}

# 函数：提交更改
# 返回：0=成功, 1=失败
commit_changes() {
    echo "📝 提交更改..."

    # 生成提交信息
    local commit_msg="🤖 自动更新规则 $(TZ='Asia/Shanghai' date '+%Y-%m-%d %H:%M:%S')"

    echo "   提交信息: $commit_msg"
    echo ""

    # 执行提交
    if git commit -m "$commit_msg" 2>/dev/null; then
        commit_success=true
        echo "✅ 提交成功"

        # 显示提交的哈希值
        local commit_hash=$(git rev-parse --short HEAD 2>/dev/null)
        if [ -n "$commit_hash" ]; then
            echo "   提交哈希: $commit_hash"
        fi
        echo ""
        return 0
    else
        local error_msg="❌ 提交失败 | 提交信息: $commit_msg"
        error_messages+=("$error_msg")
        echo "⚠️  提交失败"
        echo "💡 原因: 可能是暂存区为空或 Git 配置问题"
        echo ""
        return 1
    fi
}

# 函数：推送到远程仓库
# 返回：0=成功, 1=失败
push_to_remote() {
    echo "🚀 推送到远程仓库..."
    echo ""

    # 执行推送
    if git push 2>/dev/null; then
        push_success=true
        echo "✅ 推送成功"
        echo "💡 更改已成功推送到远程仓库"
        echo ""
        return 0
    else
        local error_msg="❌ 推送失败 | 可能原因: 网络问题、权限不足或远程仓库不存在"
        error_messages+=("$error_msg")
        echo "⚠️  推送失败"
        echo "💡 可能的原因："
        echo "   1. 网络连接问题"
        echo "   2. 没有推送到远程仓库的权限"
        echo "   3. 远程仓库不存在或 URL 配置错误"
        echo "   4. 远程仓库有新的提交，需要先拉取"
        echo ""
        return 1
    fi
}

################################################################################
# 主程序开始
################################################################################

# 步骤 1: 检查 Git 仓库
check_git_repository

# 步骤 2: 配置 Git 用户信息
configure_git_user

# 步骤 3: 添加文件到暂存区
add_files_to_staging

# 步骤 4: 检查是否有更改
if check_for_changes; then
    # 有更改，执行提交
    if commit_changes; then
        # 提交成功，尝试推送
        push_to_remote
    fi
fi

################################################################################
# 输出最终统计报告
################################################################################

echo ""
echo "=========================================="
echo "📊 操作统计报告"
echo "=========================================="
echo "⏰ 完成时间: $(TZ='Asia/Shanghai' date '+%Y-%m-%d %H:%M:%S')"

# 显示操作结果
if [ "$has_changes" = true ]; then
    if [ "$commit_success" = true ]; then
        echo "✅ 提交状态: 成功"
    else
        echo "❌ 提交状态: 失败"
    fi

    if [ "$push_success" = true ]; then
        echo "✅ 推送状态: 成功"
    else
        echo "❌ 推送状态: 失败"
    fi
else
    echo "ℹ️  提交状态: 无需提交（没有更改）"
    echo "ℹ️  推送状态: 跳过（没有需要推送的内容）"
fi

echo "=========================================="
echo ""

# 如果有错误，显示详细错误信息
if [ ${#error_messages[@]} -gt 0 ]; then
    echo "⚠️  以下操作失败："
    echo ""
    for error_msg in "${error_messages[@]}"; do
        echo "  $error_msg"
    done
    echo ""
    echo "💡 建议："
    echo "  1. 检查网络连接是否正常"
    echo "  2. 检查 Git 配置是否正确"
    echo "  3. 检查是否有足够的权限"
    echo "  4. 查看 Git 日志: git log"
    echo "  5. 查看 Git 状态: git status"
    echo ""
fi

# 显示后续操作提示
echo "📝 下一步操作："
if [ "$push_success" = true ]; then
    echo "  ✅ 所有操作完成，更改已推送到远程仓库"
elif [ "$commit_success" = true ]; then
    echo "  ⚠️  提交成功但推送失败，可以手动执行 git push"
elif [ "$has_changes" = true ]; then
    echo "  ⚠️  提交失败，请检查错误信息后重试"
else
    echo "  ℹ️  没有需要提交的更改"
fi
echo ""

# 脚本正常退出（即使有失败也不使用 exit 1）
exit 0
