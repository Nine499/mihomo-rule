#!/bin/bash
################################################################################
# 规则处理脚本
# 功能：处理下载的规则文件，合并、复制到目标目录
# 使用方法：./process-rule.sh
################################################################################

# 目录配置
INPUT_DIR="tmp"
OUTPUT_DIR="bot-mihomo"

# 初始化计数器
success_count=0
failed_count=0
skipped_count=0

# 检查输入目录
if [ ! -d "$INPUT_DIR" ]; then
    echo "❌ 输入目录不存在: $INPUT_DIR"
    echo "💡 请先运行 ./curl-rule.sh 下载规则文件"
    exit 1
fi

# 创建输出目录
mkdir -p "$OUTPUT_DIR"/{domain,classical,ip} || exit 1

# 合并文件函数
merge_files() {
    local src_files="$1"
    local dst_file="$2"
    local desc="$3"

    # 检查所有源文件是否存在
    for file in $src_files; do
        if [ ! -f "$file" ]; then
            echo "⚠️  跳过 $desc: 缺失文件 $file"
            ((skipped_count++))
            return 1
        fi
    done

    # 合并文件
    if cat $src_files > "$dst_file" 2>/dev/null; then
        echo "✅ $desc"
        ((success_count++))
        return 0
    else
        echo "❌ $desc: 合并失败"
        ((failed_count++))
        return 1
    fi
}

# 复制文件函数
copy_file() {
    local src_file="$1"
    local dst_file="$2"
    local desc="$3"

    if [ ! -f "$src_file" ]; then
        echo "⚠️  跳过 $desc: 源文件不存在"
        ((skipped_count++))
        return 1
    fi

    if cp "$src_file" "$dst_file" 2>/dev/null; then
        echo "✅ $desc"
        ((success_count++))
        return 0
    else
        echo "❌ $desc: 复制失败"
        ((failed_count++))
        return 1
    fi
}

# 处理规则文件
echo "🔄 开始处理规则文件"
echo ""

# 合并中国 IP 规则
merge_files "tmp/cnipv4.txt tmp/cnipv6.txt" "bot-mihomo/ip/cn.txt" "中国 IP 规则"

# 复制 Telegram IP 规则
copy_file "tmp/tgip.txt" "bot-mihomo/ip/tgip.txt" "Telegram IP 规则"

# 复制 CDN 域名规则
copy_file "tmp/cdn_domain.txt" "bot-mihomo/domain/cdn.txt" "CDN 域名规则"

# 复制 CDN 经典规则
copy_file "tmp/cdn_classical.txt" "bot-mihomo/classical/cdn.txt" "CDN 经典规则"

# 复制全局规则
copy_file "tmp/global.txt" "bot-mihomo/classical/global.txt" "全局规则"

# 复制国内规则
copy_file "tmp/domestic.txt" "bot-mihomo/classical/cn.txt" "国内规则"

# 合并局域网规则
merge_files "tmp/lan_classical.txt tmp/lan_ip.txt" "bot-mihomo/classical/lan.txt" "局域网规则"

# 复制 AI 规则
copy_file "tmp/ai.txt" "bot-mihomo/classical/ai.txt" "AI 规则"

# 输出统计
echo ""
echo "📊 处理完成"
echo "✅ 成功: $success_count | ❌ 失败: $failed_count | ⚠️  跳过: $skipped_count"
echo ""

# 提示下一步
if [ $failed_count -eq 0 ] && [ $skipped_count -eq 0 ]; then
    echo "✅ 所有文件处理成功，可以运行 ./git-push.sh 提交"
elif [ $failed_count -eq 0 ]; then
    echo "⚠️  部分文件被跳过，已处理的文件可以提交"
else
    echo "⚠️  有文件处理失败，建议重新运行 ./curl-rule.sh 下载"
fi
