---
description: "Show current task status from session context"
disable-model-invocation: true
---

# /task - 显示当前任务

从会话上下文提取并展示当前任务状态。

## 会话上下文

```
!`cat /home/holight/code-agent/.session-context.md`
```

## 指令

基于上方会话上下文，用简洁格式展示：

1. **当前任务**：名称 + 一句话描述
2. **状态**：进展到哪一步
3. **下一步**：立即需要做的事
4. **历史任务表**：仅显示状态表格

不要展示根因分析等详细内容，保持简短。
