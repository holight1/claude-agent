---
name: decision-record-authoring
description: Use when a change touches behavior, architecture, cross-file conventions, process, tooling, test strategy, or a persisted/wire/config format — decides by closed set whether a decision record is required and captures alternatives, trade-offs, and re-entry conditions.
---

# 决策记录写入

**状态**：stub
**消费者**：架构师 + 执行端（两侧都要，正文共享、引用方式不同）
**来源**：dsh `.agents/notes/` 制度
**触发条件**：非机械改动触及行为、架构、跨文件约定、流程、工具、测试策略、持久 / 线协议 / 配置格式，或维护者可能重议的选择
**核心判断**：将来有人想改回去时，他需要的信息现场有没有？

## 待补内容

正文未写。已知必须覆盖的：

- 用**闭集**判定是否需要记录，不靠感觉判「非平凡」
- 核心语义支点：**事实可就地改写，决策不可改写**——过时的事实原地重写、不追加变更史；但这不是改写**决策**的许可
- 强制记录被否方案，且「**记录而非编造**」（Alternatives are recorded, never invented）
- 取代检查在**写入时**做，不靠周期性审计
- 决策记录是**讨论依据，不是自动否决**；再提案必须击败已记录的理由
- 归档冻结的历史必须**免除演进中的门禁**

见 `../README.md §补写一个 skill`。
