#!/usr/bin/env bash

# tmp-rule/ai.txt 的内容覆盖 bot-mihomo/classical/ai.txt ，bot-mihomo/classical/ai.txt文件不存在就生成
install -D tmp-rule/ai.txt bot-mihomo/classical/ai.txt

# tmp-rule/cdn_classical.txt 的内容覆盖 bot-mihomo/classical/cdn.txt 文件不存在就生成
install -D tmp-rule/cdn_classical.txt bot-mihomo/classical/cdn.txt

# tmp-rule/cdn_domain.txt 的内容覆盖 bot-mihomo/domain/cdn.txt 文件不存在就生成
install -D tmp-rule/cdn_domain.txt bot-mihomo/domain/cdn.txt

# tmp-rule/cnipv4.txt 和 tmp-rule/cnipv6.txt 内容合一起覆盖 bot-mihomo/ip/cn.txt 文件不存在就生成
install -D tmp-rule/cnipv4.txt bot-mihomo/ip/cn.txt
cat tmp-rule/cnipv4.txt tmp-rule/cnipv6.txt > bot-mihomo/ip/cn.txt

# tmp-rule/domestic.txt 的内容覆盖 bot-mihomo/classical/cn.txt 文件不存在就生成
install -D tmp-rule/domestic.txt bot-mihomo/classical/cn.txt

# tmp-rule/global.txt 的内容覆盖 bot-mihomo/classical/global.txt 文件不存在就生成
install -D tmp-rule/global.txt bot-mihomo/classical/global.txt

# tmp-rule/tgip.txt 的内容覆盖 bot-mihomo/ip/tgip.txt 文件不存在就生成
install -D tmp-rule/tgip.txt bot-mihomo/ip/tgip.txt
