# 使用指南

## 1. 初始化项目

将模板复制到目标仓库，并替换占位符：

```bash
cp ~/claude-agent/collab-framework/AGENTS-template.md /path/to/project/AGENTS.md
mkdir -p /path/to/project/code-agent/{tasks,attempts,reviews,decisions,knowledge}
cp ~/claude-agent/collab-framework/code-agent/README.md /path/to/project/code-agent/README.md
```

项目已有 `AGENTS.md` 时不要覆盖，把模板中的“Subagent 协作”章节合并进去。

## 2. 标准闭环

```text
需求
  → Coordinator 写任务合同并选择 worker tier
  → Worker 在隔离工作区实现并写 attempt
  → Terra High 基于固定 revision 独立 review 并写 review
  → 有问题：新 attempt 修正，再 review
  → Coordinator 做最终门控、更新任务状态并 commit
```

任务合同创建后，验收条件原则上冻结。确需改变目标或验收时，由 Coordinator 先记录变更原因和新版本，再继续执行；worker/reviewer 不得自行降低门槛。

## 3. 创建任务

复制 `collab-framework/task-template.md` 到：

```text
code-agent/tasks/<TASK-ID>-<slug>.md
```

Coordinator 填写目标、非目标、允许修改范围、验收条件、风险标签和建议 worker。任务文件不写实现伪码，也不重复通用防造假规则。

状态由 Coordinator 单独维护：

```text
draft → ready → running → review → verified → committed
                     ↘ changes_requested ↗
                     ↘ blocked / cancelled
```

## 4. 选择 worker

按 `collab-framework/ROUTING.md` 分类：

- Luna Med：机械、局部、现有范式清楚、验收确定、失败影响有限。
- Terra Med：编译器/运行时/并发/ABI/数值语义、跨模块调试、根因未知、测试设计困难。
- Terra High：只承担独立 review；不得是同一任务的实现者。

若 Luna Med 执行中发现复杂风险，应停止扩大修改，在 attempt 中记录证据，由 Coordinator 升级为 Terra Med。不要靠反复重试掩盖错误路由。

## 5. 隔离工作区

代码任务默认使用独立 branch/worktree，尤其是并行任务：

```text
branch: agent/<task-id>/<attempt-id>
worktree: <coordinator-selected-absolute-path>
```

Coordinator 在派发前记录 base revision、已有 dirty/untracked 路径和允许修改范围。共享工作区只允许用于单任务、无并行写入的情形，并必须保留派发前快照。

## 6. Worker 返回

每次执行创建一个新记录：

```text
code-agent/attempts/<TASK-ID>/<ATTEMPT-ID>.md
```

使用 `attempt-template.md`。记录实际模型、agent/session 标识、base/result revision、修改文件、命令与退出码、关键输出、未解决问题。禁止覆盖旧 attempt。

worker 可以创建候选 commit，但不能写“review 通过”、不能修改 review 文件、不能把未通过的验收记为完成。

## 7. Terra High review

Coordinator 固定待审 revision 后，派发独立 Reviewer。Reviewer 使用 `review-template.md` 写入：

```text
code-agent/reviews/<TASK-ID>/<REVIEW-ID>.md
```

Reviewer 必须检查 diff、任务合同、attempt 证据，并亲自复跑关键验收。新增测试要验证“测试有牙齿”，阻塞结论优先要求可执行证据。

review 结论只有：

- `approved`
- `changes_requested`
- `blocked`

Reviewer 不修改实现。小修也应形成新的 coordinator-fix 或 worker attempt，然后对新 revision 复审，确保修正链可见。

涉及公共 ABI、跨仓库契约、不可逆数据布局或高成本仿真时，可在 Worker 开始前增加一次 `contract` review，先检查任务合同和验收是否足以约束实现。它不替代实现完成后的 `implementation` review。

## 8. 最终提交

只有 Coordinator 可以把任务更新为 `verified`/`committed`。提交前确认：

- review 的 target revision 与当前结果一致；
- mandatory 验收均有 ground-truth；
- 未混入派发前 dirty 或其他任务文件；
- task timeline 已链接全部 attempt/review/decision；
- commit message 含 TASK-ID。

不自动 push。push 仍由用户明确授权。

## 9. 并行原则

- 可并行：修改范围不重叠、验收环境不争用、没有未决架构依赖。
- 不可并行：同一 ABI、同一生成文件、同一硬件仿真资源或前序结论尚未确定。
- Reviewer 可以与其他任务的 Worker 并行，但不能在待审 worktree 中写入。
- 多个互不依赖的 Luna Med 任务可以在同一个 Terra High 会话中批量 review；每个任务仍须有独立 review 文件、target revision 和 verdict。

## 10. 最小派发文本

Worker：

```text
执行 <task-file>。角色：<Luna Med|Terra Med> worker。
工作区：<absolute-path>；attempt：<attempt-file>。
先读项目 AGENTS.md 和任务合同。只改允许范围，完成后写 attempt，不写 review 结论。
```

Reviewer：

```text
Review <task-file>，目标 revision：<sha>。角色：Terra High reviewer。
只读实现，独立复跑关键验收，结果写入 <review-file>；不要修改实现或旧记录。
```
