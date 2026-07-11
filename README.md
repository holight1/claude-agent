# Codex Subagent Collaboration Framework

一套以 Codex 为协调者、以分级 subagent 为执行与审查单元的可追溯协作框架。

核心分工：

| 角色 | 默认模型 | 职责 |
|---|---|---|
| Coordinator | Codex | 定义任务合同、选择模型、隔离工作区、裁决审查、提交 |
| Simple Worker | Luna Med | 机械、局部、低语义风险的实现或整理 |
| Complex Worker | Terra Med | 需要调试、跨文件推理或系统语义理解的实现 |
| Reviewer | Terra High | 独立审查所有代码和技术交付，复跑关键验收，不参与原实现 |

框架不以“改动行数”判断复杂度，而以错误后果、语义耦合和验证难度判断。任务合同、执行证据和审查结论分别落盘，任何人都不能覆盖其他角色的记录。

## 设计目标

- 可追溯：能回答谁、用什么模型、基于哪个 revision、运行了什么、发现和修正了什么。
- 可复现：验收命令、退出码、关键输出和环境事实都保存在 attempt/review 记录中。
- 角色隔离：实现者不能宣布 review 通过；reviewer 不替实现者静默改代码。
- 可恢复：会话中断后，只读任务状态和关联记录即可继续。
- 轻量：任务 md 保持技术本位，通用流程只在框架文档中定义一次。

## 快速入口

- 操作流程：[USAGE.md](USAGE.md)
- 框架文件说明：[collab-framework/README.md](collab-framework/README.md)
- 协调者规则：[collab-framework/COORDINATOR.md](collab-framework/COORDINATOR.md)
- 路由规则：[collab-framework/ROUTING.md](collab-framework/ROUTING.md)
- 追溯协议：[collab-framework/TRACEABILITY.md](collab-framework/TRACEABILITY.md)

## 项目内最小结构

```text
AGENTS.md
code-agent/
  tasks/       # 不可由 worker 改写的任务合同
  attempts/    # worker 每次执行的事实记录
  reviews/     # Terra High 每轮独立审查记录
  decisions/   # 需要架构裁决时才创建
  knowledge/   # 稳定技术知识，不存流水账
```

初始化方法见 `USAGE.md`。本仓库只提供框架和模板，不保存具体项目的运行记录。
