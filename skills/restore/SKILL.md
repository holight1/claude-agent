---
description: "Restore session context - read .session-context.md and display current task, root cause, and next steps"
disable-model-invocation: true
---

# /restore - 恢复会话上下文

读取会话上下文文件，展示当前工作状态。

## 会话上下文内容

```
!`cat code-agent/.session-context.md`
```

## 指令

请基于上方会话上下文内容，向用户展示：

1. **当前任务**：任务名称和简要描述
2. **根因/进展**：如有根因分析则展示关键发现，否则展示当前进展
3. **下一步**：接下来需要做什么
4. **历史任务**：简要展示任务状态表

用简洁的格式呈现，不要重复原文全文。
