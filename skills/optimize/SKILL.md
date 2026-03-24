---
description: "Optimize context - archive completed tasks, sync knowledge base, reduce context consumption"
allowed-tools: ["Read", "Write", "Edit", "Bash", "Glob"]
---

# /optimize - 归档已完成任务

将 `code-agent/tasks/` 中已完成的任务移至归档目录，减少 context 占用。

## 执行步骤

### 1. 扫描已完成任务

```bash
ls code-agent/tasks/*.md 2>/dev/null
```

读取每个任务文件头部，找出状态为"已完成"的任务。

### 2. 确认归档列表

向用户展示将要归档的任务列表，等待确认：

```
以下任务将归档到 code-agent/tasks/archive/：
  035a-research-xxx.md（已完成，2026-03-10）
  036a-implement-yyy.md（已完成，2026-03-15）

确认归档？
```

### 3. 执行归档

```bash
mkdir -p code-agent/tasks/archive
mv code-agent/tasks/<completed-task>.md code-agent/tasks/archive/
```

### 4. 知识库压缩提示（可选）

若 `code-agent/knowledge/` 中有大量已废弃章节，提示用户：

```
知识库中以下章节可能已过时，建议人工确认后删除：
  （列出修改时间超过 30 天且未被任何任务引用的章节）
```

## 注意

- **不自动删除**任何文件，只移动到 archive/ 子目录
- 归档前必须展示列表并等待用户确认
- 若无已完成任务，告知用户无需归档
