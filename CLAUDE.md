# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 仓库概况

这是一个以规则数据文件为主的仓库，根目录直接存放多份 `.classical` 与 `.ip` 文件。仓库中的可执行逻辑很少，主要集中在 `dev/` 下的两个脚本，以及 `.github/workflows/D-IP.yaml` 的定时更新流程。

当前没有读取到 `README.md`、已有仓库级 `CLAUDE.md`、`.cursorrules`、`.cursor/rules/` 或 `.github/copilot-instructions.md`。

## 常用命令

### 查看改动

```bash
git status
git diff
```

### 重新生成自动维护的数据文件

`dev/D-IP.sh` 会重新下载并生成以下 3 个文件：

- `chinaIP.ip`
- `telegram.ip`
- `LAN.classical`

命令：

```bash
bash dev/D-IP.sh
```

### 只检查生成结果而不提交

仓库里没有独立测试、lint 或 build 配置。对这个仓库，最贴近改动的验证方式通常是重新生成目标文件后查看 diff：

```bash
bash dev/D-IP.sh
git diff -- chinaIP.ip telegram.ip LAN.classical
```

如果只想检查某一个生成文件，也直接限定路径：

```bash
git diff -- chinaIP.ip
git diff -- telegram.ip
git diff -- LAN.classical
```

### 自动提交与推送脚本

```bash
bash dev/git-push.sh
```

注意：这个脚本会执行 `git push`。只有在用户明确要求推送远端时才应运行。

## 自动化流程

### GitHub Actions 定时任务

`.github/workflows/D-IP.yaml` 定义了名为 `D-IP` 的工作流：

- 支持 `workflow_dispatch`
- 还配置了 `schedule`：`15 15 * * *`
- 工作流顺序执行：
  1. `bash dev/D-IP.sh`
  2. `bash dev/git-push.sh`

这意味着仓库的自动更新范围目前只覆盖 `D-IP.sh` 生成并由 `git-push.sh` add 的那 3 个文件。

## 高层结构

### 1. 根目录规则文件就是主要产物

根目录下的大多数文件不是源码，而是最终规则数据，例如：

- `REJECT.classical`
- `PROXY.classical`
- `AI.classical`
- `cdn.classical`
- `youtube.classical`
- `hentai.classical`
- `japan.classical`
- `taiwan.classical`
- `LAN.classical`
- `chinaIP.ip`
- `telegram.ip`

这些文件直接保存规则条目或 IP 段，没有额外的构建目录。

### 2. 规则文件分为两类

#### 静态维护的域名/规则集

例如：

- `PROXY.classical`：包含少量 `DOMAIN-KEYWORD` / `DOMAIN-SUFFIX` 规则
- `REJECT.classical`：包含手写逻辑规则，例如 `AND,((DST-PORT,443),(NETWORK,UDP),(NOT,((RULE-SET,chinaIP-ip))))`
- `AI.classical`、`cdn.classical`、`youtube.classical`、`hentai.classical`、`japan.classical`、`taiwan.classical`：主要是手写的域名规则集合

这类文件的改动通常是直接编辑内容本身。

#### 从上游下载后拼接或落盘的 IP / LAN 数据

`dev/D-IP.sh` 负责：

- 从 `ruleset.skk.moe` 下载中国 IPv4 / IPv6 数据并合并为 `chinaIP.ip`
- 从 Telegram 官方地址下载 `telegram.ip`
- 从 `ruleset.skk.moe` 下载两个 LAN 规则文件并合并为 `LAN.classical`

所以这 3 个文件应优先视为“生成结果”，而不是手工长期维护的主编辑入口。

### 3. `dev/` 目录只做两件事

#### `dev/D-IP.sh`

负责抓取上游数据并覆盖生成文件。它不处理其他 `.classical` 文件。

#### `dev/git-push.sh`

负责：

- `git add telegram.ip chinaIP.ip LAN.classical`
- 设置提交用户名和邮箱
- 仅在 staged 内容有变化时提交
- 执行 `git push`

因此它不是通用提交脚本，而是与自动更新流程强绑定的发布脚本。

## 修改时的工作方式

### 修改静态规则文件时

直接读取并编辑目标 `.classical` 文件，然后用：

```bash
git diff -- <file>
```

确认规则是否按预期变化。

### 修改自动生成链路时

如果改动涉及：

- `dev/D-IP.sh`
- `.github/workflows/D-IP.yaml`
- `LAN.classical`
- `chinaIP.ip`
- `telegram.ip`

优先通过重新运行：

```bash
bash dev/D-IP.sh
```

来验证输出是否符合预期，再查看对应 diff。

### 修改提交脚本时

`dev/git-push.sh` 包含真实 `git push`。除非用户明确要求，否则不要执行该脚本做验证；优先通过阅读脚本和必要的局部命令验证逻辑。

## 已确认的边界

- 当前仓库内未读取到测试框架配置、lint 配置或构建配置。
- 当前仓库内未读取到 package manager、Python 项目配置或其他应用源码结构。
- 代码理解重点应放在：规则文件分类、哪些文件是生成物、自动更新只覆盖哪些文件、以及带推送副作用的脚本边界。
