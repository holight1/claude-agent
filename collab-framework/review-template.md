# [TASK-ID] / [REVIEW-ID]

## Identity

- review_kind: contract | implementation
- reviewer_tier: terra-high
- actual_model:
- agent_id:
- reviewed_at:
- independent_from_worker: yes | no

## Review target

- task_file:
- target_revision:
- attempts:
- repository/worktree:
- preexisting_dirty_considered:

## Ground-truth verification

| Command | Exit | Key result / artifact |
|---|---:|---|
| `[exact command]` | 0 | [独立复跑结果] |

## Findings

### Blocking

- [位置、现象、影响、复现证据]

### Non-blocking

- [建议；无则 none]

## Anti-gaming checks

- [ ] 测试真实命中任务对象
- [ ] 无 native/mock/CPU fallback 偷换
- [ ] 无断言/阈值降级或错误 skip
- [ ] 新增测试能在实现错误时失败
- [ ] diff 未混入其他任务或用户 dirty

## Verdict

- verdict: approved | changes_requested | blocked
- rationale:
- required_next_action:

> 本结论只对 `target_revision` 有效。Reviewer 不修改实现。
