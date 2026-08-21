---
name: task-acceptance-replay
description: Use when an executor returns a task and you are about to mark it passed — establishes ground truth by re-running verification yourself instead of trusting the completion report, and selects which checks the change actually requires.
---

# 任务验收复跑

**状态**：stub
**消费者**：架构师（CC）
**来源**：dsh `dsh-pre-push-checks` + 本框架八起真实验收事故
**触发条件**：执行端返回任务、准备把任务标成通过
**核心判断**：这条绿色结果，证明的是不是我声称的那件事？

## 范围合并说明

本 skill **吸收了原候选 `relevant-check-selection`**（对应 dsh 的 `dsh-pre-push-checks`）。

理由是拓扑不同：dsh 的落地终点是 GitHub PR + CI，选检查项是**执行端 push 前**的事；本框架的执行端不 push，**架构师才是门禁**。选哪些检查和亲自复跑核结果是同一件事的两半，拆开会让"选了但没跑"落进缝里。

## 待补内容

正文未写。补写前先列诱人错误，再写判据。已知必须覆盖的：

- **跨仓库定位**（dsh 的 skill 没有这一面）：先确认 cwd 与目标仓库、确认该仓的写入策略（自有仓可写 / 上游 clone 不可污染），再核对每条命令是在哪个仓下跑的
- 先看工作树与删除项（`D` 状态 = 回归高频根因），再跑
- 核退出码与**处理单元数**：0 单元的绿色结果无效
- 校验必须作用于**声称的真实对象与交付入口**；手搓产物、Mock、缩小样例、旁路入口不算
- 完成区与自审只作线索，不作证据

见 `../README.md §补写一个 skill`。
