# Mihomo 规则集自动化管理工具

欢迎！这是一个帮助你自动下载、整理和更新 Mihomo（Clash Meta）代理规则集的小工具。即使你是完全的小白，也能轻松使用！

---

## 📖 项目简介

这个项目是做什么的？

简单来说，它帮你**自动管理网络代理规则**。Mihomo 是一款流行的代理客户端，需要各种规则文件来决定哪些网站走直连、哪些走代理。这个工具会：

1. **自动下载规则**：从可靠的规则源（如 Sukka's Ruleset）下载最新的网络规则文件
2. **智能整理分类**：将下载的规则按类型整理成 Mihomo 可以直接使用的格式
3. **一键更新提交**：自动将更新后的规则提交到 Git 仓库，方便你同步到其他设备

### 核心功能点

- **中国 IP 地址规则**：包含中国大陆的 IPv4 和 IPv6 地址段
- **Telegram IP 规则**：官方提供的 Telegram 服务器 IP 地址
- **CDN 域名规则**：识别各种 CDN（内容分发网络）的域名
- **全局/国内/局域网规则**：区分国际网站、国内网站和局域网地址

---

## 🔧 环境与前置条件

在开始之前，你的电脑需要满足以下条件：

### 必备软件

1. **Git**

   - 用于版本控制，方便提交和管理规则文件
   - 检查方法：在终端输入 `git --version`
   - 如果没有安装，请访问 [Git 官网](https://git-scm.com/) 下载安装

2. **Bash 环境**

   - Linux 和 macOS 系统自带
   - Windows 用户建议使用 **WSL** (Windows Subsystem for Linux) 或 **Git Bash**

3. **curl 工具**
   - 用于下载网络文件
   - 检查方法：在终端输入 `curl --version`
   - Linux/macOS 通常已安装，Windows WSL 需要手动安装（`sudo apt install curl`）

### 可选配置

- **GitHub 账号**：如果你想使用 GitHub Actions 自动化功能（每天自动更新规则），需要将代码推送到 GitHub

---

## 🚀 安装与配置

### 步骤 1：克隆项目到本地

首先，把这个项目下载到你的电脑上：

```bash
git clone git@github.com:Nine499/mihomo-rule.git
cd mihomo-rule
```

### 步骤 2：设置脚本执行权限

为了让脚本可以正常运行，需要给它们添加执行权限：

```bash
chmod +x dev/*.sh
```

### 步骤 3：（可选）配置 Git 用户信息

如果你还没有配置过 Git，需要设置你的用户名和邮箱：

```bash
git config --global user.email "your-email@example.com"
git config --global user.name "Your Name"
```

> 💡 **提示**：这个设置只需要配置一次，以后就不用再设置了

---

## ⚡ 快速开始

### 手动更新规则（推荐先试试这个）

如果你只是想手动更新一次规则文件，请按顺序运行以下三个步骤：

#### 第一步：下载原始规则文件

这个脚本会从网络下载各种规则文件到 `tmp/` 目录：

```bash
bash dev/curl-rule.sh
```

你会看到类似这样的输出：

```text
🌐 开始下载网络规则集...
📅 时间: 2025-12-25 15:30:00
📋 准备下载 9 个文件...
📦 进度: 1/9
⬇️  正在下载: 中国IPv4地址
✅ 下载成功: 中国IPv4地址
...
🎉 所有文件下载成功！
```

#### 第二步：处理和整理规则

这个脚本会把下载的原始文件整理成 Mihomo 可以使用的格式：

```bash
bash dev/process-rule.sh
```

你会看到：

```text
🔄 开始处理网络规则文件...
📁 创建输出目录...
🇨🇳 处理中国 IP 地址规则...
✅ 中国 IP 规则已生成
📱 处理 Telegram IP 规则...
✅ Telegram IP 规则已复制
...
🎉 所有规则文件处理完成！
```

处理完成后，`bot-mihomo/` 目录下就会生成好用的规则文件了！

#### 第三步：（可选）提交到 Git 仓库

如果你想把这些更新提交到 Git 仓库：

```bash
bash dev/git-push.sh
```

---

## 📁 项目结构说明

```text
mihomo-rule/
├── dev/                    # 核心脚本目录（所有自动化脚本都在这里）
│   ├── curl-rule.sh       # 下载规则文件的脚本
│   ├── process-rule.sh    # 处理和整理规则的脚本
│   └── git-push.sh        # 自动提交和推送的脚本
├── bot-mihomo/            # 输出目录（处理后的规则文件存放在这里）
│   ├── domain/            # 域名类型规则
│   │   └── cdn.txt        # CDN 域名列表
│   ├── classical/         # 经典类型规则
│   │   ├── cdn.txt        # CDN 规则
│   │   ├── cn.txt         # 中国大陆规则
│   │   ├── global.txt     # 全球规则
│   │   └── lan.txt        # 局域网规则
│   └── ip/                # IP 类型规则
│       ├── cn.txt         # 中国 IP 地址（IPv4 + IPv6）
│       └── tgip.txt       # Telegram IP 地址
├── mihomo/                # 其他规则文件（手动维护的）
│   └── domain/
├── .github/               # GitHub 配置（自动化更新功能）
│   └── workflows/
│       └── mihomo-rule.yaml
└── README.md              # 你正在看的这个文件
```

### 目录说明

- **dev/**：这是最重要的目录，里面有三个脚本，分别负责下载、处理和提交规则
- **bot-mihomo/**：脚本运行后生成的规则文件都在这里，你可以直接复制到 Mihomo 配置中使用
- **mihomo/**：存放一些手动维护的规则文件
- **tmp/**：临时目录，存放下载的原始文件（脚本会自动创建和清理）

---

## ❓ 常见问题 (FAQ)

### Q1：运行脚本时提示 "permission denied"（权限被拒绝）

**原因**：脚本没有执行权限

**解决方法**：

```bash
chmod +x dev/*.sh
```

### Q2：下载规则时提示 "curl: command not found"

**原因**：你的系统没有安装 curl 工具

**解决方法**：

- Ubuntu/Debian：`sudo apt install curl`
- CentOS/RHEL：`sudo yum install curl`
- macOS：通常已安装，如果没有请使用 Homebrew 安装

### Q3：下载失败，提示网络超时

**原因**：网络连接不稳定或防火墙阻止了访问

**解决方法**：

1. 检查你的网络连接是否正常
2. 尝试使用代理或 VPN
3. 脚本已经内置了重试机制（最多重试 3 次），可以多运行几次试试

### Q4：Git 推送失败，提示 "Permission denied"

**原因**：没有配置 SSH 密钥或没有仓库的写入权限

**解决方法**：

1. 确保你已经配置了 GitHub SSH 密钥
2. 检查你是否有该仓库的推送权限
3. 如果是 fork 的仓库，需要先创建 Pull Request

### Q5：我想修改自动更新的时间

**方法**：编辑 `.github/workflows/mihomo-rule.yaml` 文件，找到这一行：

```yaml
- cron: "15 15 * * *"
```

这个表示每天 15:15（UTC 时间）自动运行。你可以根据 cron 表达式规则修改时间。

### Q6：生成的规则文件怎么用？

**方法**：在 Mihomo 的配置文件中引用这些规则文件，例如：

```yaml
rules:
  - RULE-SET,cn,DIRECT
  - RULE-SET,global,PROXY
  - RULE-SET,lan,DIRECT
```

具体配置方式请参考 Mihomo 官方文档。

### Q7：脚本运行后没有生成文件

**原因**：可能是下载步骤失败了

**解决方法**：

1. 检查 `tmp/` 目录是否有下载的文件
2. 查看 `curl-rule.sh` 的输出，确认哪些文件下载失败
3. 重新运行 `curl-rule.sh` 下载

### Q8：我想只更新某一种规则，不想全部更新

**方法**：目前脚本设计为一次性更新所有规则。如果你只需要某一种规则，可以：

1. 手动编辑 `curl-rule.sh`，注释掉不需要的下载项
2. 或者直接从 `tmp/` 目录复制你需要的文件到 `bot-mihomo/` 对应位置

---

## 📝 使用建议

### 对于普通用户

如果你只是想获取最新的规则文件：

1. 运行 `bash dev/curl-rule.sh` 下载规则
2. 运行 `bash dev/process-rule.sh` 整理规则
3. 从 `bot-mihomo/` 目录复制你需要的规则文件到 Mihomo 配置目录

### 对于开发者

如果你想维护自己的规则仓库：

1. Fork 这个项目到你的 GitHub 账号
2. 修改 `.github/workflows/mihomo-rule.yaml` 中的提交信息（可选）
3. 推送到 GitHub，启用 GitHub Actions，实现每天自动更新

---

## 📄 许可证说明

本项目整理的规则文件来源于优秀的开源项目，使用时请遵守上游项目的许可证：

- **Sukka's Ruleset**：AGPL 3.0 / CC BY-SA 2.0
- **Telegram CIDR**：MIT

---

## 🙏 致谢

特别感谢以下开源项目提供高质量的规则集：

- [Sukka's Ruleset](https://github.com/SukkaW/Surge) - 提供了高质量的网络规则集
- [Telegram](https://telegram.org/) - 官方提供的 CIDR 列表

---

**祝你使用愉快！如果遇到问题，欢迎查阅上面的常见问题部分。**
