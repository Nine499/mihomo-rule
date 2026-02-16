# mihomo-rule 极简优化 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 将 workflow 与 dev 脚本重构为“2 层结构 + fail-fast + 人类友好日志”，在不改变规则语义的前提下降低复杂度。

**Architecture:** 保留 3 个业务脚本（下载、处理、提交），新增 `dev/common.sh` 统一公共能力。workflow 仅负责编排脚本调用，不承载业务细节。所有关键失败立即退出，避免半成品。

**Tech Stack:** GitHub Actions YAML, Bash

---

### Task 1: 新增公共脚本层（common.sh）

**Files:**
- Create: `dev/common.sh`
- Modify: `dev/curl-rule.sh`
- Modify: `dev/process-rule.sh`
- Modify: `dev/git-push.sh`

**Step 1: 写“失败测试”基线（结构检查）**

```bash
test -f dev/common.sh
```

> 说明：当前应失败（文件不存在），用于确认新增文件是必要改动。

**Step 2: 运行并确认失败**

Run: `bash -lc 'test -f dev/common.sh'`
Expected: exit code 1

**Step 3: 写最小实现（common.sh）**

```bash
#!/usr/bin/env bash
set -euo pipefail

log_info() { printf '[INFO] %s\n' "$*"; }
log_warn() { printf '[WARN] %s\n' "$*"; }
log_error() { printf '[ERROR] %s\n' "$*"; }

die() {
  log_error "$*"
  exit 1
}

require_file() {
  local path="$1"
  local hint="${2:-}"
  [[ -f "$path" ]] || die "缺少文件: $path${hint:+，$hint}"
}

require_dir() {
  local path="$1"
  local hint="${2:-}"
  [[ -d "$path" ]] || die "缺少目录: $path${hint:+，$hint}"
}

line_count() {
  local path="$1"
  wc -l < "$path"
}
```

**Step 4: 运行检查确认通过**

Run: `bash -lc 'test -f dev/common.sh && test -s dev/common.sh'`
Expected: PASS（exit code 0）

**Step 5: Commit**

```bash
git add dev/common.sh
git commit -m "refactor(scripts): 提取公共 shell 能力"
```

---

### Task 2: 重写下载脚本为 fail-fast + 可读流程

**Files:**
- Modify: `dev/curl-rule.sh`
- Reference: `dev/common.sh`

**Step 1: 写“失败测试”（语法与 source 约束）**

```bash
bash -n dev/curl-rule.sh && grep -q 'source "$(dirname "$0")/common.sh"' dev/curl-rule.sh
```

> 说明：当前大概率失败（尚未改为统一头部与公共层）。

**Step 2: 运行并确认失败**

Run: `bash -lc 'bash -n dev/curl-rule.sh && grep -q "source \"$(dirname \"$0\")/common.sh\"" dev/curl-rule.sh'`
Expected: FAIL（grep 不匹配或头部未统一）

**Step 3: 写最小实现**

```bash
#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

readonly TEMP_DIR="tmp"
readonly CONNECT_TIMEOUT=30
readonly MAX_TIME=120

readonly DOWNLOADS=(
  "https://ruleset.skk.moe/Clash/ip/china_ip.txt|$TEMP_DIR/cnipv4.txt|中国 IPv4"
  "https://ruleset.skk.moe/Clash/ip/china_ip_ipv6.txt|$TEMP_DIR/cnipv6.txt|中国 IPv6"
  "https://core.telegram.org/resources/cidr.txt|$TEMP_DIR/tgip.txt|Telegram IP"
  "https://ruleset.skk.moe/Clash/domainset/cdn.txt|$TEMP_DIR/cdn_domain.txt|CDN 域名"
  "https://ruleset.skk.moe/Clash/non_ip/cdn.txt|$TEMP_DIR/cdn_classical.txt|CDN 规则"
  "https://ruleset.skk.moe/Clash/non_ip/global.txt|$TEMP_DIR/global.txt|全球规则"
  "https://ruleset.skk.moe/Clash/non_ip/domestic.txt|$TEMP_DIR/domestic.txt|国内规则"
  "https://ruleset.skk.moe/Clash/non_ip/lan.txt|$TEMP_DIR/lan_classical.txt|局域网规则"
  "https://ruleset.skk.moe/Clash/ip/lan.txt|$TEMP_DIR/lan_ip.txt|局域网 IP"
  "https://ruleset.skk.moe/Clash/non_ip/ai.txt|$TEMP_DIR/ai.txt|AI 规则"
)

is_valid_file() {
  local file="$1"
  local first_line
  [[ -s "$file" ]] || return 1
  IFS= read -r first_line < "$file" || true
  [[ ! "$first_line" =~ [Hh][Tt][Mm][Ll] ]] && [[ ! "$first_line" =~ [Dd][Oo][Cc][Tt][Yy][Pp][Ee] ]]
}

download_one() {
  local url="$1"
  local output="$2"
  local name="$3"

  curl -fsSL --connect-timeout "$CONNECT_TIMEOUT" --max-time "$MAX_TIME" "$url" -o "$output"
  is_valid_file "$output" || die "下载结果无效: $name"
  log_info "下载成功: $name ($(line_count "$output") 行)"
}

main() {
  local item url output name
  mkdir -p "$TEMP_DIR"
  log_info "开始下载规则文件"

  for item in "${DOWNLOADS[@]}"; do
    IFS='|' read -r url output name <<< "$item"
    download_one "$url" "$output" "$name"
  done

  log_info "下载完成"
}

main "$@"
```

**Step 4: 运行检查确认通过**

Run: `bash -n dev/curl-rule.sh`
Expected: PASS

**Step 5: Commit**

```bash
git add dev/curl-rule.sh
git commit -m "refactor(scripts): 简化下载流程并统一失败策略"
```

---

### Task 3: 重写处理脚本为 fail-fast + 直观映射

**Files:**
- Modify: `dev/process-rule.sh`
- Reference: `dev/common.sh`

**Step 1: 写“失败测试”（语法与 source 约束）**

```bash
bash -n dev/process-rule.sh && grep -q 'source "$(dirname "$0")/common.sh"' dev/process-rule.sh
```

**Step 2: 运行并确认当前失败**

Run: `bash -lc 'bash -n dev/process-rule.sh && grep -q "source \"$(dirname \"$0\")/common.sh\"" dev/process-rule.sh'`
Expected: FAIL（source 未引入前）

**Step 3: 写最小实现**

```bash
#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

readonly INPUT_DIR="tmp"
readonly OUTPUT_DIR="bot-mihomo"

copy_rule() {
  local src="$1"
  local dst="$2"
  local name="$3"
  require_file "$src" "请先运行 ./dev/curl-rule.sh"
  cp "$src" "$dst"
  log_info "复制完成: $name ($(line_count "$dst") 行)"
}

merge_rules() {
  local dst="$1"
  local name="$2"
  shift 2
  local src
  for src in "$@"; do
    require_file "$src" "请先运行 ./dev/curl-rule.sh"
  done
  sort -u "$@" > "$dst"
  log_info "合并完成: $name ($(line_count "$dst") 行)"
}

main() {
  require_dir "$INPUT_DIR" "请先运行 ./dev/curl-rule.sh"
  mkdir -p "$OUTPUT_DIR/ip" "$OUTPUT_DIR/domain" "$OUTPUT_DIR/classical"

  merge_rules "$OUTPUT_DIR/ip/cn.txt" "中国 IP" "$INPUT_DIR/cnipv4.txt" "$INPUT_DIR/cnipv6.txt"
  copy_rule "$INPUT_DIR/tgip.txt" "$OUTPUT_DIR/ip/tgip.txt" "Telegram IP"
  copy_rule "$INPUT_DIR/cdn_domain.txt" "$OUTPUT_DIR/domain/cdn.txt" "CDN 域名"

  copy_rule "$INPUT_DIR/cdn_classical.txt" "$OUTPUT_DIR/classical/cdn.txt" "CDN 规则"
  copy_rule "$INPUT_DIR/global.txt" "$OUTPUT_DIR/classical/global.txt" "全球规则"
  copy_rule "$INPUT_DIR/domestic.txt" "$OUTPUT_DIR/classical/cn.txt" "国内规则"
  merge_rules "$OUTPUT_DIR/classical/lan.txt" "局域网规则" "$INPUT_DIR/lan_classical.txt" "$INPUT_DIR/lan_ip.txt"
  copy_rule "$INPUT_DIR/ai.txt" "$OUTPUT_DIR/classical/ai.txt" "AI 规则"

  rm -rf "$INPUT_DIR"
  log_info "处理完成"
}

main "$@"
```

**Step 4: 运行检查确认通过**

Run: `bash -n dev/process-rule.sh`
Expected: PASS

**Step 5: Commit**

```bash
git add dev/process-rule.sh
git commit -m "refactor(scripts): 简化处理流程并改为失败即中止"
```

---

### Task 4: 重写提交脚本并移除本地 git config 依赖

**Files:**
- Modify: `dev/git-push.sh`
- Reference: `dev/common.sh`

**Step 1: 写“失败测试”（禁用 git config --local）**

```bash
! grep -q 'git config --local' dev/git-push.sh
```

> 说明：当前应失败（旧脚本包含 git config --local）。

**Step 2: 运行并确认失败**

Run: `bash -lc '! grep -q "git config --local" dev/git-push.sh'`
Expected: FAIL（退出码非 0）

**Step 3: 写最小实现**

```bash
#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

readonly TARGET_DIR="bot-mihomo"

main() {
  local commit_msg

  git rev-parse --git-dir >/dev/null 2>&1 || die "当前目录不是 Git 仓库"
  require_dir "$TARGET_DIR" "请先运行 ./dev/process-rule.sh"

  git add "$TARGET_DIR"

  if git diff --cached --quiet; then
    log_info "没有可提交的变更"
    exit 0
  fi

  log_info "本次变更："
  git diff --cached --stat

  commit_msg="auto: update rules $(date '+%Y-%m-%d %H:%M:%S')"
  git commit -m "$commit_msg"
  log_info "提交成功: $commit_msg"

  git push
  log_info "推送成功"
}

main "$@"
```

**Step 4: 运行检查确认通过**

Run: `bash -n dev/git-push.sh && ! grep -q 'git config --local' dev/git-push.sh`
Expected: PASS

**Step 5: Commit**

```bash
git add dev/git-push.sh
git commit -m "refactor(scripts): 精简提交流程并去除本地配置写入"
```

---

### Task 5: 简化 workflow 为纯编排

**Files:**
- Modify: `.github/workflows/mihomo-rule.yaml`
- Verify: `dev/curl-rule.sh`
- Verify: `dev/process-rule.sh`
- Verify: `dev/git-push.sh`

**Step 1: 写“失败测试”（关键结构断言）**

```bash
grep -q 'run: ./dev/curl-rule.sh' .github/workflows/mihomo-rule.yaml
grep -q 'run: ./dev/process-rule.sh' .github/workflows/mihomo-rule.yaml
grep -q 'run: ./dev/git-push.sh' .github/workflows/mihomo-rule.yaml
```

> 说明：若后续误删任何一步，这组检查会失败。

**Step 2: 运行并确认当前通过（保护基线）**

Run:
- `bash -lc 'grep -q "run: ./dev/curl-rule.sh" .github/workflows/mihomo-rule.yaml'`
- `bash -lc 'grep -q "run: ./dev/process-rule.sh" .github/workflows/mihomo-rule.yaml'`
- `bash -lc 'grep -q "run: ./dev/git-push.sh" .github/workflows/mihomo-rule.yaml'`
Expected: PASS

**Step 3: 写最小实现（仅保留必要编排）**

```yaml
name: 更新 mihomo 规则

on:
  workflow_dispatch:
  schedule:
    - cron: "15 15 * * *"

concurrency:
  group: update-rules
  cancel-in-progress: false

jobs:
  update-rules:
    name: 下载 -> 处理 -> 提交
    runs-on: ubuntu-latest
    timeout-minutes: 15
    defaults:
      run:
        shell: bash
    steps:
      - name: 检出仓库
        uses: actions/checkout@v4

      - name: 下载规则
        run: ./dev/curl-rule.sh

      - name: 处理规则
        run: ./dev/process-rule.sh

      - name: 提交并推送
        run: ./dev/git-push.sh
```

**Step 4: 运行检查确认通过**

Run: `bash -n dev/curl-rule.sh && bash -n dev/process-rule.sh && bash -n dev/git-push.sh`
Expected: PASS

**Step 5: Commit**

```bash
git add .github/workflows/mihomo-rule.yaml
git commit -m "refactor(ci): 精简 workflow 为脚本编排层"
```

---

### Task 6: 整体验证与收尾

**Files:**
- Verify: `dev/common.sh`
- Verify: `dev/curl-rule.sh`
- Verify: `dev/process-rule.sh`
- Verify: `dev/git-push.sh`
- Verify: `.github/workflows/mihomo-rule.yaml`

**Step 1: 写“失败测试”（全量语法验证命令）**

```bash
bash -n dev/common.sh
bash -n dev/curl-rule.sh
bash -n dev/process-rule.sh
bash -n dev/git-push.sh
```

> 说明：任一脚本语法错误都会失败。

**Step 2: 运行检查并确认通过**

Run:
- `bash -n dev/common.sh`
- `bash -n dev/curl-rule.sh`
- `bash -n dev/process-rule.sh`
- `bash -n dev/git-push.sh`
Expected: 全部 PASS

**Step 3: 本地干跑关键路径（不推送）**

```bash
./dev/curl-rule.sh
./dev/process-rule.sh
git status --short
```

Expected:
- 下载与处理成功
- `git status` 显示仅规则文件有预期改动

**Step 4: 最终提交（合并收尾）**

```bash
git add dev/common.sh dev/curl-rule.sh dev/process-rule.sh dev/git-push.sh .github/workflows/mihomo-rule.yaml
git commit -m "refactor(ci,scripts): 完成 mihomo 规则流程极简优化"
```

**Step 5: 复核**

Run: `git log --oneline -n 5`
Expected: 出现收尾提交，历史清晰。
