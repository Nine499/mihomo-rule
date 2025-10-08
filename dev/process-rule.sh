#!/bin/bash

echo "🔄 开始处理规则文件..."

# 创建输出目录
mkdir -p bot-mihomo/{domain,classical,ip}

# 中国 IPv4
cat tmp/cnipv4.txt > bot-mihomo/ip/cn.txt

# Telegram IP
cp tmp/tgip.txt bot-mihomo/ip/tgip.txt

# CDN 规则：domain 类型 和 classical 类型
cp tmp/cdn_domain.txt bot-mihomo/domain/cdn.txt
cp tmp/cdn_classical.txt bot-mihomo/classical/cdn.txt

# 全局与国内规则
cp tmp/global.txt bot-mihomo/classical/global.txt
cp tmp/domestic.txt bot-mihomo/classical/cn.txt

# LAN 规则合并（classical）
cat tmp/lan_classical.txt tmp/lan_ip.txt > bot-mihomo/classical/lan.txt

echo "✅ 规则处理完成！输出目录：bot-mihomo/"
