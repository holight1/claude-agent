# [TASK-ID] / [ATTEMPT-ID]

## Identity

- actor_role: worker | coordinator-fix
- planned_tier: luna-med | terra-med
- actual_model:
- agent_id:
- started_at:
- finished_at:

## Input

- task_file:
- task_revision:
- repository:
- branch/worktree:
- base_revision:
- preexisting_dirty:
- routing_reason:

## Result

- outcome: completed | partial | blocked | failed
- result_revision:
- candidate_commit:
- changed_files:
  -

## Implementation summary

[说明实际改了什么及关键技术判断，不宣称 review 通过。]

## Verification evidence

| Command | Exit | Key result / artifact |
|---|---:|---|
| `[exact command]` | 0 | [数量、关键日志；长日志路径 + sha256] |

## Self-check

- [ ] 修改未越过 task 边界
- [ ] 未降低或删除验收
- [ ] 未使用未声明 fallback/skip
- [ ] 未覆盖派发前 dirty/untracked
- [ ] `git diff --check` 或项目等价检查通过

## Findings and unresolved issues

- [无则写 none；阻塞需给可执行证据]
