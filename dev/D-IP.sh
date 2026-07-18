curl -vL -o chinaIP.ip https://ruleset.skk.moe/Clash/ip/china_ip.txt
curl -vL -o telegram.ip https://core.telegram.org/resources/cidr.txt
curl -vL -o lan1 https://ruleset.skk.moe/Clash/ip/lan.txt
curl -vL -o lan2 https://ruleset.skk.moe/Clash/non_ip/lan.txt
cat lan1 lan2 > LAN.classical
