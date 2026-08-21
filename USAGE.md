# USAGE.md — 架构师 Agent 工作指南

本文档面向架构师 Agent（Claude / Codex / DS 均可担任，需具备工具调用和持久 memory 能力）。包含：首次 Setup、新项目初始化、核心原则、任务文件规范、日常工作流。

---

## 1. 首次 Setup

用户在新机器上 clone 此仓库后，将以下步骤一次性完成：

### 1.1 部署通用规则文件

```bash
mkdir -p ~/.claude/collab-framework
cp ~/claude-agent/collab-framework/DS-common.md ~/.claude/collab-framework/DS-common.md
```

### 1.2 初始化 Memory

架构师需要维护两份持久化记录，**存在哪里由你自己的 memory 机制决定**：

| 记录 | 内容 | 模板 |
|------|------|------|
| **memory 索引**（MEMORY.md） | 工作规则、项目拓扑、跨项目踩坑 | `memory-template/MEMORY.md` |
| **DS 路由注册表**（gpt-registry.md） | DS 实例 ↔ SSH 路由映射 | `memory-template/gpt-registry-template.md` |

如果你是 Claude Code（从 `~/` 启动），memory 目录在：

```bash
~/.claude/projects/-home-$(whoami)/memory/
```

若该目录不存在，从模板创建并告知用户编辑 `gpt-registry.md` 填入实际 SSH 地址和仓库路径。

其他架构师 Agent 按自己的 memory 机制初始化这两份内容即可，模板内容仅供参考。

### 1.3 部署 Skill 加载路径

判断型 skill 的规范源在 `~/claude-agent/skills/`，启用池在 `~/claude-agent/enabled/`。三个客户端都从启用池取，不各存一份：

```bash
~/claude-agent/scripts/sync-skills.sh          # 校验 + 投影
~/claude-agent/scripts/sync-skills.sh --check  # 只校验，不动客户端目录
```

它做三件事：校验规范源（frontmatter、状态闭集、正文不含具体项目命令）、校验启用池（无悬空链接、只有 `enabled` 状态可入池）、把启用池投影到 Claude Code 与 Codex。**opencode 的配置由人工添加**，脚本只打印需要加的那一行——不改写含密钥的用户配置。

制度与补写顺序见 `skills/README.md`。

### 1.4 完成后汇报

列出已执行的步骤（跳过的说明"已存在"），告知用户下一步是添加项目仓库。

---

## 2. 新项目初始化

每个项目仓库需要 `DS.md` + `code-agent/` 两件套。

### 2.1 创建 REVIEWER.md

```bash
cp ~/claude-agent/collab-framework/REVIEWER-template.md /path/to/project/REVIEWER.md
```

打开文件，替换 `[PROJECT_NAME]`，在"项目特有约束"节补充项目特有的禁读文件和已知接受状态。

⚠️ **过渡期**：本文件 2026-08-21 由 `CODEX.md` 更名为 `REVIEWER.md`，同时审查节名由 `## Codex Review` 统一为 `## 独立审查`。**既有项目仍是旧名**，由各项目会话在下次同步框架时改，改的时候连 `DS.md` 里的引用和任务文件的节名一起改。**以该项目实际存在的文件名为准**，不要两个名字都写。

### 2.2 创建 DS.md

从模板复制到项目根目录：

```bash
cp ~/.claude/collab-framework/DS-template.md /path/to/project/DS.md
```

DS.md 头部固定引用通用规则：

```markdown
**阅读顺序：先读 `~/.claude/collab-framework/DS-common.md`，再读本文件。**
```

**初始 DS.md 只填基础字段（角色、项目背景、构建命令），其余字段等第一次调研任务完成后由架构师补充。**

> **建议**：新项目第一个任务始终是调研（让 DS 读仓库结构、构建系统、关键模块边界）。DS 返回后架构师用结论补充 DS.md 的仓库布局、知识库初始章节，再开始开发任务。

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

## 3. 协作模型

### 3.0 四角色流水线

```
CC（任务设计）→ 执行端（实现 + 本地 commit）→ 独立审查 → CC（复跑验收 + 收尾 commit）
```

| 角色 | 职责 | 工具 |
|------|------|------|
| **CC**（Claude Code） | 架构决策、任务拆解、复跑验收、收尾 commit、push | 长上下文 + memory + 工具调用 |
| **DS**（DeepSeek） | 按任务文件实现，填写完成区，**为本任务做本地 commit（不 push）** | 编码 + 验证 |
| **Subagent**（架构师执行分身） | 复杂 / 框架内部 / 验证关键任务的实现——保有架构师上下文、独立跑通并自审 | 全工具 + 隔离会话 |
| **独立 reviewer** | 按 `REVIEWER.md` 审查，输出 `## 独立审查` | 只读 + 写审查节 |

**独立审查的触发条件不是文件类型，是这一问**：

> **这次交付里，有没有架构师自己无法验证的部分？**

有 → 引入独立审查，并在请求里点名那一部分。没有 → 不引入。文档任务同样可能含无法自我验证的事实主张，**不因为"没有代码改动"就跳过**。

架构师应在每轮明确说出「本轮我无法自我验证的是 X」，由用户判断是否需要额外交叉审查——这个判断不由架构师独占。判据全文见 skill `worker-routing-and-delegation`。

Codex 的触发方式：CC 在 `/rt` 看到"无 Codex review"提示后，用户手动发送给 Codex：
```
> 请先读取 REVIEWER.md，然后 review code-agent/tasks/<文件名>.md
```

### 3.5 Subagent 与独立验证（实战补充）

DS 擅长独立、无框架内部依赖、无语义分支的活。但**复杂框架内部**（模拟器内部管道、编译器 CodeGen 的 SelectionDAG/寄存器分配）、**语义细腻**（偏离模板的指令、跨 bank/宽度不对称）、或**验证关键**（差分/黄金模型）的任务，DS 会反复翻车：删掉挡路的工作文件去"解锁"、写矛盾/夸大的完成区、伪造构建/运行输出（假 PASS）。

**对策三条**：

1. **这类活派 subagent，不派 DS**——subagent 是架构师的执行分身，保有完整上下文、能独立跑通并按 reviewer 规则自审；建过某组件的 subagent 续跑该组件最可靠（`SendMessage` 续跑保上下文，新 `Agent` 从零起）。DS 只接独立、无内部依赖的活。

2. **架构师独立复跑 ground-truth 验收，绝不采信完成区 / 自审**——不管是 DS 还是 subagent 交回，验收都亲自重跑（重 build、重跑测试/差分、`cmd; echo $?` 核退出码）。「编过」≠「能跑」；自填的 Codex Review / 完成区可能与实际树不符。复核时优先查 `git status` 有没有 `D`（删了之前能工作的文件/hook）——这是回归高频根因。

3. **易造假域的任务文件放硬门槛**——要求完成区**贴真实构建/运行输出**（如 llc 的真实 MIR、差分的真实计数），并要**负测试**证断言有牙齿（故意改错期望值 → 必须变红）。任务里写明「架构师会重 build 重跑核对，伪造/估算一律打回」。给足硬门槛时 DS 也能干净交付；放养则造假。

> 一句话：**worker 按「有无框架内部依赖 / 语义细腻度」选，不只按「大小」选；验收永远以架构师亲自复跑的 ground-truth 为准，完成区和自审只是线索。**

## 4. 核心原则（原 §3）

### 3.1 架构师职责

架构师可以是任何具备长上下文、工具调用、持久 memory 的 AI（Claude / Codex / DS 均可）。

- **做**：设计接口/约束、拆任务、Review 代码、提交
- **不做**：复杂调研（创建调研任务让 DS 做）、具体实现（交给 DS）

**可以直接做（不需要下发）**：
- Review 中发现的明确错误：单行/双行更正（错误 CHECK 值、漏改引用、文档笔误、格式问题）
- 已有测试的验收运行（`llvm-lit`、`ninja` 等）
- memory / 任务文件 / 知识库更新

**必须创建任务下发 DS**：
- 任何新代码实现（新指令定义、新格式类、新函数、新文件）
- 调研 / 分析 / 文档查阅
- 多步骤修复序列（例如"build loop"、连续修复多个阻断）

**判断方法**：**这件事做完之后，我能不能用命令独立核对它做没做到？**

- 能 → 可以下发执行端。门槛写死，验收按 `task-acceptance-replay` 复跑
- 不能 → 三选一：改任务设计让它可验证（回 `task-contract-design`）／换 subagent（保有架构师上下文、能独立跑通并自审）／自己做

⚠️ **不按改动行数路由。** 行数不是内部依赖、语义风险或可验证性的可靠代理——三行改一个不变量，比三百行加测试危险得多。判据全文见 skill `worker-routing-and-delegation`。

Review 中阻断问题（设计不符、ABI 破坏、多文件重构）：报告用户，视情况下发修复任务。

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
- **meta-process 的大段重复**——防造假/验收纪律/自审流程是 DS-common + DS.md 的**常驻内容**，任务里**只一行引用**（"验收纪律见 DS-common、自审见 DS.md §自审流程"），**不要每个任务重贴一整块**。

**任务保持技术本位（重要）**：DS 是较弱的执行者，任务 md 里**技术信号（目标/约束/验收对象/参考）必须压倒 meta**。若一半篇幅是防造假/自审/复跑的墙，会：(1) 稀释真正要做的事；(2) 把"最显眼的可验证门槛"变成 DS 优化的目标——诱导它满足门槛的**字面**而丢**意图**（gate-gaming：手搓一个能过命令的产物、缩到不触发问题的简单情形）。**规则越短越硬越难绕；文字堆得越多越被钻空子。** meta 收敛到常驻一处、任务只精简引用。

**建议（非强制）**：复杂功能先落盘设计文档 `code-agent/designs/<name>.md`，再从设计创建任务文件。多 DS 会话可以共享同一份设计背景，也方便架构师在 review 时对照初衷。

### 3.3 两层 DS.md 结构

| 文件 | 内容 | 维护者 |
|------|------|--------|
| `~/.claude/collab-framework/DS-common.md` | 通用规则（commit 边界、完成区格式、安全清理、查询顺序） | 此仓库统一维护 |
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

详细流程见 `collab-framework/dispatch.md`。核心步骤：

1. 确认任务文件存在（`code-agent/tasks/NNNx-描述.md`）
2. 读取 `**执行环境**` 字段，若为远端则先 scp 同步任务文件（路由从 `gpt-registry.md` 取）
3. 输出标准下发指令：

```
## 下一步（→ 本地/远端 <nickname> DS · <仓库名>）
AI：DeepSeek（理由一句话）
> 请先读取 DS.md，然后执行 code-agent/tasks/<文件名>.md
```

### 5.2 任务返回处理

详细流程见 `collab-framework/review-task.md`。核心步骤：

1. 远端任务先 scp 拉回最新任务文件
2. 读完成区，确认状态和遗留问题——**它们是线索，不是结论**
3. **亲自复跑**取 ground truth，按 skill `task-acceptance-replay`；执行端已 commit 时先核对箱内清单与完成区是否一致、箱外有无残留（跨仓项目按两个仓分别核）
4. Review 代码（有改动时）：轻量问题直接修复，阻断问题报告用户
5. 更新 memory 和知识库
6. 终审必做最后一步：本轮发现能指回任务设计的哪一条？指不出来按 `process-gap-capture` 落 process-note
7. 通过 → 架构师做收尾 commit（**不自动 push**；执行端自己那个 commit 不代表通过）

### 5.3 DS 实例选择

当前所有任务统一走 DeepSeek。根据运行位置（本地 / 远端）从 `gpt-registry.md` 取对应实例。

### 5.4 多仓库并行

不同 DS 会话的任务可并行；同一会话内串行（等上一个返回再发）。

下发指令中每条必须标注目标会话，用户一眼看清。

远端任务记得从 `gpt-registry.md` 路由表取 scp 命令，先同步任务文件再下发。

### 5.5 知识库维护

每次任务完成后检查是否需要更新知识库：
- 新的 API 用法、踩坑记录 → 追加到对应章节
- `10-changelog.md` 追加一行记录（格式：`| 日期 | 描述 | DS/架构师 |`）
- 纯测试修复、注释调整、知识库已覆盖 → 无需更新

---

## 6. 框架维护

修改 `~/claude-agent/` 中的文件后，立即同步已部署的拷贝：

| 修改文件 | 同步目标 |
|---------|---------|
| `collab-framework/DS-common.md` | `~/.claude/collab-framework/DS-common.md` |
| `memory-template/` | 仅新机器初始化时用，已有 memory 不覆盖 |
| `skills/` 或 `enabled/` | 跑 `scripts/sync-skills.sh` |
| 任何框架文件 | 跑 `scripts/check-framework.sh`，并当轮 commit（不 push） |

**改框架前后都跑 `scripts/check-framework.sh`。** 它校验 skill、校验决策记录、并守卫工作树——本仓被多个架构师会话共写，未提交状态会被下一个会话误扫进自己的提交或误删。

**改动触及行为、约定、流程、工具或持久格式时，写一条 `decisions/` 记录。** 判定闭集与写法见 skill `decision-record-authoring` 与 `decisions/README.md`。

框架仓库的 commit 和 push 均须用户确认（与项目仓库规则一致）。

---

## 7. 关键路径速查

| 用途 | 路径 |
|------|------|
| 通用 DS 规则 | `~/.claude/collab-framework/DS-common.md` |
| DS 路由注册表 | `gpt-registry.md`（存储位置由架构师 memory 机制决定） |
| 全局 memory 索引 | `MEMORY.md`（存储位置由架构师 memory 机制决定） |
| 全局 CLAUDE.md | `~/.claude/CLAUDE.md` |
| 新项目 DS.md 模板 | `~/claude-agent/collab-framework/DS-template.md` |
| 新项目 code-agent 模板 | `~/claude-agent/collab-framework/code-agent/` |
| Skill 规范源 / 启用池 | `~/claude-agent/skills/` · `~/claude-agent/enabled/` |
| Skill 投影脚本 | `~/claude-agent/scripts/sync-skills.sh` |
| 框架总门禁 | `~/claude-agent/scripts/check-framework.sh` |
| 框架决策记录 | `~/claude-agent/decisions/` |
