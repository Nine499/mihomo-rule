#!/bin/bash

mkdir -p 49tmp49

curl -fSL -o 49tmp49/cnip.txt https://ruleset.skk.moe/Clash/ip/china_ip.txt
curl -fSL -o 49tmp49/tgip.txt https://core.telegram.org/resources/cidr.txt
curl -fSL -o 49tmp49/lanip1.txt https://ruleset.skk.moe/Clash/ip/lan.txt
curl -fSL -o 49tmp49/lanip2.txt https://ruleset.skk.moe/Clash/non_ip/lan.txt

cat 49tmp49/cnip.txt > chinaIP.ip
cat 49tmp49/tgip.txt > telegram.ip
cat 49tmp49/lanip1.txt 49tmp49/lanip2.txt > LAN.classical

FILES=(
    chinaIP.ip
    LAN.classical
    telegram.ip
)
fail=0
for f in "${FILES[@]}"; do
    if [[ ! -f "$f" ]]; then
        echo "ERROR: $f 文件不存在" >&2
        fail=1
        continue
    fi
    n=$(awk 'END{print NR}' "$f")
    if (( n <= 3 )); then
        echo "ERROR: $f 只有 $n 行" >&2
        fail=1
    fi
done
(( fail == 0 )) || exit 1

echo end
