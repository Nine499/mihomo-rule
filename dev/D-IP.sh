mkdir -p tmp49
curl -vL -o tmp49/chinaip4 https://ruleset.skk.moe/Clash/ip/china_ip.txt
curl -vL -o tmp49/chinaip6 https://ruleset.skk.moe/Clash/ip/china_ip_ipv6.txt
cat tmp49/chinaip4 tmp49/chinaip6 > chinaIP.ip
curl -vL -o telegram.ip https://core.telegram.org/resources/cidr.txt
