# 采纳 sim 的四条流程缺口记录

**状态**：现行
**日期**：2026-08-21
**触发**：sim 会话按用户指示建立 `code-agent/process-notes/`，把流程级缺陷从任务终审区分离出来，产出四条可采纳的建议。
**证据**：`~/sim/code-agent/process-notes/` 的 `README.md` 与 `0001`–`0004`。每条含触发事件、缺口机制、本可以拦住它的是什么、建议改到哪个文件的哪一节、以及本仓是否已临时落地。**本仓不复制其内容，以那四份文件为准。**
**作用面**：新增 `skills/process-gap-capture/`、`collab-framework/code-agent/process-notes/`；`collab-framework/DS-common.md`；`skills/task-contract-design/SKILL.md`、`skills/task-acceptance-replay/SKILL.md`、`skills/semantic-code-review/SKILL.md`。

## 决定

四条全部采纳，无保留意见。

| note | 采纳为 |
|---|---|
| 0001 流程缺口无独立通道 | 新增 skill `process-gap-capture`（enabled）+ `code-agent/` 模板加 `process-notes/` + `DS-common` 加「流程缺口 vs 实现缺陷」一节 |
| 0002 审查清单缺第三类失败 | **本轮之前已采纳**：`DS-common` §6、`REVIEWER-template` 三类失败表、`semantic-code-review` §2 |
| 0003 验收点只写机制不写充分性 | `task-contract-design` §1 加充分性强制项与「最弱实现」判据、作弊路径表加两条；`task-acceptance-replay` 把「互为负测试」升级为终审必做步骤 |
| 0004 防造假机制自身的作用集合无人审 | `semantic-code-review` 新增 §3.1「规则 + 作用集合」，点名 derive 值与「手工列举改自动生成后边界不可见」 |

同时补全闭环：**项目侧记录缺口不改框架 → 用户采纳 → 框架侧改动并写 `decisions/` 记录（引用不复制）→ 判定通用则回流 `DS-common` / `REVIEWER-template`。** 两端各有一条硬规矩把住，中间任何一段断了，下一个人就只看得到规则、看不到规则为什么长这样。

## 为什么

**0003 和 0004 都是对本仓 skill 的直接反驳，而且成立。**

- 0003 打的是 `task-contract-design` §1 的四栏映射：**四栏都能填满，缺口照样存在**。「可观察结果」栏填「扫描集自动生成」是合法填写，但它没被要求回答覆盖到哪。⇒ 机制不等于充分性。
- 0004 打的是 `semantic-code-review` §3 末尾那句盲区提醒：它只覆盖「手工清单」，没覆盖「自动生成的集合」——**而后者更危险，因为看起来更可靠**。

0003 还记下了一个更重要的形态：R1 的修复（手工清单 → 自动生成）**把洞从「清单写不全」移到了「生成器的输入覆盖不全」**。同类失败换位置复发 ⇒ 修的是症状不是机制。这条已写进 `task-contract-design` 作为修复后的必查项。

0001 的价值在于它解释了为什么此前的机制**依赖人的记性**：两次流程分析都是用户明确要求「把分析也记下来」才有的。`task-acceptance-replay` 原本有一句「验收发现的漏洞回头必须能指出任务设计里哪条没写死」——方向对，但**没有落点**，指出来之后没地方放。

## 备选方案

- **只采纳 0002/0003/0004，不采纳 0001 的 `process-notes/` 目录**，理由是流程缺口写进 `decisions/` 即可。放弃：两者层级不同。`process-notes/` 是**项目侧的现场记录**，写的时候还不知道该改框架的哪一处；`decisions/` 是**框架侧的决定**，写的时候已经定了改什么。合并会让项目会话被迫在踩坑当场就做框架决策，而它按规矩不该改框架。
- **把 `process-gap-capture` 设为 dormant**，等更多项目验证后再启用。放弃：它的触发点是「每个任务终审都问一遍」，休眠等于不存在；而 0001 记录的病根恰恰是「靠人记得」。
- **把 sim 那四条的内容抄进本仓 `decisions/`，不依赖 `~/sim` 存在**。放弃：违反「一条事实只有一个可编辑源」。抄过来的副本会随 sim 侧追加新证据而漂，且漂移无人发现。改为精确引用到文件 + 小节。

## 验收证据

`scripts/check-decisions.sh` 的证据链可达性检查会验证本记录引用的 `~/sim/code-agent/process-notes/` 路径存在；仓外引用不可达时报 WARN。

采纳后重跑 `scripts/check-framework.sh`：18 个 skill 规范源 / 6 个启用 / 0 处错误。

**0002 有独立的效果证据**（来自 `0002` 记录末尾）：清单加上第三类检查后，SIM-001b 的独立 reviewer **当轮即主动执行反例证伪三次，抓到 4 条执行端未自查的问题**；审查侧从 SIM-001a 的「三条全漏」到 SIM-001b 的「四条自抓」，只隔了一次清单修订。这是本框架目前**唯一一条带前后对照的制度有效性证据**——此前所有制度都只能证明「如此设计」，不能证明「有效」。
