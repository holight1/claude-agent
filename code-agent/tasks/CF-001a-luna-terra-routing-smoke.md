# CF-001a — Luna Medium → Terra High routing smoke

**状态**：ready
**优先级**：P0
**风险标签**：local / process-smoke
**建议 Worker**：Luna Med
**Coordinator**：Codex root

## 背景与目标

验证 Codex 分模型协作的最小完整链路：Coordinator 固定任务合同，Luna Medium worker 生成确定性 artifact 和 attempt，Terra High reviewer 对固定 revision 独立验收并生成 review，最后由 Coordinator 裁决。

## 非目标

- 不修改 UPU 业务仓库；
- 不验证复杂实现质量；
- 不测试并行写入或 App Server；
- 不 push。

## 技术合同

生成 `code-agent/artifacts/CF-001a-routing-smoke.json`，内容必须是有效 JSON，并精确表达：

- `task_id` 为 `CF-001a`；
- `worker_tier` 为 `luna-med`；
- `route` 为 `gpt-5.6-luna/medium`；
- `values` 为前四个质数 `[2, 3, 5, 7]`；
- `checksum` 等于 `values` 之和，即 `17`。

Worker 同时创建 `code-agent/attempts/CF-001a/A01.md`，按 attempt 模板记录实际模型、agent/thread id、base/result revision、修改文件、命令和退出码。实现者不得创建 review 文件或宣布 review 通过。

## 修改边界

**允许**：

- `code-agent/artifacts/CF-001a-routing-smoke.json`
- `code-agent/attempts/CF-001a/A01.md`

**禁止**：

- 除上述两项外的全部文件；
- 修改本任务合同；
- commit、push、spawn subagent。

## 验收

### 必须通过

```bash
jq -e '
  keys == ["checksum", "route", "task_id", "values", "worker_tier"] and
  .task_id == "CF-001a" and
  .worker_tier == "luna-med" and
  .route == "gpt-5.6-luna/medium" and
  .values == [2, 3, 5, 7] and
  .checksum == (.values | add) and
  .checksum == 17
' code-agent/artifacts/CF-001a-routing-smoke.json
```

```bash
test -s code-agent/attempts/CF-001a/A01.md
```

### 回归

```bash
git diff --check
```

## 派发快照

- task_revision: bound in A01
- base_revision: bound in A01
- branch/worktree: current repository root, branch `codex/subagent-traceable-framework`
- preexisting_dirty: none at initial task creation

## Timeline

- 2026-07-11T16:20+08:00 created by Coordinator
