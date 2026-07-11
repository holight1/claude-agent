# code-agent 过程目录

```text
tasks/       Coordinator 维护的任务合同和状态索引
attempts/    每次 Worker/Coordinator 修正的不可覆盖记录
reviews/     每轮 Terra High 审查的不可覆盖记录
decisions/   必要的架构裁决
knowledge/   可复用的稳定技术知识
```

命名和字段见 `~/claude-agent/collab-framework/TRACEABILITY.md`。失败记录也必须保留；不要把运行流水账写入 knowledge。
