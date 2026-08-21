---
name: stacked-change-landing
description: Dropped candidate — the framework has no dependent-PR stack. Kept as a record of why, and of the one transferable principle.
---

# 依赖栈落地（不吸收）

**状态**：dropped
**来源**：dsh `dsh-merging-stacked-prs`

## 为什么不吸收

场景不存在。dsh 的落地终点是 GitHub 上一串相互依赖的 PR，需要按依赖顺序合并、处理 retarget 与重写。

本框架的落地终点是**执行端本地 commit → 架构师复跑 → 架构师 commit**，没有远端栈，也没有多分支依赖关系。把它吸收进来会引入一整套无对象的概念。

## 唯一可迁移的原则（已并入别处）

> 官方机制不可用时**硬停**，不手工模拟其语义。

这条已经作为通用纪律记在 `~/knowledge-graph/ai-dev-workflow/15-discipline-to-executable.md`，不需要 skill 载体。

## 什么情况下应该重新提

项目实际开始使用依赖 PR / 分支栈，且宿主提供了官方栈机制。**缺少官方机制时不要用手工流程替代**——那正是本条要防的错。
