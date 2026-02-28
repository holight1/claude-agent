---
description: "Route tasks to the right AI - Gemini (unlimited) or GPT 5.3 (stronger, token-limited)"
allowed-tools: ["Read", "Glob"]
argument-hint: "<task-id or task description>"
---

# /assign-ai — AI 选型路由

每个项目同时拥有 **Gemini**（代码分析师，token 几乎无限）和 **GPT 5.3**（编码者，token 有限）。
根据任务特性选择合适的 AI，避免浪费 GPT token 或将复杂任务错交给 Gemini。

---

## Tradeoff 原则

| 维度 | Gemini | GPT 5.3 |
|------|--------|---------|
| **能力** | 弱（分析为主，不写代码） | 强（实现/调试/多步推理） |
| **token** | 几乎无限 | 有限，省着用 |
| **适合任务** | 大量读代码、提炼知识、结构化输出 | 实现/修复/调试/多文件改动 |
| **输出** | Markdown 知识文件 → 交给 Claude 写入知识库 | 代码改动 → 直接提交 |

**核心 tradeoff**：
- 能用 Gemini 做的先用 Gemini（省 GPT token）
- 但 Gemini 做不好的别强行用（分析错误比浪费 token 更贵）

---

## 路由规则

### → GPT 5.3（更强，token 有限，省着用）

满足以下任一条件时选 GPT 5.3：

| 条件 | 判断依据 |
|------|---------|
| **实现类任务** | task-id 或描述含 `impl`/`fix`/`refactor`/`build` |
| **多文件改动** | 任务涉及 2 个以上文件的修改 |
| **调试/排错** | 任务描述含 `debug`/`错误`/`失败`/`崩溃`/`排查` |
| **结果正确性要求高** | 如算法实现、结果验证、数值对比 |
| **需要推理判断** | 任务没有明确输出格式，需要多步分析后做决策 |

### → Gemini（无限量，适合大量读取/整理工作）

满足以下任一条件时选 Gemini：

| 条件 | 判断依据 |
|------|---------|
| **代码库深度分析** | 需要读取 5 个以上源文件并提炼知识 |
| **调研/搜索类** | task-id 或描述含 `research`/`recon`/`调研`/`调查` |
| **构建/运行/测试执行** | 任务主要是跑命令、执行测试、收集输出 |
| **知识库整理** | 填写模板、更新 changelog、归档任务 |
| **结构化输出** | 任务有明确的输出格式，Gemini 按模板填写即可 |

### 默认规则

- 调研先行 → **Gemini**
- 实现跟进 → **GPT 5.3**
- 不确定时：任务简单/输出固定 → Gemini；任务模糊/需要判断 → GPT 5.3

---

## 执行步骤

### 1. 读取任务文件（若有 task-id）

在当前仓库 `code-agent/tasks/` 下查找任务文件，读取**任务标题**和**执行步骤**前几行。

### 2. 应用路由规则

对照上表，选出目标 AI。若两类条件都有，以**实现/调试类**为准（选 GPT 5.3）。

### 3. 输出路由结论

**若目标为 GPT 5.3：**
```
任务：<task-id> — <标题>
→ 目标：GPT 5.3（本地 / 远端）
→ 理由：<一句话>

下发指令：
> 请先读取 CHATGPT.md，然后执行 code-agent/tasks/<文件名>.md
```

**若目标为 Gemini：**
```
任务：<task-id> — <标题>
→ 目标：Gemini · <仓库名>
→ 理由：<一句话>

下发指令：
> 请先读取 GEMINI.md，然后执行 code-agent/tasks/<文件名>.md
```

> **注**：Gemini 任务的 `执行环境` 字段填 `Gemini · <仓库名>`，dispatch 格式与 GPT 相同，
> 但读取 `GEMINI.md` 而非 `CHATGPT.md`。

---

## 快速参考表

| 任务类型 | AI |
|---------|-----|
| 任务类型 | AI |
|---------|-----|
| **大型代码库深度分析**（公开项目/多文件读取） | **Gemini** |
| 项目结构调研 | Gemini |
| API 接口调研 | Gemini |
| 构建 & 运行测试 | Gemini |
| smoke test / 回归测试 | Gemini |
| 知识库/changelog 更新 | Gemini |
| 单一函数实现 | GPT 5.3 |
| Bug 修复 | GPT 5.3 |
| 多文件重构 | GPT 5.3 |
| 算法实现 & 验证 | GPT 5.3 |
| 调试排错 | GPT 5.3 |
| 复杂配置脚本修改 | GPT 5.3 |
