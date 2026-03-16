---
description: "Save session context - write current progress and key findings to persistent memory"
allowed-tools: ["Read", "Write", "Edit"]
---

# /save - 保存当前进展到 memory

将本次会话的重要发现、决策或进展写入 `~/.claude/projects/-home-holight/memory/`，
使下次会话可以感知上下文。

## 执行步骤

1. 回顾本次会话：完成了什么、发现了什么、有什么决策
2. 判断哪些信息值得跨会话保留（已解决问题、架构决策、环境发现等）
3. 更新或新建对应 memory 文件：
   - **project 类**：进展状态、重要决策、遗留问题 → `memory/project_<topic>.md`
   - **feedback 类**：纠正了什么行为 → `memory/feedback_<topic>.md`
   - **reference 类**：新发现的外部资源位置 → `memory/reference_<topic>.md`
4. 同步更新 `memory/MEMORY.md` 索引（若新建了文件）

## 判断是否需要 save

若本次会话只做了常规代码查看、任务下发，无新发现，直接告知用户无需保存。

## 注意

- 不再维护 `session-context.md`（已废弃）
- memory 文件用 frontmatter 格式，见 MEMORY.md 中的类型说明
