curl -vL -o ip4 https://ruleset.skk.moe/Clash/ip/china_ip.txt
curl -vL -o ip6 https://ruleset.skk.moe/Clash/ip/china_ip_ipv6.txt
cat ip4 ip6 > chinaIP.ip
curl -vL -o telegram.ip https://core.telegram.org/resources/cidr.txt
