---
name: simplification-audit
description: Use only when explicitly asked to find simplification or removal candidates — separates production consumers from test and doc references, computes net deletion, reads existing decisions, and argues the strongest case against each candidate.
---

# 简化候选审计

**状态**：stub
**消费者**：架构师
**投影**：无
**来源**：dsh `dsh-find-simplifications`
**触发条件**：**用户明确要求**简化、瘦身或寻找候选（不自动触发）
**核心判断**：删掉它之后，谁会在什么场景下重新把它加回来？

## 待补内容

正文未写。已知必须覆盖的：

- 区分**生产消费者**与测试 / 文档引用；只被测试引用不等于没人用
- 检查所有权和生命周期，计算**净删除量**
- 先读既有决策记录，再对每个候选提出**最强的反方理由**
- 少量高证据候选优于一堆薄猜测

见 `../README.md §补写一个 skill`。
