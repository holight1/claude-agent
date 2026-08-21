# 执行端可做本地 commit，不可 push

**状态**：现行
**日期**：2026-08-21
**触发**：`DS-common.md` 写「不做 git commit」，而用户知识图谱 `ai-dev-workflow/01` 有模式「实现 AI 本地 commit 作为 Review 边界」。两者直接冲突，每轮验收都要手工分辨哪些改动属于本任务。
**作用面**：`collab-framework/DS-common.md`、`collab-framework/review-task.md`；各项目 `DS.md` 的适配层。

## 决定

执行端**可以**为单个任务在本地 commit，但：

- **不 push**，任何情况下
- 不做合并、rebase、reset
- 不在 message 或完成区写 review 结论（「独立审查通过」「架构师已确认」不属于它）
- **一个任务、一个仓、一个 commit**，完成区注明短 SHA

### 跨仓形态：一个任务两个 commit

有的项目的**源码与协作产物不在同一个 git 仓**。已知实例：`~/agent/practice-agent` 的源码在它自己的仓，而 `code-agent/` 是指向 `~/agent/agent-assets` 的符号链接——**同一个 commit 不可能同时包含代码与完成区**。

这种情况下：

- 每个仓各一个 commit，两条 message 首行都带同一个任务号
- **代码仓先提，产出仓后提**，产出仓的 message 里写上代码仓的短 SHA
- 完成区同时注明两个短 SHA
- 两个 commit 是一笔事务：只提了一个就是**部分完成**，不得标已完成

架构师验收时按任务号在两个仓各查一次，箱外残留按两个仓分别核。

**commit 不等于通过。** 它只是把改动装箱，结论以架构师复跑为准。

项目可覆盖，覆盖必须在该项目 `DS.md` 里写明理由。已有的覆盖：`deepseek-harness`（上游 clone，`master` 必须与上游一致，产出全在仓外 `code-agent/`，禁止 commit）。

## 为什么

commit 是 **review 的边界**。没有它，架构师在工作树里看到的是一堆混在一起的改动，分不清哪些属于本任务——而「一个任务的产出必须能被单独指认」是单独复跑和单独打回的前提。

仍然不 push，是因为 push 是对外副作用，需要用户明确授权。

## 备选方案

- **维持「一律不 commit」**。放弃：验收成本实测存在——`practice-agent` 曾同时有 6 处未提交改动分属不同任务，每轮都要手工分辨归属。
- **执行端可 commit 也可 push 到自己的分支**。放弃：push 是对外副作用；且本框架没有 PR 与 CI，push 之后没有任何门禁接住它。
- **由架构师在验收时替执行端补 commit**。放弃：装箱人和验收人是同一个，就没有边界可言了——架构师会按自己理解的范围装箱，而不是按执行端实际做了什么。

## 验收证据

`review-task.md §5` 分成两路：执行端已 commit 时先核对箱内清单与完成区是否一致、箱外有无残留，不一致直接打回而不是替它补 commit。`~/agent/agent-assets/practice-agent/DS.md`（允许，跨仓两提交）与 `~/agent/agent-assets/deepseek-harness/DS.md`（禁止，上游 clone）各自给出了不同的项目级策略，**这一条证明的是覆盖机制可用**，不是单提交规则可行——单提交规则在 practice-agent 上本就不成立，已改为跨仓两提交。
