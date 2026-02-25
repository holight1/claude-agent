---
description: "Save session context - update .session-context.md with current progress"
allowed-tools: ["Read", "Write"]
---

# /save - 保存会话上下文

根据当前会话的工作进展，更新 `code-agent/.session-context.md`。

## 执行步骤

1. 读取当前 `code-agent/.session-context.md`
2. 根据本次会话中的工作进展，更新以下内容：
   - **当前任务**：更新任务名称和描述（如有变化）
   - **根因/进展**：补充新发现或新进展
   - **下一步**：更新为最新的下一步计划
   - **历史任务状态**：更新任务状态表
   - **更新时间**：设置为今天日期
3. 写回文件

## 格式要求

保持现有的 markdown 格式结构。只更新有变化的部分，不要重写未变化的内容。

## 注意

- 如果本次会话没有实质性进展，告知用户无需保存
- 保持内容简洁，避免冗长描述
