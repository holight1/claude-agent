---
name: decision-record-retirement
description: Use when the decision-record corpus needs pruning or a new record supersedes an old one — decides keep, archive, reject, or delete by future decision value, and freezes archived records from evolving gates.
---

# 决策记录退役

**状态**：stub
**消费者**：架构师（CC）
**来源**：dsh `dsh-archive-agent-notes`
**触发条件**：决策语料达到需要清理的规模，或新记录取代旧记录
**核心判断**：这条记录还在阻止一个**诱人错误**吗？

## 待补内容

正文未写。已知必须覆盖的：

- 保留判据（dsh 原文，两处）：`Keep it only while its rationale prevents a tempting, meaningful mistake; otherwise delete the complete triplet.` / `Keep a rejected note only while it prevents a plausible mistake; otherwise delete its English, Chinese, and sidecar files together.`
- 按**未来决策价值**决定保留 / 归档 / 拒绝 / 删除，不按年龄
- 取代关系在**写入时**检查，不靠周期性审计
- 归档后**永久冻结**：不可编辑、不可改格式、不可移动删除，且**免除演进中的门禁**
- 归档目录应从检索范围排除（`.rgignore` 之类），否则冻结的旧结论会被当成当前权威

见 `../README.md §补写一个 skill`。
