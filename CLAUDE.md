# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 仓库定位

这是一个 Mihomo/Clash 规则数据仓库，而非应用项目：根目录规则文件是直接供消费者引用的接口。仓库没有源码目录、依赖或锁文件、构建系统、lint 配置和测试框架。

- 手工维护的规则集为根目录的 `.classical` 文件，如 `PROXY.classical`、`REJECT.classical`、`cdn.classical`、`fcm.classical`、`hentai.classical`、`japan.classical`、`taiwan.classical` 与 `youtube.classical`。
- 自动生成的规则集为 `chinaIP.ip`、`telegram.ip` 和 `LAN.classical`；不要直接手工维护其内容。
- 保持规则文件名、根目录位置、Mihomo/Clash 规则语法及现有注释格式不变；这些均为对消费者的兼容性接口。

## 常用命令

```bash
# 查看工作区和限定文件的差异
git status
git diff
git diff -- <file>

# 仅检查更新脚本语法；不访问网络、不写规则文件，也不推送
bash -n dev/D-IP.sh dev/git-push.sh

# 从上游重新生成三个自动产物；需要网络和 curl，会改写目标文件
bash dev/D-IP.sh
git diff -- chinaIP.ip telegram.ip LAN.classical
```

仓库不存在 build、lint、test 或运行单个测试的命令。静态规则修改后的最小验证是：

```bash
git diff -- <目标规则文件>
```

`bash dev/git-push.sh` 会暂存四个自动产物，在有变化时创建 commit 并执行真实 `git push`。除非用户明确要求远端写入，不要运行它，也不要将其作为验证命令。

## 自动更新链路

`dev/D-IP.sh` 是唯一的生成入口：

1. 创建临时目录。
2. 下载中国 IPv4、Telegram CIDR、LAN IP 与 LAN 域名。
3. 合并 LAN IP 与 LAN 域名数据。
4. 全部下载及解析成功后，才以 `mv` 原子替换 `chinaIP.ip`、`telegram.ip` 与 `LAN.classical`。

因此，调整自动规则应修改生成逻辑或其上游输入后重跑脚本，而不是编辑生成结果。脚本失败时，三个仓库内目标文件不会在中途被覆盖。

## 自动化与远端写入

`.github/workflows/D-IP.yaml` 定义 `D-IP` 工作流：支持 `workflow_dispatch` 和 cron `15 15 * * *`，在 `ubuntu-latest` 上依次运行 `dev/D-IP.sh`、`dev/git-push.sh`，并拥有 `contents: write` 权限。

`dev/git-push.sh` 仅处理 `telegram.ip`、`chinaIP.ip` 与 `LAN.classical`：它暂存这些文件、生成 GitHub Step Summary、在存在变更时提交并推送。修改该脚本或工作流时，只做静态语法检查与限定 diff 核对；不要触发真实 push 来验证。

## 修改边界

- 修改静态规则：只编辑指定规则文件，并用限定路径的 `git diff` 核对语法、条目及无关改动。
- 修改生成链路：运行 `bash dev/D-IP.sh` 后，仅检查三个自动产物的差异。
- 不引入构建系统、依赖管理、目录包装或额外产物；仓库当前的根目录规则文件布局就是发布形式。
- 修改 `dev/git-push.sh` 或 `.github/workflows/D-IP.yaml` 前，明确其会影响自动提交、推送及仓库写权限；未经明确授权不得运行可能创建 commit 或写入远端的命令。
