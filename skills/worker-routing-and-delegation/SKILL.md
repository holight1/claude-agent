---
name: worker-routing-and-delegation
description: Use when choosing between executor, subagent, and independent reviewer for a task, or when creating a sub-task — routes by verifiability and semantic risk rather than by file type or diff size.
---

# Worker 路由与委托

**状态**：stub
**消费者**：架构师（CC）
**来源**：dsh 的委托边界 + DSH-003a（策略继承、管理者所有权、失败事实三条边界）
**触发条件**：选择 DS / Subagent / Codex，或创建子任务
**核心判断**：架构师能不能独立验证这件事的结果？

## 待补内容

正文未写。已知必须覆盖的：

- 路由判据是**验收能不能机械核对**，不是「话题是否属于易造假域」，也不是改动行数
- 独立审查的触发条件应是「架构师存在无法自我验证的部分」，**不是文件类型**（当前"纯文档任务跳过 Codex"是按类型触发，待改）
- 委托只快照**明确可继承的策略**，禁止隐式继承上下文
- 由持有父子关系的一方发起结算；失败只暴露有界且可归属的事实
- 已实测的执行端行为修正见 memory `collab-framework`：本地 DS 在门槛写松时精确满足字面（不补漏洞但也不造假），遇自相矛盾的任务原文时按声明的**目的**执行并写明偏离理由

**依赖一个未决的框架决策**：`USAGE.md` 里"改动超过 3 行就下发"这条按行数路由的规则待删——行数不是内部依赖、语义风险或可验证性的可靠代理。

见 `../README.md §补写一个 skill`。
