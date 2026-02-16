# mihomo-rule 极简优化设计（workflow + dev 脚本）

日期：2026-02-16
范围：
- `.github/workflows/mihomo-rule.yaml`
- `dev/` 下所有 shell 脚本

## 1. 目标与约束

### 目标
1. 越简单越好：降低认知负担，让人一眼看懂执行链路。
2. 人类友好：日志统一、错误直接、职责明确。
3. 稳定可控：关键步骤失败即中止，避免半成品产出。

### 已确认约束
1. 优先级：简单可读优先。
2. 失败策略：失败即中止（fail-fast）。
3. 脚本组织：采用 2 层结构（业务脚本 + 公共函数层）。
4. 提交策略：由实现方选择最简方案；本设计推荐保留在脚本内，workflow 仅编排。

---

## 2. 方案对比与结论

### 方案 A（推荐）
2 层脚本 + workflow 仅编排 + 提交保留脚本。

- 结构：
  - `dev/common.sh`（公共函数层）
  - `dev/curl-rule.sh`（下载）
  - `dev/process-rule.sh`（处理）
  - `dev/git-push.sh`（提交推送）
- 优点：最符合“2 层 + 极简 + 易读”，每个脚本职责单一，可单独调试。
- 缺点：提交细节在脚本而非 YAML 中展示。

### 方案 B
2 层脚本 + workflow 内提交。

- 优点：CI 行为更“可视化”。
- 缺点：YAML 变长，shell 逻辑散落，不利于复用。

### 方案 C
单入口脚本 + workflow 单步调用。

- 优点：YAML 最短。
- 缺点：分步可读性和定位能力下降，不契合本次“2 层结构”偏好。

### 结论
采用 **方案 A**。

---

## 3. 架构设计

### 3.1 目录职责
- `dev/common.sh`：统一日志、失败退出、命令/文件校验等公共能力。
- `dev/curl-rule.sh`：只负责下载源规则到 `tmp/`。
- `dev/process-rule.sh`：只负责将 `tmp/` 处理到 `bot-mihomo/`。
- `dev/git-push.sh`：只负责 git add/commit/push（仅 `bot-mihomo/`）。

### 3.2 调用链路
1. 下载：`curl-rule.sh`
2. 处理：`process-rule.sh`
3. 提交：`git-push.sh`

workflow 仅按顺序执行这 3 步，不承载业务逻辑。

---

## 4. 脚本规范

### 4.1 统一头部
```bash
#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
```

### 4.2 统一日志
- `log_info` / `log_warn` / `log_error`
- 日志只保留关键对象（规则名、文件名、结果）

### 4.3 统一失败策略
- 关键动作失败立即退出（exit 1）
- 不采用“部分成功继续”

### 4.4 统一编码约定
- 常量 `readonly`
- 函数变量 `local`
- 保留必要中文注释，仅解释意图
- 不做过度抽象，保证脚本短小可读

---

## 5. 数据流设计

### 5.1 输入输出
- 输入源：外部规则 URL
- 中间目录：`tmp/*.txt`
- 输出目录：`bot-mihomo/{ip,domain,classical}/*.txt`

### 5.2 处理规则
- 复制型规则：直接 copy
- 合并型规则：`sort -u` 去重合并
- 清理策略：处理成功后移除 `tmp/`

---

## 6. workflow 设计

### 6.1 保留项
- `workflow_dispatch`
- `schedule`
- `concurrency`
- 单 job + 3 个 run step
- `actions/checkout`

### 6.2 简化原则
- step 名称直白：下载规则 / 处理规则 / 提交并推送
- YAML 中不写复杂 shell 分支
- 可读优先，不引入额外 matrix 或高级技巧

---

## 7. 错误处理设计

### 7.1 下载阶段
- curl 失败 -> 立即失败
- 下载为空/疑似 HTML -> 立即失败

### 7.2 处理阶段
- 输入目录缺失 -> 立即失败
- 源文件缺失 -> 立即失败
- 合并/复制失败 -> 立即失败

### 7.3 提交阶段
- 非 git 仓库或目标目录缺失 -> 立即失败
- 无变更 -> 输出提示并正常退出 0

---

## 8. 验收标准

1. `.github/workflows/mihomo-rule.yaml` 仅编排流程，结构更短更直观。
2. `dev/` 脚本风格统一，重复逻辑收敛到 `dev/common.sh`。
3. 失败路径明确，日志统一，所有关键失败都会中止流程。
4. 三个脚本均可独立执行，CI 串行运行可读可定位。
5. 总体复杂度下降，无新增不必要抽象。

---

## 9. 非目标（本次不做）

1. 不改规则来源与规则语义。
2. 不引入额外语言或外部依赖。
3. 不新增与本次优化无关的功能。
