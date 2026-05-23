# USAGE.md — 架构师 Agent 工作指南

本文档面向架构师 Agent（Claude Code，从 `~/` 启动）。包含：首次 Setup、新项目初始化、核心原则、任务文件规范、日常工作流。

---

## 1. 首次 Setup

用户在新机器上 clone 此仓库后，将以下步骤一次性完成：

### 1.1 部署通用 DS 规则

```bash
mkdir -p ~/.claude/collab-framework
cp ~/claude-agent/collab-framework/DS-common.md ~/.claude/collab-framework/DS-common.md
```

### 1.2 注册框架到全局 CLAUDE.md

检查 `~/.claude/CLAUDE.md` 是否已有 `@WORKFLOW.md`（若已有则跳过）：

```bash
grep -q "@WORKFLOW.md" ~/.claude/CLAUDE.md 2>/dev/null || echo "@WORKFLOW.md" >> ~/.claude/CLAUDE.md
```

（若 `~/.claude/CLAUDE.md` 不存在，先确认用户的全局 `~/CLAUDE.md` 已就位，再处理。）

### 1.3 初始化 Memory

检查 memory 目录是否存在：

```bash
ls ~/.claude/projects/-home-$(whoami)/memory/ 2>/dev/null
```

若不存在，从模板创建：

```bash
mkdir -p ~/.claude/projects/-home-$(whoami)/memory
cp ~/claude-agent/memory-template/MEMORY.md ~/.claude/projects/-home-$(whoami)/memory/MEMORY.md
cp ~/claude-agent/memory-template/gpt-registry-template.md \
   ~/.claude/projects/-home-$(whoami)/memory/gpt-registry.md
```

然后提示用户：编辑 `gpt-registry.md`，填入实际机器 SSH 地址和仓库路径。

### 1.4 完成后汇报

列出已执行的步骤（跳过的说明"已存在"），告知用户下一步是添加项目仓库。

---

## 2. 新项目初始化

每个项目仓库需要 `DS.md` + `code-agent/` 两件套。

### 2.1 创建 DS.md

从模板复制到项目根目录：

```bash
cp ~/.claude/collab-framework/DS-template.md /path/to/project/DS.md
```

DS.md 头部固定引用通用规则：

```markdown
**阅读顺序：先读 `~/.claude/collab-framework/DS-common.md`，再读本文件。**
```

**初始 DS.md 只填基础字段（角色、项目背景、构建命令），其余字段等第一次调研任务完成后由架构师补充。**

### 2.2 创建 code-agent/

```bash
cp -r ~/claude-agent/collab-framework/code-agent/ /path/to/project/code-agent/
```

目录结构：

```
code-agent/
  tasks/          # 任务文件（DA-NNNx-描述.md）
  knowledge/      # 知识库
    README.md     # 知识库主题索引
    10-changelog.md
```

### 2.3 注册到 Memory

在 `gpt-registry.md` 中添加项目对应的 DS 路由规则（本地路径 + 远端 scp 命令）。

在 `MEMORY.md` 中添加项目拓扑条目。

---

## 3. 核心原则

### 3.1 架构师职责

- **做**：设计接口/约束、拆任务、Review 代码、小问题直接修复、提交
- **不做**：复杂调研（创建调研任务让 DS 做）、具体实现（交给 DS）
- Review 中轻量问题（测试断言、漏改引用、格式）：直接修复 + 运行验收
- Review 中阻断问题（设计不符、ABI 破坏、多文件重构）：报告用户，视情况下发修复任务

### 3.2 TDD 合同风格（任务文件核心）

任务文件 = 接口说明书 + 架构决策 + 测试场景，**不写实现伪码**。

**写什么**：
- 架构决策（DS 无法从代码推断的选择：ABI、接口、关键约束）
- 测试场景：*必须保持通过的现有测试* + *新增测试的行为特征（不写 CHECK 模式）*
- 参考指针（"参考 xxx.c 的 yyy 模式"）
- 工具链路径、CMake 变量名等环境信息

**不写什么**：
- for 循环伪码、Step 1/2/3 手把手分解
- 具体 CHECK 模式（DS 跑工具后自己写）
- 行号引用（行号会变）

### 3.3 两层 DS.md 结构

| 文件 | 内容 | 维护者 |
|------|------|--------|
| `~/.claude/collab-framework/DS-common.md` | 通用规则（不 commit、完成区格式、查询顺序） | 此仓库统一维护 |
| 项目根目录 `DS.md` | 项目 context（角色、布局、构建、任务编号、项目特有规则） | 架构师随项目演进补充 |

DS.md 只写项目特有内容，通用规则通过引用 DS-common.md 获取。

### 3.4 Review 分类

| 任务类型 | Review 重点 |
|---------|-------------|
| 通过已有测试 | 检查 pass/fail 结果即可 |
| 新增测试 | 重点 review CHECK 语义是否正确（这是架构师的核心职责） |

---

## 4. 任务文件规范

### 4.1 文件命名

`code-agent/tasks/<编号>-<类型>-<简述>.md`

编号格式：三位数字 + 字母后缀，如 `027c`、`035a`；子步骤用数字：`035a1`。

类型：`research` / `implement` / `fix` / `continue`

### 4.2 必须包含的字段

```markdown
# 任务标题

**状态**：待执行
**执行环境**：本地 DS · <仓库名>
（或：远端 <nickname> DS · <仓库名>）

## 前置知识
- `code-agent/knowledge/XX.md` §章节号 — 关联说明

## 任务描述

### 背景
[为什么需要这个任务，2-3 句]

### 约定（架构决策）
[DS 无法从代码推断的选择]

### 测试场景
- 已有测试：必须保持通过 `llvm/test/CodeGen/Dadao/xxx.ll`
- 新增测试：`新文件名.ll`，行为特征：[描述，不写 CHECK]

## 验收条件
[可运行的验证命令]

## 完成区
**状态**：
**修改文件**：
**验收结果**：
**遗留问题**：
```

### 4.3 知识库引用

引用格式用章节号（`§3.1`），不用行号（行号会变）：

```markdown
## 前置知识
- `code-agent/knowledge/02-llvm-backend-howto.md` §5 — LLVM 22 LowerCCCArguments 接口
```

---

## 5. 日常工作流

### 5.1 下发任务

1. 创建任务文件
2. 用 `/dispatch <task-id>` 生成标准下发指令
3. 将指令复制给对应 DS 会话

下发指令格式：

```
## 下一步（→ 本地 DS · <仓库名>）
AI：DeepSeek / Gemini（理由一句话）

> 请先读取 DS.md，然后执行 code-agent/tasks/<文件名>.md
```

### 5.2 任务返回处理

用 `/rt <task-id>`（即 `/review-task`）：

1. 读任务文件完成区
2. 检查代码变更（`git status` + 读相关文件）
3. 轻量问题直接修复，阻断问题报告用户
4. 按需更新 memory 和知识库
5. Review 通过 → 自动 commit（不自动 push）

### 5.3 AI 选型

| → DeepSeek | → Gemini |
|-----------|---------|
| 实现/修复/重构 | 调研/搜索 |
| 多文件改动 | 构建/运行/测试 |
| 调试排错 | 单文件只读 |
| 算法实现 | 知识库整理 |

### 5.4 多仓库并行

不同 DS 会话的任务可并行；同一会话内串行（等上一个返回再发）。

下发指令中每条必须标注目标会话，用户一眼看清。

远端任务记得从 `gpt-registry.md` 路由表取 scp 命令，先同步任务文件再下发。

### 5.5 知识库维护

每次任务完成后检查是否需要更新知识库：
- 新的 API 用法、踩坑记录 → 追加到对应章节
- `10-changelog.md` 追加一行记录（格式：`| 日期 | 描述 | DS/Claude |`）
- 纯测试修复、注释调整、知识库已覆盖 → 无需更新

---

## 6. 框架维护

修改 `~/claude-agent/` 中的文件后，立即同步已部署的拷贝：

| 修改文件 | 同步目标 |
|---------|---------|
| `collab-framework/DS-common.md` | `~/.claude/collab-framework/DS-common.md` |
| `memory-template/` | 仅新机器初始化时用，已有 memory 不覆盖 |

框架仓库的 commit 和 push 均须用户确认（与项目仓库规则一致）。

---

## 7. 关键路径速查

| 用途 | 路径 |
|------|------|
| 通用 DS 规则 | `~/.claude/collab-framework/DS-common.md` |
| DS 路由注册表 | `~/.claude/projects/-home-$(whoami)/memory/gpt-registry.md` |
| 全局 memory 索引 | `~/.claude/projects/-home-$(whoami)/memory/MEMORY.md` |
| 全局 CLAUDE.md | `~/.claude/CLAUDE.md` |
| 新项目 DS.md 模板 | `~/claude-agent/collab-framework/DS-template.md` |
| 新项目 code-agent 模板 | `~/claude-agent/collab-framework/code-agent/` |
