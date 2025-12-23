# Mihomo 规则集资源

本仓库整理并维护了一系列适用于 Mihomo (Clash Meta) 的规则集文件。这些文件来源于优秀的开源项目（如 [Sukka's Ruleset](https://github.com/SukkaW/Surge) 等），并针对代理客户端进行了格式转换和分类。

> **注意**：部分规则可能包含额外的分发限制，使用时请务必遵守上游项目的 License 及相关条款。

---

## 📂 文件清单

下表详细列出了当前维护的规则集文件及其来源信息：

| 目标文件                                                             | 规则类型/描述                 | 来源                                                                                                                                    | 许可证       |
| :------------------------------------------------------------------- | :---------------------------- | :-------------------------------------------------------------------------------------------------------------------------------------- | :----------- |
| [`bot-mihomo/ip/cn.txt`](bot-mihomo/ip/cn.txt)                       | 中国大陆 IP 段 (IPv4 + IPv6)  | [china_ip.txt](https://ruleset.skk.moe/Clash/ip/china_ip.txt) • [china_ip_ipv6.txt](https://ruleset.skk.moe/Clash/ip/china_ip_ipv6.txt) | CC BY-SA 2.0 |
| [`bot-mihomo/ip/tgip.txt`](bot-mihomo/ip/tgip.txt)                   | Telegram IP 段                | [cidr.txt](https://core.telegram.org/resources/cidr.txt)                                                                                | MIT          |
| [`bot-mihomo/domain/cdn.txt`](bot-mihomo/domain/cdn.txt)             | CDN 域名列表                  | [cdn.txt](https://ruleset.skk.moe/Clash/domainset/cdn.txt)                                                                              | AGPL 3.0     |
| [`bot-mihomo/classical/cdn.txt`](bot-mihomo/classical/cdn.txt)       | CDN 经典规则 (Non-IP)         | [cdn.txt](https://ruleset.skk.moe/Clash/non_ip/cdn.txt)                                                                                 | AGPL 3.0     |
| [`bot-mihomo/classical/cn.txt`](bot-mihomo/classical/cn.txt)         | 中国大陆经典规则 (Non-IP)     | [domestic.txt](https://ruleset.skk.moe/Clash/non_ip/domestic.txt)                                                                       | AGPL 3.0     |
| [`bot-mihomo/classical/global.txt`](bot-mihomo/classical/global.txt) | 全球经典规则 (Non-IP)         | [global.txt](https://ruleset.skk.moe/Clash/non_ip/global.txt)                                                                           | AGPL 3.0     |
| [`bot-mihomo/classical/lan.txt`](bot-mihomo/classical/lan.txt)       | 局域网/直连规则 (Non-IP + IP) | [lan.txt (non_ip)](https://ruleset.skk.moe/Clash/non_ip/lan.txt) • [lan.txt (ip)](https://ruleset.skk.moe/Clash/ip/lan.txt)             | AGPL 3.0     |

---

**特别感谢** [Sukka](https://github.com/SukkaW) 维护的高质量规则集资源以及 Telegram 官方提供的 CIDR 列表。
