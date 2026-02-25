---
description: "Dispatch a task to ChatGPT - find or create task file and output standard instruction"
allowed-tools: ["Read", "Write", "Glob"]
argument-hint: "<task-id>"
---

# /dispatch <task-id> - 下发任务给 GPT

根据 task-id 找到或创建任务文件，输出标准下发指令。

## 执行步骤

1. **查找任务文件**：在 `code-agent/tasks/` 中搜索匹配 `<task-id>` 的文件
   - 搜索模式：`code-agent/tasks/<task-id>*.md`
   - 如果找到多个匹配，列出让用户选择

2. **检查任务文件**：
   - 确认文件包含必要字段（状态、分配给、任务描述）
   - 确认状态为 `pending` 或需要执行
   - 如果知识库引用缺少行号范围，发出警告

3. **输出下发指令**：

```
---
## 下一步

请将以下指令发送给 ChatGPT Codex：

> 请先读取 CHATGPT.md，然后执行 code-agent/tasks/<完整文件名>.md
```

## 注意

- 如果 task-id 对应的文件不存在，提示用户是否需要创建
- 知识库引用必须标行号范围（如 `L136-250`），无行号的引用要警告
- 下发指令格式是固定的，不要修改
