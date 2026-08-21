---
name: task-contract-design
description: Use when writing or substantially revising a task file and its acceptance conditions — maps each claim to a real object and observable result, and hunts for the bypass, no-op, and literal-satisfaction space before dispatch.
---

# 任务合同设计

**状态**：stub
**消费者**：架构师（CC）
**来源**：本框架任务设计实践 + dsh 的门禁自负测试原则
**触发条件**：创建或大改任务文件、验收条件
**核心判断**：这条验收条件，作弊是不是比做对更容易？

## 待补内容

正文未写。已知必须覆盖的：

- 每项主张映射到：真实对象、可观察结果、处理单元数、负测试
- 主动寻找旁路、空转、缩小样例、字面满足（gate-gaming）的空间
- 门槛的强度上限 = 写任务时的思考深度；写松了执行端会精确满足字面
- 任务 md 要**技术信号压倒 meta**：防造假纪律常驻在 `DS-common.md`，任务里只一行引用
- 写架构决策 + 测试场景，不写实现伪码 / 行号 / 手把手步骤

与 `task-acceptance-replay` 用同一批事故互为负测试：验收时发现的漏洞，回头必须能指出任务设计里哪一条没写死。

见 `../README.md §补写一个 skill`。
