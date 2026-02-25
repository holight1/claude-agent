---
description: "Optimize context - archive completed tasks, sync knowledge base, reduce context consumption"
allowed-tools: ["Read", "Write", "Glob", "Grep", "Bash"]
---

# /optimize - 优化清理

按以下流程执行任务归档和知识库同步，减少 context 消耗。

## 执行流程

### 步骤 1：列出所有任务文件状态

```bash
# 列出所有任务文件
ls -la code-agent/tasks/*.md

# 检查每个任务的状态
grep -l "状态.*done\|状态.*completed" code-agent/tasks/*.md
```

### 步骤 2：识别可清理的任务

**可清理条件**：
- 状态为 `done` 或 `completed`
- 不在"保留列表"中（见下方）

**保留列表**（不清理）：
- 与当前进行中的设计 MD 相关的任务
- session-context.md 中"下一步工作"引用的任务
- 最近 3 个已完成任务（保留作为参考）

### 步骤 3：检查待清理任务的知识库同步

对于每个待清理任务，检查其"执行结果"部分：

1. **是否有新发现的规律/约定？** → 同步到 `code-agent/knowledge/` 对应主题文件
2. **是否有可复用的代码模式？** → 同步到 `code-agent/knowledge/` 对应主题文件
3. **是否修正了之前的错误认知？** → 更新 `code-agent/knowledge/` 对应主题文件

### 步骤 4：检查知识库冗余

审查 `code-agent/knowledge/` 各主题文件：

1. **重复内容**：同一信息出现在多个文件
2. **过时内容**：已被后续任务修正的信息
3. **过于详细**：可精简的描述

### 步骤 5：执行清理

**独立任务**（无关联设计）：
```bash
mkdir -p code-agent/tasks/archived
mv code-agent/tasks/xxx.md code-agent/tasks/archived/
```

**设计-实现配对**（有关联设计文件）：
```bash
mkdir -p code-agent/completed/tasks code-agent/completed/designs
mv code-agent/tasks/xxx.md code-agent/completed/tasks/
mv code-agent/designs/xxx.md code-agent/completed/designs/
```

**重要**：`code-agent/completed/` 目录下的文件**严禁自动加载到 context**，除非用户明确要求。

### 步骤 6：更新 session-context.md

- 从任务表格中移除已归档的任务
- 更新"下一步工作"

---

## 输出格式

```markdown
## Context 优化结果

### 待清理任务
| 任务文件 | 原因 |
|----------|------|
| 040-xxx.md | 已完成，无需保留 |

### 保留任务
| 任务文件 | 保留原因 |
|----------|----------|
| 053-xxx.md | 进行中 |

### 知识库同步
| 来源任务 | 同步内容 | 目标文件 |
|----------|----------|----------|
| 051-xxx.md | 异步资源释放表 | knowledge/02-pitfalls.md |

### 清理统计
- 归档任务数：X
- 知识库新增：X 条
- 知识库精简：X 处
```

---

## 注意事项

- 设计 MD 文件（`code-agent/designs/`）由用户手动清理，此命令不处理
- 如不确定是否应清理某任务，询问用户
- 归档而非删除，便于回溯
