---
name: knowledge-distillation
description: Use only when explicitly asked to distill source material into the knowledge graph — runs the layer 1 to 3 pass, checks existing nodes first, merges evidence for the same question, and lands only a few patterns per phase.
---

# 知识蒸馏入图

**状态**：stub
**消费者**：架构师（CC）
**来源**：本框架 DSH-002a / 003a 抽取实践 + `~/knowledge-graph` 的既有纪律
**触发条件**：**用户明确要求**从材料进入知识图谱（不自动触发）
**核心判断**：这条是二层方法学，还是这个项目的一层事实？

## 待补内容

正文未写。已知必须覆盖的：

- 执行 Layer 1 → 2 → 3；**先查已有节点**，同一问题合并证据而不是新开节点
- 每个 Phase 只落 **1–3 个模式**，不按「预计 15–25 条」一次性灌入
- 保留来源限定与置信度；不把「该项目如此设计」当成「该做法有效」
- 落盘后跑图谱自带的链接与索引校验脚本（入口见 `~/knowledge-graph/README.md`）——半角/全角引号不一致会造成悬空链接，这是图谱历史上 43% 悬空的同一根因

见 `../README.md §补写一个 skill`。
