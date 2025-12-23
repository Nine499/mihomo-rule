#!/bin/bash
# 规则处理脚本 - 小白友好版
# 将下载的原始规则文件整理成 mihomo 可用的格式
# 使用方法：确保 tmp/ 目录有下载的文件，然后运行 ./process-rule.sh

echo "🔄 开始处理网络规则文件..."
echo "📅 时间: $(TZ='Asia/Shanghai' date '+%Y-%m-%d %H:%M:%S')"

# 检查 tmp 目录是否存在
if [ ! -d "tmp" ]; then
    echo "❌ 错误：tmp/ 目录不存在！请先运行 curl-rule.sh 下载规则文件"
    exit 1
fi

# 创建输出目录结构
echo "📁 创建输出目录..."
mkdir -p bot-mihomo/{domain,classical,ip}

# 处理中国 IP 地址规则（合并 IPv4 和 IPv6）
echo "🇨🇳 处理中国 IP 地址规则..."
if [ -f "tmp/cnipv4.txt" ] && [ -f "tmp/cnipv6.txt" ]; then
    cat tmp/cnipv4.txt tmp/cnipv6.txt > bot-mihomo/ip/cn.txt
    echo "✅ 中国 IP 规则已生成"
else
    echo "⚠️ 缺少中国 IP 文件，跳过此步骤"
fi

# 处理 Telegram IP 规则
echo "📱 处理 Telegram IP 规则..."
if [ -f "tmp/tgip.txt" ]; then
    cp tmp/tgip.txt bot-mihomo/ip/tgip.txt
    echo "✅ Telegram IP 规则已复制"
else
    echo "⚠️ 缺少 Telegram IP 文件，跳过此步骤"
fi

# 处理 CDN 规则（域名类型）
echo "🌐 处理 CDN 域名规则..."
if [ -f "tmp/cdn_domain.txt" ]; then
    cp tmp/cdn_domain.txt bot-mihomo/domain/cdn.txt
    echo "✅ CDN 域名规则已复制"
else
    echo "⚠️ 缺少 CDN 域名文件，跳过此步骤"
fi

# 处理 CDN 规则（经典类型）
echo "🌐 处理 CDN 经典规则..."
if [ -f "tmp/cdn_classical.txt" ]; then
    cp tmp/cdn_classical.txt bot-mihomo/classical/cdn.txt
    echo "✅ CDN 经典规则已复制"
else
    echo "⚠️ 缺少 CDN 经典文件，跳过此步骤"
fi

# 处理全局规则
echo "🌍 处理全局规则..."
if [ -f "tmp/global.txt" ]; then
    cp tmp/global.txt bot-mihomo/classical/global.txt
    echo "✅ 全局规则已复制"
else
    echo "⚠️ 缺少全局规则文件，跳过此步骤"
fi

# 处理国内规则
echo "🏠 处理国内规则..."
if [ -f "tmp/domestic.txt" ]; then
    cp tmp/domestic.txt bot-mihomo/classical/cn.txt
    echo "✅ 国内规则已复制"
else
    echo "⚠️ 缺少国内规则文件，跳过此步骤"
fi

# 处理局域网规则（合并经典类型和 IP 类型）
echo "🏢 处理局域网规则..."
if [ -f "tmp/lan_classical.txt" ] && [ -f "tmp/lan_ip.txt" ]; then
    cat tmp/lan_classical.txt tmp/lan_ip.txt > bot-mihomo/classical/lan.txt
    echo "✅ 局域网规则已合并生成"
else
    echo "⚠️ 缺少局域网规则文件，跳过此步骤"
fi

# 显示处理结果
echo ""
echo "📊 规则处理完成！"
echo "📁 输出目录结构："
echo "   bot-mihomo/"
echo "   ├── domain/     - 域名规则"
echo "   ├── classical/  - 经典规则"
echo "   └── ip/         - IP 规则"
echo ""
echo "🎉 所有规则文件处理完成！现在可以运行 git-push.sh 提交更改"
