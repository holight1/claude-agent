# 模型路由

## 基本原则

复杂度由语义风险决定，不由文件数或行数决定。一个两行 ABI 修复可能是 Terra Med；一个数百行自动生成清单可能是 Luna Med。

## Luna Med — 简单 Worker

同时满足大部分条件时使用：

- 行为和正确结果明确，已有相邻实现可参照；
- 修改局部，不改变公共接口、数据布局或控制流语义；
- 测试命令稳定，失败容易定位；
- 不需要选择架构方案；
- 错误影响可被现有测试完整覆盖。

典型任务：机械迁移、明确的单点修复、测试矩阵补齐、结构化文档整理、无语义判断的批量更新。

以下任一信号出现时，不使用 Luna Med：编译器 lowering、runtime 生命周期、并发/异步、ABI/序列化、数值稳定性、安全边界、跨仓库一致性、根因未知、需要设计新测试 oracle。

## Terra Med — 复杂 Worker

满足任一条件时使用：

- 需要跨文件或跨层追踪真实数据流；
- 需要调试并形成根因，而非照已有模式填空；
- 涉及 compiler/runtime/kernel/driver、并发、状态机、内存、ABI 或数值语义；
- 存在多种实现方案，需要在任务约束内做技术判断；
- 新测试必须构造可靠 oracle、负测试或真实硬件/仿真路径；
- 错误可能“测试变绿但目标未实现”。

Terra Med 可以提出架构问题，但不得擅自扩大任务边界。遇到公共 ABI、跨仓库契约或路线选择时，停止并交 Coordinator。

## Terra High — Reviewer

所有代码任务和技术结论任务默认必须由 Terra High review。仅纯状态同步、链接修正、格式整理可由 Coordinator 标记 `review-exempt`，并在 task timeline 写明理由。

Terra High review 分为可选的实现前 `contract` review 和强制的实现后 `implementation` review。多个独立 Luna Med 任务可共用一个 reviewer 会话以降低成本，但必须分别产出 revision-bound verdict。

Reviewer 必须：

- 与本任务 worker 身份隔离；
- 以固定 target revision 审查；
- 检查 diff 和真实执行路径；
- 独立复跑关键验收，关注退出码；
- 对新增测试做 anti-gaming 检查；
- 只写 review 记录，不修改实现。

## 升级和降级

- Luna Med 发现复杂信号：记录当前证据并停止，由 Coordinator 新建 Terra Med attempt。
- Luna Med 首次交付因语义/设计问题被 changes_requested：后续默认升级 Terra Med。
- Terra Med 只因机械问题被退回：仍可由 Terra Med 修正，避免上下文丢失。
- Terra High 不可降级。若实际不可用，任务停在 `review`；不能用较低模型冒充 approved。
- 模型服务不可用时允许 Coordinator 选择替代模型，但必须记录实际模型与偏差，并由用户决定是否接受该审查等级。

## 路由记录

每次 dispatch 至少记录：

```text
planned_tier: luna-med | terra-med | terra-high
actual_model: <provider/model identifier>
agent_id: <runtime identity>
routing_reason: <one sentence>
```
