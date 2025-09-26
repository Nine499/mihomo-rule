echo 处理规则
mkdir -p bot-mihomo/domain
mkdir -p bot-mihomo/classical
mkdir -p bot-mihomo/ip
# 处理 tmp/cnipv4.txt 和 tmp/cnipv6.txt
# 要求：把两个文件合并到 bot-mihomo/ip/cn.txt
cat tmp/cnipv4.txt tmp/cnipv6.txt > bot-mihomo/ip/cn.txt
# 处理 tmp/tgip.txt
# 要求：文件输出到 bot-mihomo/ip/tgip.txt
cp tmp/tgip.txt bot-mihomo/ip/tgip.txt
# 处理 tmp/ai.txt
# 要求：文件输出到 bot-mihomo/classical/ai.txt
cp tmp/ai.txt bot-mihomo/classical/ai.txt
# 处理 tmp/cdn1.txt
# 要求：文件输出到 bot-mihomo/domain/cdn.txt
cp tmp/cdn1.txt bot-mihomo/domain/cdn.txt
# 处理 tmp/cdn2.txt
# 要求：文件输出到 bot-mihomo/classical/cdn.txt
cp tmp/cdn2.txt bot-mihomo/classical/cdn.txt
# 处理 tmp/global.txt
# 要求：文件输出到 bot-mihomo/classical/global.txt
cp tmp/global.txt bot-mihomo/classical/global.txt
# 处理 tmp/domestic.txt
# 要求：文件输出到 bot-mihomo/classical/cn.txt
cp tmp/domestic.txt bot-mihomo/classical/cn.txt
# 处理 tmp/lan1.txt 和 tmp/lan2.txt
# 要求：把两个文件合并到 bot-mihomo/classical/lan.txt
cat tmp/lan1.txt tmp/lan2.txt > bot-mihomo/classical/lan.txt
