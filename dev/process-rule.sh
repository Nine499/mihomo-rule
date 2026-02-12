#!/bin/bash
set -euo pipefail

# ============================================================================
# 规则处理脚本
# 功能：处理下载的规则文件，合并、复制到目标目录，并清理临时文件
# ============================================================================

# ----------------------------------------------------------------------------
# 配置区域
# ----------------------------------------------------------------------------
readonly INPUT_DIR="tmp"
readonly OUTPUT_DIR="bot-mihomo"

# ----------------------------------------------------------------------------
# 函数定义
# ----------------------------------------------------------------------------

log_info()  { echo -e "\033[32m[INFO]\033[0m $*"; }
log_warn()  { echo -e "\033[33m[WARN]\033[0m $*"; }
log_error() { echo -e "\033[31m[ERROR]\033[0m $*"; }

# 合并多个文件
merge_files() {
    local output="$1"
    local desc="$2"
    shift 2
    local sources=("$@")
    
    # 检查所有源文件
    for src in "${sources[@]}"; do
        if [[ ! -f "$src" ]]; then
            log_warn "跳过 [$desc]: 缺失文件 $(basename "$src")"
            return 1
        fi
    done
    
    # 合并文件（去重）
    cat "${sources[@]}" | sort -u > "$output"
    log_info "合并完成 [$desc] ($(wc -l < "$output") 行)"
    return 0
}

# 复制单个文件
copy_file() {
    local src="$1"
    local dst="$2"
    local desc="$3"
    
    if [[ ! -f "$src" ]]; then
        log_warn "跳过 [$desc]: 源文件不存在"
        return 1
    fi
    
    cp "$src" "$dst"
    log_info "复制完成 [$desc] ($(wc -l < "$dst") 行)"
    return 0
}

# ----------------------------------------------------------------------------
# 主流程
# ----------------------------------------------------------------------------

echo ""
echo "=========================================="
echo "       开始处理规则文件"
echo "=========================================="
echo ""

# 检查输入目录
if [[ ! -d "$INPUT_DIR" ]]; then
    log_error "输入目录不存在: $INPUT_DIR"
    log_info "请先运行 ./curl-rule.sh 下载规则文件"
    exit 1
fi

# 创建输出目录结构
mkdir -p "$OUTPUT_DIR"/{domain,classical,ip}

# 统计
success=0
failed=0

# ---- IP 规则 ----
merge_files "$OUTPUT_DIR/ip/cn.txt" "中国 IP" "$INPUT_DIR/cnipv4.txt" "$INPUT_DIR/cnipv6.txt" && ((success++)) || ((failed++))
copy_file "$INPUT_DIR/tgip.txt" "$OUTPUT_DIR/ip/tgip.txt" "Telegram IP" && ((success++)) || ((failed++))

# ---- 域名规则 ----
copy_file "$INPUT_DIR/cdn_domain.txt" "$OUTPUT_DIR/domain/cdn.txt" "CDN 域名" && ((success++)) || ((failed++))

# ---- 经典规则 ----
copy_file "$INPUT_DIR/cdn_classical.txt" "$OUTPUT_DIR/classical/cdn.txt" "CDN 规则" && ((success++)) || ((failed++))
copy_file "$INPUT_DIR/global.txt" "$OUTPUT_DIR/classical/global.txt" "全球规则" && ((success++)) || ((failed++))
copy_file "$INPUT_DIR/domestic.txt" "$OUTPUT_DIR/classical/cn.txt" "国内规则" && ((success++)) || ((failed++))
merge_files "$OUTPUT_DIR/classical/lan.txt" "局域网" "$INPUT_DIR/lan_classical.txt" "$INPUT_DIR/lan_ip.txt" && ((success++)) || ((failed++))
copy_file "$INPUT_DIR/ai.txt" "$OUTPUT_DIR/classical/ai.txt" "AI 规则" && ((success++)) || ((failed++))

# ---- 清理临时文件 ----
echo ""
log_info "清理临时目录: $INPUT_DIR"
rm -rf "$INPUT_DIR"

echo ""
echo "=========================================="
echo " 处理完成: 成功 $success / 失败 $failed"
echo "=========================================="
echo ""

if [[ $failed -gt 0 ]]; then
    log_warn "部分文件处理失败，建议重新下载"
    exit 1
fi

log_info "所有文件处理成功，可以运行 ./git-push.sh 提交"
