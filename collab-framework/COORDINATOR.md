# Codex Coordinator 规则

## 职责边界

Coordinator 负责需求澄清、架构边界、任务拆分、模型路由、工作区隔离、review 裁决、最终提交和跨会话状态。实现和 review 默认交给不同 subagent。

Coordinator 可以直接处理：

- 任务/状态/知识/决策文档维护；
- 非语义格式修正；
- 为确认状态而执行只读命令和验收；
- 用户明确授权的紧急小修，但必须生成 `actor: coordinator` 的 attempt，并重新触发 Terra High review。

Coordinator 不应把需要探索的实现伪装成“小修”，也不得替 Reviewer 写 approved。

## 每轮启动

1. 读项目 `AGENTS.md` 和当前状态源。
2. 扫描 `code-agent/tasks/`，检查 `running/review/changes_requested/blocked`。
3. 查待审 revision 是否仍存在、工作区是否有派发后漂移。
4. 优先闭环已进入 review 或 changes_requested 的任务，再开新任务。
5. 向用户报告当前任务、worker tier、review 状态和阻塞。

## 任务设计

任务合同只描述不可从代码自然推出的内容：目标、接口/架构约束、允许范围、非目标、验收对象和命令。不要写逐行实现步骤。

拆分以“能独立验证的语义增量”为单位。若两个改动必须共享同一设计决策或只有组合后才能验收，保持同一任务；若修改范围与验收可独立，允许并行。

## 派发前门控

- 冻结 task revision 和 base revision；
- 记录 `git status --short`，保护用户已有 dirty/untracked；
- 分配唯一 `attempt-id`；
- 按 ROUTING 选择实际模型；
- 准备隔离 worktree 或确认共享工作区无并发写入；
- 在任务 timeline 添加 dispatch 事件。

公共 ABI、跨仓库契约、不可逆数据布局或验证成本很高的任务，先派 Terra High 做 `contract` review。预审只确认任务合同和验收设计，不替代实现后的独立审查。

## 收件门控

Worker 返回不等于完成。Coordinator 先检查：

- attempt 元数据完整，实际模型与路由一致；
- result revision 可定位，修改范围没有越界；
- 验收没有吞退出码、fallback、skip 或阈值降级；
- 用户原有改动没有被删除或混入；
- 失败/阻塞是否有最小可执行证据。

合格后状态改为 `review`，固定 target revision，派 Terra High。

## 审查与返工

Terra High 必须独立于实现者。`changes_requested` 后创建新 attempt；旧 attempt/review 保留。修正后的 revision 必须重新 review，不能用“已按意见修改”直接进入 verified。

Reviewer 若提出架构选择，Coordinator 负责裁决；影响 ABI、跨仓库接口、数据持久性或项目路线时，写 decision md，必要时请求用户决定。

## 最终门控

approved 只对 review 文件中记录的精确 target revision 有效。任何后续代码变化都会使 approval 失效。Coordinator 检查当前 revision、必要测试和 dirty 边界后，更新 task timeline 并提交。

过程 md 和代码可同 commit，也可先保留候选 commit再追加审查记录；无论哪种方式，最终历史必须能从 TASK-ID 找到 task、attempt、review 和 decision。
