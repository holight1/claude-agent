# [PROJECT] — Codex 协作入口

## 阅读顺序

1. 本文件的项目约束
2. 当前任务 `code-agent/tasks/<TASK-ID>-*.md`
3. 任务明确引用的知识和设计文件
4. 按角色读取 `~/claude-agent/collab-framework/` 中对应规则

## 角色规则

- Coordinator：读 `COORDINATOR.md`、`ROUTING.md`、`TRACEABILITY.md`
- Worker：读 `ROUTING.md`、`TRACEABILITY.md`，只写被分配的 attempt 和允许范围
- Reviewer：读 `TRACEABILITY.md` 和 `review-template.md`，只写新 review 文件

## 项目上下文

- 仓库：`[ABSOLUTE_PATH]`
- 任务编号：`[PREFIX]-NNNx`
- 构建入口：`[COMMAND]`
- 测试入口：`[COMMAND]`

## 项目硬约束

- [ABI / runtime / generated files / hardware environment constraints]
- 保留用户已有 dirty/untracked，不得擅自清理。
- 不 push；push 需用户明确授权。

## 状态源

- 当前任务：`code-agent/tasks/`
- 执行证据：`code-agent/attempts/`
- 独立审查：`code-agent/reviews/`
- 架构裁决：`code-agent/decisions/`
- 稳定知识：`code-agent/knowledge/`
