---
name: doc-site-projection
description: Dropped candidate — no documentation site is generated from repository Markdown. Kept as a record of why, and of the transferable single-source principle.
---

# 文档站投影（不吸收）

**状态**：dropped
**来源**：dsh `dsh-doc-site-sync`

## 为什么不吸收

场景不存在。dsh 从仓库 Markdown 投影生成文档站，需要区分可编辑源与生成树、维护 manifest 白名单、把内容同步与互联网部署分开授权。

本框架没有文档站。最接近的东西是 `/mnt/c/Users/suiyan/work/agent/` 这个**审计路径**——但它是**人读的发布面**，不是生成物，没有构建步骤。

## 可迁移的原则（已在别处）

- **正文只有一个可编辑源**——已进 `documentation-architecture` 的必覆盖项
- 内容同步与对外部署**分开授权**——已是框架常驻规则（不自动 push）

## 什么情况下应该重新提

文档站由仓库 Markdown 投影生成时。注意届时**审计路径与生成物是两件事**，不要把审计路径改造成生成树——它的价值恰恰在于人手写、可追溯。
