---
name: bilingual-doc-sync
description: Dropped candidate — no formal bilingual documentation is maintained. Kept as a record of why, and of the enabling precondition.
---

# 双语文档同步（不吸收）

**状态**：dropped
**来源**：dsh `dsh-translate-docs`

## 为什么不吸收

场景不存在。dsh 维护正式的中英双语文档（每篇 note 是 `英文 / .zh.md / sidecar` 三件套），所以需要配对同步的判断程序。

本框架的文档是**单语中文**，面向用户自己和受托 AI，不对外沟通。设计文档那条线已明确「纯 markdown，不做 HTML 分版」。

## 一个已经付过学费的坑

dsh 的双语三件套结构直接导致过本框架的一次计数错误：`.agents/notes/` 下 `1446 篇` 实际是 **723 篇英文 + 中文译文双计**。

**教训不在双语同步，在计数口径**——已并入 `research-evidence-audit` 的必覆盖项。

## 什么情况下应该重新提

项目开始维护正式双语文档。届时可吸收的内核是：只显式调用；已有配对做最小对侧更新，新配对走全文流程；术语表是约束；结构与语义分别核验。
