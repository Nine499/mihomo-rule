curl -vL -o cn4 https://ruleset.skk.moe/Clash/ip/china_ip.txt
curl -vL -o cn6 https://ruleset.skk.moe/Clash/ip/china_ip_ipv6.txt
cat cn4 cn6 > chinaIP.ip
curl -vL -o telegram.ip https://core.telegram.org/resources/cidr.txt
