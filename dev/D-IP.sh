curl -vL -o cn4 https://ruleset.skk.moe/Clash/ip/china_ip.txt
curl -vL -o cn6 https://ruleset.skk.moe/Clash/ip/china_ip_ipv6.txt
cat cn4 cn6 > chinaIP.ip
curl -vL -o telegram.ip https://core.telegram.org/resources/cidr.txt
curl -vL -o lan1 https://ruleset.skk.moe/Clash/ip/lan.txt
curl -vL -o lan2 https://ruleset.skk.moe/Clash/non_ip/lan.txt
cat lan1 lan2 > LAN.classical
