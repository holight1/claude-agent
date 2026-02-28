---
description: "Route tasks to the right AI - Gemini (unlimited, simple first) or GPT 5.3 (stronger, complex tasks)"
allowed-tools: ["Read", "Glob"]
argument-hint: "<task-id or task description>"
---

# /assign-ai — AI 选型路由

每个项目同时拥有 **Gemini**（token 几乎无限）和 **GPT 5.3**（更强，token 有限）。
默认优先用 Gemini，复杂任务或 Gemini 搞不定时升级到 GPT 5.3。

---

## 核心原则

> **简单任务 → Gemini 先做；复杂任务 → GPT 5.3；Gemini 搞不定 → GPT 5.3 重做。**

| 维度 | Gemini | GPT 5.3 |
|------|--------|---------|
| **能力** | 通用，适合简单到中等任务 | 更强，适合复杂多步任务 |
| **token** | 几乎无限 | 有限，省着用 |
| **使用策略** | 默认优先尝试 | 仅当必要时使用 |

---

## 路由规则

### → GPT 5.3（满足任一条件）

- 任务需要**多步骤推理**或**调试排错**（含 debug/fix/排查/崩溃）
- 任务涉及**多文件联动修改**（≥3 个文件）
- **算法实现**或**正确性验证**要求高
- **Gemini 已尝试但结果不满足要求**

### → Gemini（其余情况默认选 Gemini）

- 调研、搜索、代码分析、阅读大量源文件
- 单一任务目标明确、输出格式固定
- 构建/测试执行、知识库整理、changelog 更新
- 简单函数实现或小范围修改

### 升级路径

Gemini 完成任务后，若输出**不满足要求**（分析错误/实现有 bug），
直接创建 GPT 5.3 任务，在任务描述中附上 Gemini 的结论供参考。

---

## 执行步骤

### 1. 读取任务文件（若有 task-id）

在当前仓库 `code-agent/tasks/` 下查找任务文件，读取任务标题和执行步骤。

### 2. 应用路由规则，选出目标 AI

### 3. 输出路由结论

**若目标为 GPT 5.3：**
```
任务：<task-id> — <标题>
→ 目标：本地 GPT · <仓库名>（或 远端 GPT · <仓库名>）
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

> **注**：任务文件的 `执行环境` 字段填对应 AI 标注（如 `Gemini · gem5-a4e`
> 或 `本地 GPT · SuBase-SY`），dispatch 格式相同，读取的 md 文件不同。
