#!/bin/bash
set -euo pipefail

# ============================================================================
# Git 自动提交脚本
# 功能：自动提交并推送规则��新
# ============================================================================

# ----------------------------------------------------------------------------
# 配置区域
# ----------------------------------------------------------------------------
readonly GIT_EMAIL="deceit-bucket-shy@duck.com"
readonly GIT_USERNAME="Nine_Action_bot"
readonly TARGET_DIR="bot-mihomo"

# ----------------------------------------------------------------------------
# 函数定义
# ----------------------------------------------------------------------------

log_info()  { echo -e "\033[32m[INFO]\033[0m $*"; }
log_warn()  { echo -e "\033[33m[WARN]\033[0m $*"; }
log_error() { echo -e "\033[31m[ERROR]\033[0m $*"; }

# ----------------------------------------------------------------------------
# 主流程
# ----------------------------------------------------------------------------

echo ""
echo "=========================================="
echo "       开始 Git 提交推送"
echo "=========================================="
echo ""

# 检查 Git 仓库
if ! git rev-parse --git-dir &>/dev/null; then
    log_error "当前目录不是 Git 仓库"
    exit 1
fi

# 检查目标目录
if [[ ! -d "$TARGET_DIR" ]]; then
    log_error "目标目录不存在: $TARGET_DIR"
    log_info "请先运行 ./process-rule.sh 生成规则文件"
    exit 1
fi

# 配置 Git 用户
git config --local user.email "$GIT_EMAIL"
git config --local user.name "$GIT_USERNAME"

# 添加文件
git add "$TARGET_DIR"

# 检查是否有变更
if git diff --cached --quiet; then
    log_info "没有需要提交的更改"
    exit 0
fi

# 显示变更
echo "变更的文件："
echo "-------------------------------------------"
git diff --cached --stat
echo "-------------------------------------------"
echo ""

# 生成提交信息
commit_msg="auto: update rules $(date '+%Y-%m-%d %H:%M:%S')"

# 提交
git commit -m "$commit_msg"
log_info "提交成功: $commit_msg"

# 推送
echo ""
log_info "推送到远程仓库..."

if git push; then
    log_info "推送成功"
else
    log_error "推送失败"
    log_info "可能原因：网络问题、权限不足、需先拉取远程更新"
    exit 1
fi

echo ""
echo "=========================================="
echo "       更新完成"
echo "=========================================="
