# 独立 reviewer 可读框架 skill，禁读架构师上下文

**状态**：现行
**日期**：2026-08-21
**触发**：`semantic-code-review` 自述消费者是「读各仓 `REVIEWER.md` 的独立 reviewer」，而模板 §禁止事项当时写着「收到『请先读取 CODEX.md』时，只读 `CODEX.md`，不读其他 MD 文件」（该模板已更名为 `REVIEWER-template.md`，见 `2026-08-21-reviewer-role-not-vendor.md`）。照模板初始化的新项目里，该 skill **按设计不可达**。
**证据**：矛盾由 `~/agent` 会话在对 `~/sim` 的文档级 review 中核出，登记在 `2026-08-21-skill-carrier-and-enablement.md` 的「已知矛盾（未决）」。sim 侧的实际绕法是把 skill 正文抄进 `~/sim/CODEX.md`，于是同一段判据有了两份手工同步的副本。
**作用面**：`collab-framework/REVIEWER-template.md` §禁止事项、`skills/semantic-code-review/SKILL.md` 头部与新增 §4.1。

## 决定

把禁令从「不读其他 MD 文件」**收窄为「不读架构师上下文」**，并显式放行框架启用池里的 skill。

| | 内容 |
|---|---|
| **禁读** | `CLAUDE.md`（任何目录）、`~/.claude/CLAUDE.md`、`~/.claude/RTK.md`、`~/CLAUDE.md` |
| **可读** | `REVIEWER.md`、任务文件、`DS.md`、被审查代码与接口两端、项目设计与规格文件、`~/claude-agent/enabled/*/SKILL.md` |
| **不读** | 与本次审查无关的其他项目文档；范围有疑问写进 review，不自行扩大 |

同时在 `semantic-code-review` 新增 §4.1：**本 skill 由架构师侧编写，清单盖不住它自己不知道的那一类失败**。用它，但清单外的问题照样报并注明「不在清单内」，按 `process-gap-capture` 落 process-note。

## 为什么

原禁令的**目的**是保持独立：`CLAUDE.md` 写的是架构师对本项目、本次改动的**框定与结论**，读了会让 reviewer 带着被审查者的判断去审查。

但它的**措辞**（「不读其他 MD 文件」）比目的宽得多，把角色中立的判断程序一起挡在外面。skill 说的是**怎么审**，不是**审出什么**——它和 `CLAUDE.md` 不是一类东西。

不改的代价已经在发生：sim 把 skill 正文抄进项目 `REVIEWER.md`，两份手工同步的副本从此各自演化。这正是 `documentation-architecture` 列的第一类腐化。

另有一条事实使原措辞失去意义：三个宿主的 skill 加载路径（`~/.claude/skills`、`~/.codex/skills`、opencode 的 `skills.paths`）都已指向同一个启用池，**skill 可能被宿主自动加载**。禁令管得住显式读取，管不住自动加载；措辞与机制不符时，该改的是措辞。

§4.1 处理的是这次顺带暴露的更深一层：**判据的作者也在被审查的那条链上**。`semantic-code-review` 由架构师写，reviewer 若只用它，就继承了架构师的盲区——与「审查不能只依赖任务书」同构，只是高一层。§2 的第三类失败就是在一整类被漏掉之后才补进来的，在那之前清单看起来是完备的。

## 备选方案

- **改 skill，把消费者改成只有架构师终审**，reviewer 侧靠项目 `REVIEWER.md` 承载内容。放弃：等于承认两份副本手工同步，把腐化制度化。
- **维持禁令，建立「`REVIEWER.md` 从 skill 生成」的机制**。当时放弃，理由是复杂度高于收益。⚠️ **这条评估已被 `2026-08-21-skill-consumer-split-and-generated-projection.md` 推翻**：范围缩小到渲染一个标记块而非整个文件，且 `permission=skill` 为 0 的实测使双源成为必然腐化。本记录的其余决定仍然现行。
- **全面放开 reviewer 的阅读范围**。放弃：独立性是这条流水线唯一的外部校验点。`CLAUDE.md` 必须继续禁读——那是被审查者的框定。

## 验收证据

`scripts/check-decisions.sh` 的证据链可达性覆盖本记录引用的全部路径。

**未验证**：放行之后 reviewer 是否**真的**会去读 skill（显式或自动加载）。这与 opencode 端到端加载是同一个未闭合的验证面。已知模板改动生效需要新项目初始化或既有项目手工同步 `REVIEWER.md`——**本仓不改任何项目文件**，sim 侧的 `REVIEWER.md` 仍是旧措辞。
