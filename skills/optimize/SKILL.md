---
description: "Optimize context - archive completed tasks, sync knowledge base, reduce context consumption"
allowed-tools: ["Read", "Write", "Glob", "Grep", "Bash"]
---

# /optimize - 创建清理任务并下发给 GPT

任务清理统一由 GPT/Gemini 执行，Claude 负责创建任务文件并下发。

## 执行流程

### 步骤 1：确定清理范围

询问用户或从上下文判断：
- 清理哪些仓库（默认：当前会话涉及的所有仓库）
- 哪些任务文件**保留**（通常是状态 `pending` 且当前正在执行的）
- 清理目标：归档已完成任务，检查知识库覆盖

### 步骤 2：列出各仓库任务文件

```bash
ls ~/SuBase-SY/code-agent/tasks/
ls ~/gem5-a4e/code-agent/tasks/
ls ~/a4e_multi_core/code-agent/tasks/
ls ~/llama.cpp-SY/ggml/code-agent/tasks/
ls ~/pytorch/code-agent/tasks/
# 根据实际项目调整
```

### 步骤 3：创建清理任务文件

任务文件位置：`~/code-agent/tasks/<id>-cleanup-<scope>.md`

任务文件模板：

```markdown
# 任务：<ID> — <仓库/范围> 任务清理

**状态**：pending
**分配给**：Gemini
**创建者**：Claude
**执行环境**：本地 GPT · <主仓库>（Gemini 实例，跨仓库操作）
**工作目录**：`/home/holight`

---

## 保留任务

（列出不得归档的任务文件，含原因）

## 执行步骤

对每个仓库按此流程：

### 步骤 1：读任务文件，检查知识库覆盖

对每个任务文件：
1. 读取"执行结果"部分（若有）
2. 判断是否有尚未进入知识库的关键信息（坑点、根因、API 约定、架构细节）
3. 若有，补充到对应知识库章节，在 `10-changelog.md` 追加记录

### 步骤 2：归档

```bash
mkdir -p <repo>/code-agent/tasks/archived
mv <repo>/code-agent/tasks/<task>.md <repo>/code-agent/tasks/archived/
```

无执行结果的纯 pending 任务可直接删除。

## 各仓库任务清单

（列出每个仓库需处理的任务文件名）

## 执行结果

（GPT 填写）

## 下一步（→ 本地 GPT · <仓库>）

> 请先读取 ~/<仓库>/GEMINI.md，然后执行本任务文件
```

### 步骤 4：输出下发指令

```
---
## 下一步（→ 本地 GPT · <仓库>）

**AI：Gemini**（理由：清理/整理任务，无代码实现）

请将以下指令发送给 Gemini：

> 请先读取 ~/<主仓库>/GEMINI.md，然后执行 ~/code-agent/tasks/<完整文件名>.md
```

---

## 注意事项

- Claude **不自己执行**清理，只创建任务文件并输出下发指令
- 清理任务统一放在 `~/code-agent/tasks/`（全局任务目录）
- 归档而非删除，便于回溯
- 知识库更新：GPT 在任务文件"执行结果"中列出补充摘要
- 设计文档（`code-agent/designs/`）由用户手动清理，不纳入此任务
