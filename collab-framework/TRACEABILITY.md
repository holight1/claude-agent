# 追溯协议

## 三类事实源

| 文件 | 所有者 | 内容 | 是否可覆盖 |
|---|---|---|---|
| task | Coordinator | 目标、约束、验收、当前状态、事件索引 | 仅 Coordinator 更新 |
| attempt | 对应 Worker/Coordinator | 一次实现或修正的事实和证据 | 不可覆盖；修正建新 attempt |
| review | Terra High Reviewer | 对固定 revision 的独立结论 | 不可覆盖；复审建新 review |

架构选择单独写 decision。知识库只保存稳定结论，不作为某次任务完成的证据。

## 标识规则

```text
TASK-ID: 项目既有编号，例如 TR-049j
ATTEMPT-ID: A01, A02, ...
REVIEW-ID: R01, R02, ...
DECISION-ID: D01, D02, ...（在任务范围内）
```

目录：

```text
code-agent/tasks/<TASK-ID>-<slug>.md
code-agent/attempts/<TASK-ID>/<ATTEMPT-ID>.md
code-agent/reviews/<TASK-ID>/<REVIEW-ID>.md
code-agent/decisions/<TASK-ID>/<DECISION-ID>.md
```

## Revision 绑定

每个 attempt 必须记录 `base_revision` 和 `result_revision`。未创建 commit 时，使用 base SHA 加完整 `git diff --binary` 的哈希或由 Coordinator 创建候选 commit；代码 review 优先使用候选 commit，避免工作树漂移。

每个 review 只对一个 `target_revision` 有效。review 后任何实现文件变化都必须生成新 revision 和新 review。

## 环境与证据

至少记录：仓库绝对路径、branch/worktree、实际模型、agent id、时间、相关环境变量、命令、退出码和关键输出摘要。大段原始日志可以保存在项目约定的 artifact 路径，并在 md 中记录相对路径和 SHA-256。

以下不算通过证据：

- 只有自然语言“已通过”；
- 使用 `|| true`、忽略退出码或只截取成功片段；
- mock/native/CPU fallback 替代任务指定路径；
- skip/xpass 冒充 pass；
- 修改阈值、删除断言或缩小输入后得到的绿灯。

## Timeline

task 的 timeline 是索引，不复制全部内容：

```text
2026-07-11T10:00+08:00 dispatch A01 → Luna Med @ base abc123
2026-07-11T10:20+08:00 result A01 → candidate def456
2026-07-11T10:25+08:00 review R01 → changes_requested
2026-07-11T10:40+08:00 dispatch A02 → Terra Med @ def456
2026-07-11T11:20+08:00 review R02 → approved target fed987
2026-07-11T11:30+08:00 committed → 012abc
```

每条事件链接对应文件。不得删除失败 attempt 或被否决 review，它们是决策链的一部分。

## Dirty 工作区

派发前的 tracked dirty/untracked 属于用户或其他任务。Coordinator 将快照写入 task 或 attempt；worker 不能清理、覆盖或顺带提交。发现范围重叠时停止并报告。

## 可恢复性检查

新会话仅凭仓库文件应能确定：

1. 当前任务状态和下一动作；
2. 最近一次实现 revision；
3. 最近 review 结论及其 target revision；
4. 未解决问题及证据位置；
5. 哪些文件属于用户原有 dirty。
