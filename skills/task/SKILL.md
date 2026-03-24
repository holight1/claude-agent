---
description: "View current task status - list tasks in code-agent/tasks/"
allowed-tools: ["Read", "Glob", "Bash"]
argument-hint: "[task-id]"
---

# /task - 查看任务状态

列出当前项目 `code-agent/tasks/` 中的任务，或查看指定任务详情。

## 执行步骤

### 无参数：列出所有任务

```bash
ls code-agent/tasks/*.md 2>/dev/null || echo "（无任务文件）"
```

对每个任务文件，读取前 10 行，提取：
- 文件名（编号）
- 状态（待执行 / 执行中 / 已完成 / 失败）
- 执行环境（本地 GPT / 远端 XX GPT）
- 任务类型和简述

输出格式：
```
编号      状态        环境              简述
035a      待执行      本地 GPT          research: XXX 模块初始化流程
036a      已完成      远端 21 GPT       implement: YYY 接口
```

### 有 task-id：显示任务详情

```bash
cat code-agent/tasks/<task-id>*.md
```

直接输出任务文件完整内容，重点标注"完成区"部分。

## 注意

- 若在全局 `~/` 目录运行，提示用户指定项目目录（`/task` 需在项目根目录下运行）
- 已完成任务若过多，建议使用 `/optimize` 归档
