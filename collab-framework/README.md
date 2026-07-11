# 框架目录

| 文件 | 用途 |
|---|---|
| `COORDINATOR.md` | Codex 协调者的完整操作规则 |
| `ROUTING.md` | Luna Med / Terra Med / Terra High 选型与升级规则 |
| `TRACEABILITY.md` | 文件布局、身份、revision、证据和状态机规范 |
| `AGENTS-template.md` | 合并到具体项目的协作入口 |
| `task-template.md` | 任务合同模板 |
| `attempt-template.md` | worker 执行记录模板 |
| `review-template.md` | Terra High 审查记录模板 |
| `decision-template.md` | 架构裁决模板 |
| `code-agent/README.md` | 项目内过程目录说明 |

这套框架刻意不提供某个供应商 CLI 的固定命令。Coordinator 应使用当前环境可用的 agent 调度接口，并把实际模型、agent 标识和工作区写入记录；调度能力不足时必须如实记录 fallback，不能把普通模型标成 Terra High。
