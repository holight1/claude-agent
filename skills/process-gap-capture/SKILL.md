---
name: process-gap-capture
description: Use whenever a task exposes a defect in the collaboration process itself — a checklist that lacked a category, a task contract that under-specified, a review that missed a class of failure, a skill that would have caught it. Records the gap as a numbered note under the project's process-notes directory so the framework can be updated later, instead of losing it in a task file.
---

# 流程缺口捕获

**状态**：enabled
**消费者**：架构师（各项目会话）
**来源**：sim 工作区 2026-08-21 的实践，见 `~/sim/code-agent/process-notes/0001-no-channel-for-process-gaps.md`
**核心判断**：这次的问题**只是这次做错了**，还是**流程允许它发生**？

## 何时触发

**每个任务的终审都问一遍**，不等用户提醒：

- 验收点被精确满足了字面，但意图落空 → **合同缺陷**
- 独立 reviewer 漏掉一整类问题 → **检查清单缺项**
- 自己写的任务书 / 文档里发现不一致或残缺 → **架构师侧纪律缺口**
- 某个已存在但未启用 / 未补正文的 skill 本可以拦住它 → **skill 缺口**
- 修复一个缺陷后，**同类缺陷换了个位置又出现** → **最高优先级**，说明修的是症状不是机制

**不触发**：单纯的实现 bug、笔误、一次性判断失误——写在任务终审区就够了。

**判据**：**同一个人下次做同一件事，会不会再犯？** 会 ⇒ 是流程缺口。

## 记录去哪、长什么样

位置：`code-agent/process-notes/NNNN-<短横线短语>.md`（四位序号，**只追加，不改写既有记录**；同一缺口有新证据就追加到该记录末尾）。

| 字段 | 要求 |
|---|---|
| **触发事件** | 哪个任务、哪一条发现。**给可核对的锚点**（文件 + 测试名 / 终审小节号） |
| **缺口是什么** | 一句话说清**流程允许它发生的那个机制**，不是复述缺陷本身 |
| **本可以拦住它的是什么** | 具体到 skill 名 / 清单条目 / 纪律条款；没有对应物就写「当前无」 |
| **建议改动** | 落到**哪个文件的哪一节**，写清加什么。**不写抽象原则** |
| **是否已在本仓临时落地** | 项目文件可先改以止血，但必须写明「本仓已临时落地，框架未同步」 |

## 硬规矩

🔴 **不直接修改 `~/claude-agent`。** 项目会话只负责把缺口记录成**可采纳的建议**；框架改动权在用户。

项目的 `CODEX.md` / `CLAUDE.md` / `DS.md` 可以先改以止血，但记录里必须写明「本仓已临时落地，框架未同步」——否则两边会漂，而漂移不会被任何门禁发现。

🔴 **一条记录只写一个缺口。** 合并会让采纳时无法逐条取舍。

🔴 **建议必须能指回证据。** 写不出「哪个任务的哪一条发现」就不是缺口，是想法——不要记。

## 完整闭环

```
项目踩坑
  → code-agent/process-notes/NNNN-*.md      项目会话记录，不改框架
  → 用户采纳
  → ~/claude-agent 改动 + decisions/ 记录    承接会话执行，记录引用那条 process-note
  → 回流判定：通用 → DS-common / CODEX-template
```

两端各有一条硬规矩把住：项目侧**不直接改框架**，框架侧**改动必须有 decisions/ 记录且不复制项目内容、只引用**。中间任何一段断了，下一个人就只看得到规则、看不到规则为什么长这样。

## 与终审的关系

终审区写**这次的判决**；process-note 写**下次怎么不再发生**。同一件事两处都出现是正常的，措辞不同：

- 终审：「F1 转下一任务，扫描集补 derive 结果」
- note：「防造假机制自身的数据来源覆盖面无人审——修复后洞从『清单写不全』移到『生成器输入覆盖不全』，同类失败换位置复发」

## 停止条件

- 写不出「本可以拦住它的是什么」→ 先想清楚，别记半条
- 建议是「以后要更仔细」→ 不是可采纳的改动，重写或丢弃
- 该缺口已有记录 → **追加到既有记录**，不新开一条
