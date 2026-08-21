---
name: browser-ui-evidence
description: Use when a change to a graphical interface needs visual proof — runs the real service at a pinned commit with isolated state, captures one evidence run per semantic state, and discloses any mock or fixture explicitly.
---

# 界面可视证据

**状态**：stub
**消费者**：架构师
**投影**：无
**来源**：dsh `record-browser-gif`
**启用前提**：项目有 GUI，且变更需要可视证据
**核心判断**：截图里那个界面，是不是真实交付链路跑出来的？

## 为什么保留而不是 dropped

当前三个受管仓都没有 GUI，但**三步走的终点 H3 Agent 是视频生成产品**（参考 S3 方案），可视证据是必然出现的场景。到时候需要的是判断程序，不是临时发挥。

## 待补内容

正文未写。已知必须覆盖的：

- 精确提交、**真实服务**、隔离状态、单次证据运行
- 按**语义状态**截图，不按操作步骤
- Mock 或 fixture **必须明确披露**，不得冒充真实链路——这与 `task-acceptance-replay` 的「校验必须作用于真实交付入口」是同一条

**强制政策不得上升为框架通则**：「所有 GUI 改动必须带 GIF」只能由项目适配层声明。

见 `../README.md §补写一个 skill`。
