# 使用指南

本文档说明如何使用 Claude + ChatGPT Codex 协作框架完成实际开发工作。

---

## 目录

1. [核心思路](#1-核心思路)
2. [快速开始](#2-快速开始)
3. [下发调研任务](#3-下发调研任务)
4. [下发开发任务](#4-下发开发任务)
5. [任务文件格式参考](#5-任务文件格式参考)
6. [知识库管理](#6-知识库管理)
7. [多项目逻辑关系](#7-多项目逻辑关系)
8. [会话管理](#8-会话管理)
9. [AI 选型与下发](#9-ai-选型与下发)
10. [项目管理](#10-项目管理)
11. [常见场景示例](#11-常见场景示例)

---

## 1. 核心思路

**分工**：Claude 负责设计和协调，GPT / Gemini 负责编码和调研。

```
用户需求
  → Claude 分析、拆解、创建任务文件
  → /assign-ai 决定派给 GPT 还是 Gemini
  → 用户将任务指令发给对应 AI
  → AI 执行任务、填写结果
  → Claude Review 结果、决定下一步
```

**为什么这样分工？**

- Claude 有完整的对话上下文，适合做设计决策和任务拆解
- GPT / Gemini 每次从零开始，适合聚焦单一任务的编码执行
- 任务文件是两者之间的"合同"，清晰定义输入和输出

**关键约束**：

- AI 每次必须先读 `CHATGPT.md`（或 `GEMINI.md`），获取项目规范
- 每个任务文件是独立的，AI 不依赖之前任务的记忆
- Claude 不自己写代码，调研复杂问题也交给 GPT / Gemini

---

## 2. 快速开始

### 安装

```bash
git clone <repo-url> ~/claude-agent
bash ~/claude-agent/install.sh
```

脚本幂等，可重复执行；已有 memory 不覆盖。

### 初始化新项目

详见 `collab-framework/README.md`，核心是 3 步：

```bash
cd /path/to/your-project

# 1. 配置 GPT 工作规范
cp ~/.claude/collab-framework/CHATGPT-template.md CHATGPT.md
# 编辑 CHATGPT.md，替换顶部占位符（作者、公司、项目名、年份）

# 2. 配置 Gemini 工作规范（可选，有 Gemini 实例时）
cp ~/.claude/collab-framework/GEMINI-template.md GEMINI.md

# 3. 创建协作工作区
cp -r ~/.claude/collab-framework/code-agent/ code-agent/
```

### 开始工作

**推荐从 `~/` 启动 Claude Code**（全局协调者视角）：

```bash
cd ~
claude
```

从 `~/` 启动时，memory 存储在 `~/.claude/projects/-home-<user>/memory/`，
跨项目全局共享，Claude 可同时协调多个仓库的 GPT 任务。
Claude 读取各项目 CLAUDE.md 时仍然正常，无需切换到项目目录。

使用 `/architect` 激活架构师模式开始设计工作。

---

## 3. 下发调研任务

调研任务用于让 GPT **读代码、查资料、回答具体问题**，不要求写代码。

### 何时使用调研任务

- 不了解某个模块的实现方式，需要 GPT 读源码并总结
- 需要确认某个 API 的正确用法（参数、返回值、约束）
- 遇到 bug，需要 GPT 分析调用链和根因
- 技术选型前，需要 GPT 对比多种方案

### 创建调研任务

告诉 Claude 需要调研什么，Claude 会创建任务文件并给出下发指令。
也可以用 `/architect` 让 Claude 进入架构师模式后直接下发。

**调研任务的关键要素**：

1. **具体问题**：禁止模糊目标（如"了解 XX 模块"），必须是可验证的具体问题
2. **知识库引用**：列出相关章节和行号范围，节省 GPT context
3. **调研范围**：指定需要分析的文件列表
4. **输出格式**：明确要求 GPT 给出代码位置和行号

**示例**：

> **用户**：我想知道 serverd 守护进程是怎么初始化设备的，让 GPT 调研一下。
>
> **Claude**：（创建任务文件 `041-research-serverd-init.md`，内容包含：需要分析的文件路径、
> 具体问题列表、知识库相关章节行号）
>
> **下发指令**：`请先读取 CHATGPT.md，然后执行 code-agent/tasks/041-research-serverd-init.md`

### 允许插桩的调研

对于运行时行为分析（如调用顺序、数据流向），可在任务中允许 GPT 插桩：

```markdown
**调试选项**：允许插桩
- 使用 printf("[DEBUG] ...") 格式
- 调试完成后必须移除插桩代码
```

---

## 4. 下发开发任务

开发任务要求 GPT **修改或新建代码**，需要比调研任务更精确的规格说明。

### 何时使用开发任务

- 实现一个明确设计好的功能模块
- 修复已定位根因的 bug
- 重构某段代码（已有明确的目标结构）
- 补充测试用例

### 设计先行原则

**在创建开发任务前**，Claude 应完成设计决策：

- 确定数据结构和接口签名
- 确定文件变更清单
- 确定关键算法或实现方案

设计文档存放在 `code-agent/designs/`，任务文件引用设计文档。

### 开发任务的关键要素

1. **明确的文件变更清单**：GPT 需要新建/修改哪些文件
2. **接口定义**：函数签名、结构体定义（带注释）
3. **实现步骤**：有序、原子化、可独立验证
4. **验证方法**：如何确认实现正确（命令、期望输出）
5. **失败处理**：常见失败场景及处理方法

### 任务粒度控制

- 单个任务应在 2-4 小时内完成
- 复杂功能拆分为多个子任务（用字母后缀：`035a`、`035b`）
- 子任务之间明确依赖关系（"前置任务：035a 完成后执行"）

**示例拆分**：

```
035a  调研：确认 API 参数语义      → 产出：知识库更新
035b  实现：核心数据结构           → 产出：头文件
035c  实现：初始化与销毁逻辑       → 产出：.c 文件
035d  实现：主逻辑                 → 产出：.c 文件
035e  验证：端到端测试             → 产出：测试通过截图
```

### 下发指令格式（固定）

用 `/dispatch <task-id>` 自动生成，或手写：

```
## 下一步（→ [目标 AI 标识]）

请将以下指令发送给 ChatGPT / Gemini：

> 请先读取 CHATGPT.md（或 GEMINI.md），然后执行 code-agent/tasks/<文件名>.md
```

**目标 AI 标识示例**：
- `→ 本地 GPT`
- `→ 远端 51 GPT · <仓库名>`
- `→ Gemini`

多仓库并行时每条指令前都必须有标注，用户一眼看清发给哪个会话。
不清楚该派给谁时，先用 `/assign-ai` 决策。

**注意**：每次给同一个 AI 会话一个任务，等结果回来后再下发下一个。
不同 AI 会话的任务可以并行。

---

## 5. 任务文件格式参考

```markdown
# 任务：<编号> — <标题>

**状态**：pending
**分配给**：[本地 GPT / 本地 GPT · <仓库名> / 远端 51 GPT · <仓库名> / Gemini]
**创建者**：Claude
**执行环境**：[本地 / 远端 user@host · 项目名]
**前置任务**：<编号> 完成后执行（无则删除此行）

---

## 前置知识

- `code-agent/knowledge/<文件>.md` §<章节号>（L<起>-L<止>）— <与本任务的关联>

---

## 背景

<2-3 句话说明为什么需要这个任务，当前状态是什么>

---

## 任务描述

### 步骤 1：<操作>
<具体指令，包含命令或代码示例>

### 步骤 2：<操作>
...

---

## 失败处理

**若 <场景>**：
- <处理方式>

---

## 输出要求

1. <具体产出 1>
2. <具体产出 2>
3. 知识库更新：<若有新发现，更新哪个文件哪个章节>

---

## 执行结果（由 AI 填写）

```

### 编号规则

| 格式 | 用途 | 示例 |
|------|------|------|
| `001` | 独立任务 | `001-research-api.md` |
| `035a` | 系列子任务 | `035a-init.md`, `035b-impl.md` |
| `035a1` | 子任务的子步骤 | `035a1-debug.md` |

---

## 6. 知识库管理

知识库是 Claude 和 GPT 之间共享的持久化信息，存放在 `code-agent/knowledge/`。

### 组织原则

- **按主题分文件**：每个主题一个文件，如 `01-project-structure.md`、`02-api-reference.md`
- **不按任务分文件**：知识是提炼后的结论，不是任务日志
- **变更日志**：`10-changelog.md` 记录每次更新，便于追踪

### 什么内容放知识库

| 放入知识库 | 不放知识库 |
|-----------|-----------|
| 已验证的 API 用法 | 任务执行过程 |
| 踩坑记录与解决方案 | 临时调试信息 |
| 架构决策及原因 | 推测性结论 |
| 关键数据结构定义 | 单次使用的脚本 |

### GPT 使用知识库的规范

任务文件中引用知识库**必须标行号范围**，减少 GPT 加载无关内容：

```markdown
## 前置知识
- `code-agent/knowledge/04-api-reference.md` §4.3（L136-L180）— suKernelSetArgs 参数语义
```

不要写 `阅读整个知识库`，GPT context 有限。

### 知识库同步时机

- GPT 完成任务后，要求其将新发现更新到相关知识库章节
- 任务文件归档（`/optimize`）前检查知识库是否已同步

---

## 7. 多项目逻辑关系

当工作涉及多个相互依赖的仓库时（如：核心库 + 多个适配器），
需要建立明确的协作模式。

### 典型拓扑：核心库 + 适配器

```
[核心库]  提供 API 和运行时
    ↓ 依赖
[适配器A]  如 PyTorch 后端
[适配器B]  如 GGML 后端
```

每个仓库独立维护自己的 `CHATGPT.md` + `code-agent/`，
GPT 分配到具体仓库工作，不跨仓库操作。

### 核心库变更 → 同步到适配器

**标记机制**：核心库 `10-changelog.md` 条目末尾加 `[PUBLIC]`：

```markdown
- 2026-02-10: 修改 suKernelSetArgs 参数顺序，兼容性破坏 [PUBLIC]
```

Claude 看到 `[PUBLIC]` 标记后，将相关内容同步更新到各适配器的知识库章节。

**同步清单**：在核心库 `code-agent/knowledge/00-sync-manifest.md` 维护映射关系：

```markdown
| 核心库章节 | 适配器A同步目标 | 适配器B同步目标 |
|-----------|----------------|----------------|
| §4.3 API  | pytorch/knowledge/05-api.md §3 | ggml/knowledge-base.md §7 |
```

### 适配器发现核心库 Bug → 上报

**标记机制**：适配器任务结果含 `[CORE-BUG]`：

```markdown
## 执行结果
[CORE-BUG] suQueueLaunch 在队列为空时返回 0 而非错误码，导致后续等待超时
```

Claude 看到 `[CORE-BUG]` 后，在核心库 `code-agent/tasks/` 创建对应修复任务。

### 多仓库任务分配

Claude 同时管理多个仓库的任务，但每次只给 GPT 一个仓库的一个任务。

**任务状态追踪**（在 Claude 的 memory 中维护，见 `memory/gpt-registry.md`）：

```
本地 GPT              核心库:   任务 035e 进行中
本地 GPT · <仓库A>    适配器A:  任务 009  进行中
远端 GPT · <仓库B>    适配器B:  任务 049  进行中
```

不同 GPT 会话的任务可以并行；同一 GPT 会话内任务必须串行。

### 远端机器上的仓库

对于需要在特定硬件上运行的任务（如 gem5 模拟器），
知识库需要手动同步：

```bash
# 将本地知识更新同步到远端机器
rsync -av /path/to/repo/code-agent/knowledge/ \
  user@remote-host:~/repo/code-agent/knowledge/

# 将远端测试结果同步回本地
rsync -av user@remote-host:~/repo/code-agent/knowledge/ \
  /path/to/repo/code-agent/knowledge/
```

任务文件也需要同步后才能在远端执行：

```bash
rsync -av /path/to/repo/code-agent/tasks/ \
  user@remote-host:~/repo/code-agent/tasks/
```

---

## 8. 会话管理

Claude Code 使用持久化 memory 系统（`~/.claude/projects/-home-<user>/memory/`）跨会话保持状态，无需手动 save/restore。

Claude 在任务返回处理（architect skill §任务返回处理 步骤 5）时会自动评估是否有值得保留的发现，并更新对应 memory 文件。

### /task — 查看任务状态

快速查看当前进行中的任务：

```
/task
```

### /optimize — 归档与清理

当任务列表积累过多时，归档已完成任务并同步知识库：

```
/optimize
```

执行后：
- 已完成任务移入 `code-agent/tasks/archive/`
- 重要发现同步到知识库

**建议频率**：每完成 5-10 个任务后运行一次。

---

## 9. AI 选型与下发

### /assign-ai — 路由到 GPT 或 Gemini

框架同时支持 **GPT**（能力强，token 有限）和 **Gemini**（token 几乎无限）。
创建任务文件后，用 `/assign-ai` 决定派给谁：

```
/assign-ai <task-id 或任务描述>
```

路由规则（简版）：

| 任务类型 | 推荐 AI |
|---------|---------|
| 简单调研、联网查资料 | Gemini 优先 |
| 复杂多步推理、debug、大型实现 | GPT |
| Gemini 搞不定的 | GPT 重做 |

**`分配给` 字段标注规范**（任务文件头部）：

| 标注 | 含义 |
|------|------|
| `本地 GPT` | SuBase-SY 本地 GPT 会话 |
| `本地 GPT · <仓库名>` | 指定仓库的本地 GPT 会话 |
| `远端 51 GPT · <仓库名>` | 指定远端机器的 GPT 会话 |
| `Gemini` | 本地 Gemini（联网） |

### /dispatch — 输出下发指令

```
/dispatch <task-id>
```

输出固定格式的下发指令，用户复制后发给对应 AI 会话：

```
## 下一步（→ 本地 GPT）

请将以下指令发送给 ChatGPT：

> 请先读取 CHATGPT.md，然后执行 code-agent/tasks/<文件名>.md
```

---

## 10. 项目管理

从 `~/` 启动 Claude 后，用 `/project-add` 和 `/project-remove` 管理哪些项目纳入协调。

### /project-add — 注册项目

```
/project-add /path/to/myproject
/project-add /path/to/myproject remote: user@host:/remote/path
```

Claude 会：
1. 检查项目是否有 `CHATGPT.md` 和 `code-agent/`，缺失时给出补全命令（不阻止注册）
2. 在 global memory（`MEMORY.md` + `gpt-registry.md`）中添加项目拓扑、GPT 实例、仓库条目
3. 若有远端，同时注册 `远端 GPT · <project-name>` 实例和 dispatch 路由

### /project-remove — 注销项目

```
/project-remove myproject
```

Claude 会：
1. 列出将从 memory 移除的条目，请用户确认
2. 从 `MEMORY.md` 删除拓扑块、GPT 实例行、仓库行
3. 将 `gpt-registry.md` 中的对应实例移至"历史停用实例"

**不会修改任何项目文件**——`CHATGPT.md`、`code-agent/`、知识库、任务文件全部保留。
随时可以重新 `/project-add` 恢复管理。

---

## 11. 常见场景示例

### 场景一：从零开始一个新功能

```
1. 用户：我想实现 XX 功能
2. Claude（/architect）：
   - 拆分为 3 个子任务：001a（调研）、001b（实现）、001c（验证）
   - /assign-ai 001a → 派给 Gemini（调研联网）
3. 用户 → Gemini：请先读取 GEMINI.md，然后执行 code-agent/tasks/001a-xxx.md
4. Gemini 完成 001a，填写结果
5. Claude Review，/assign-ai 001b → 派给 GPT（实现）
6. ...循环直到功能完成
```

### 场景二：调试一个已知现象的 bug

```
1. 用户：运行时 crash 在 XX 函数，提供了 stack trace
2. Claude：
   - 创建调研任务，/assign-ai → GPT（需要多步推理定位根因）
   - 允许插桩
3. GPT 定位根因，填写结论
4. Claude：基于根因创建修复任务，/dispatch 输出下发指令
5. GPT 实现修复，Claude Review 修复代码
```

### 场景三：核心库 API 变更，适配器需要跟进

```
1. 核心库 GPT 完成 API 变更任务，在 changelog 中标注 [PUBLIC]
2. Claude 检查 changelog，识别 [PUBLIC] 条目
3. Claude 更新各适配器的知识库对应章节
4. Claude 为每个适配器创建跟进任务（说明 API 变更细节）
5. /assign-ai 分别路由，下发给各适配器的 AI
```

### 场景四：新人接手项目

```
1. 安装 claude-agent（见安装章节）
2. 打开项目目录，启动 Claude Code
3. /restore  ← 恢复会话上下文，了解项目当前状态
4. 阅读 code-agent/knowledge/ 了解项目知识
5. 正常工作
```
