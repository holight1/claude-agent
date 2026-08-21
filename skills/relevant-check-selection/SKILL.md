---
name: relevant-check-selection
description: Dropped candidate — merged into task-acceptance-replay. Kept as a record so the same candidate is not re-proposed.
---

# 相关检查项选择（已并入）

**状态**：dropped
**去向**：并入 `task-acceptance-replay`
**来源**：dsh `dsh-pre-push-checks`

## 为什么不单列

拓扑不同。dsh 的落地终点是 GitHub PR + CI 门禁，"根据 outgoing diff 选最窄而充分的检查"是**执行端 push 前**的动作。

本框架的执行端**不 push**——它的终点是本地 commit，架构师才是门禁。选哪些检查、和亲自复跑核结果，在这里是同一个人同一时刻的两半；拆成两个 skill 会让「选了但没跑」「跑了但没选全」落进缝里。

## 什么情况下应该重新拆出来

若将来执行端获得直接向远端落地的权限（有了真正的 push 前时刻），本条应重新独立。届时需要重新回答的是：**谁在什么时刻选检查项**，而不是「要不要有这个 skill」。
