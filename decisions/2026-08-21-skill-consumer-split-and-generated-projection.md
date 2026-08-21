# Skill 按消费者二分；共享部分生成投影，不手抄

**状态**：现行
**日期**：2026-08-21
**触发**：opencode 日志实测——`permission=skill` **0 次**，`permission=bash` 12,104 次；`claude-agent/enabled` 在日志中 0 次出现。而 dsh 的**项目级** skill 目录**确实被加载过**（11 条 `duplicate skill name`），加载之后**仍然 0 次调用**。skill 内容唯一一次真正到达执行端，形态是 `permission=bash pattern="grep -n ... .agents/skills/dsh-prose-standard/SKILL.md"`——任务明确要求它读那个文件。
**证据**：`~/.local/share/opencode/log/opencode.log`（本会话独立复核，非采信）；`~/sim/code-agent/process-notes/0008-skill-mechanism-never-reached-executor.md`。**本仓不复制其内容，以该记录为准。**
**作用面**：19 个 `SKILL.md` 的 `**消费者**` / `**投影**` 字段；4 个共享 skill 的 `## 跨角色必读`；`scripts/render-shared.py`（新增）；`scripts/sync-skills.sh` 与 `scripts/check-framework.sh`；`collab-framework/DS-common.md` §5–§8 与 `collab-framework/REVIEWER-template.md`；`README.md`、`USAGE.md`、`skills/README.md`。

## 决定

**一 · 两个闭集字段**，`dropped` 免除：

```
**消费者**：架构师 | 共享
**投影**：无 | <目标文件>（逗号分隔）
```

`共享` 必须有 `## 跨角色必读`（**上限 45 行**），且投影不得为「无」；`架构师` 反之，且不得有该节。

**二 · 共享部分生成，不手抄。** `scripts/render-shared.py` 把该节渲染进目标文件的 `<!-- BEGIN SKILL-BLOCK: name -->` 标记块，标题降一级。块内不可手改；门禁校验块是否最新。

**三 · 归类结果**（8 个 enabled）：

| 共享 → 投影 | 架构师 |
|---|---|
| `semantic-code-review` → REVIEWER-template + DS-common | `task-contract-design` |
| `task-acceptance-replay` → DS-common | `worker-routing-and-delegation` |
| `research-evidence-audit` → DS-common | `process-gap-capture` |
| `gate-design-and-negative-testing` → DS-common | `decision-record-authoring` |

## 为什么

**skill 机制对执行端不成立，且不是配置问题。** 三层里第一层（载体）在 dsh 那次已经满足——项目级目录被自动加载——结果仍是 0 次调用。卡死的是第三层：skill 是**模型主动调用**的工具，而 DeepSeek-V4-Flash 在一万两千次 bash 调用里从没调过。换目录只修第一层。

**对照组是硬的**：`REVIEWER.md` 里新增的第三类检查**当轮即被执行**，产出 4 条执行端未自查的发现。同一份内容也在 `semantic-code-review` skill 里，那条路径从未被走过。⇒ **对执行端，「写进它必读的文件」比「挂成 skill」可靠一个数量级。**

**为什么必须生成而不是手抄**：本仓已经因手抄让同一段判据散在 **3–5 处**，并且开始不一致——`DS-common` 版本多了一句「贴出坏实现变红的实际输出」，另外三处没有。这正是 sim `0005` 记录的「止血副本只管建立不管撤除」在框架内部的复现，而且**是我在采纳 0005 的同一轮制造的**。

**为什么设 45 行上限**：`## 跨角色必读` 进的是执行端**每轮必读**的文件。没有上限，它会长成整个 skill 的副本，把 `DS-common` 撑成没人读完的文档。上限强迫作者回答「哪一部分真的跨角色」。

**为什么 `task-acceptance-replay` 判为共享**：执行端的「自审」与架构师的「复跑」判据高度重叠，而 `DS-common` §5 早就是它的执行端版本——重复的源头正在这里。判为架构师专用等于承认双源。

## 备选方案

- **`DS-common` 只写指针，指向 `~/claude-agent/skills/` 下对应的 SKILL.md**。放弃：单源，但依赖执行端真去读。日志里 DS 读 SKILL.md 只发生过一次，是任务明确要求 `grep` 的；弱模型会不会跟指针没有证据。**若将来有证据表明它可靠，这条应重新评估**——它比生成更简单。
- **保持手抄，靠纪律同步**。放弃：已经失败过一次，且失败发生在最应该警惕的那一轮。
- **改用项目级 skill 目录投影**（sim 0008 的 S1）。放弃：**它自己的证据反驳了它**——dsh 的项目级 skill 被加载过且仍 0 调用。S1 修的是已经满足的那一层。
- **生成整个 `REVIEWER.md`**。放弃：要处理通用检查与项目特有检查的合并，复杂度远高于渲染一个标记块。

## 取代关系

本记录取代 `2026-08-21-reviewer-reads-framework-skills.md` 的**备选方案第 2 条**——那条以「复杂度高于收益」放弃了「从 skill 生成」。两点变了：范围从整个文件缩小到一个标记块（生成器约 60 行）；证据从「未验证」变成「`permission=skill` 为 0」，双源从可选的坏处变成唯一形态下的必然腐化。该记录的**决定本身仍然现行**（禁令收窄、放行启用池），仅此一条备选评估被本记录推翻。

## 验收证据

**生效范围绑定启用池**：只有状态为 `enabled` **且** `enabled/` 里有链接的共享 skill 才渲染。否则休眠的 skill 会通过残留的标记块继续对执行端生效——「移出启用池」就不是真的移出。同时检测**孤儿标记块**（目标文件里有块但没有对应的生效 skill），要求显式删除，不静默清空。

`render-shared.py` 幂等，渲染 5 个块到 2 个目标文件。八条负测试逐条验过：共享 skill 改 dormant 并移出启用池 / 孤儿标记块 / 消费者不在闭集 / 共享但投影为无 / 架构师却带跨角色必读 / 跨角色必读超长（82 行 > 45）/ 源改了没重渲染（块过期）/ 目标文件标记块被删。

去重后每段判据只剩**一个可编辑源**：`含 stable` 的触发清单从 5 处收敛到 1 处可编辑 + 2 处生成；`参数、门限、系数一视同仁` 从 3 处收敛到 1 + 2。

**未验证**：执行端读到生成块之后行为是否改变。唯一可信的验收信号是 sim `0008` 的 S4——在 opencode 日志里复查，但那对生成块不适用（生成块走的是文件不是 skill 机制）。**对应的信号应是：下一轮执行端的完成区里是否出现反例证伪的实际输出。** 现在没有。
