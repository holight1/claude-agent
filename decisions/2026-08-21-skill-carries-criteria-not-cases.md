# skill 承载判据，不承载案例 —— 与 dsh 的差异及原因

**状态**：现行
**日期**：2026-08-21
**触发**：用户指出「skill 是不是太具体了，我看有好多具体数据」，并追问「包括那个整理流程的 skill，也应该排除具体问题、只归纳流程级别的问题？」，随后要求**先看 dsh 怎么做**再定。
**证据**：`~/agent/deepseek-harness/.agents/skills/dsh-code-review/SKILL.md`（49 行）、`dsh-pre-push-checks/SKILL.md`（123 行）、`dsh-prose-standard/SKILL.md`（81 行）；`~/agent/deepseek-harness/.agents/notes/implemented/process/2026-06-11-quality-gates.md`（Agent Note 的 `## Problem` / `## Decision` / `## Consequences` 结构与顶部取代链接）。**本仓不复制其内容，以那些文件为准。**
**作用面**：`skills/*/SKILL.md` 全部 8 个 enabled skill（剥离案例数据 + 新增 `## 判据来源` + 野心上限声明）；`scripts/sync-skills.sh`（新增案例数据判别式与 `## 判据来源` 强制）；经生成块投影到 `collab-framework/DS-common.md`。

## 决定

**一 · SKILL.md 正文只放判据与形态，不放案例。**

| 层 | 内容 | 放哪 |
|---|---|---|
| **判据** | 「把被约束量改成永远不接近界的值，这条断言会不会红？」 | SKILL.md，抽象、无领域词 |
| **形态** | 「上界断言 + 量永远远离界 ⇒ 空转」「阈值与构造参数不同源 ⇒ 界一变红在错处」 | SKILL.md ——「点名具体手法」要的是**这一层** |
| **实证** | 实测数字、领域名词、某仓对象名、事故叙事 | `decisions/` 的「为什么」节 + `evals/EVALS.md` 的场景列 |

**二 · 每个 enabled skill 必须有 `## 判据来源`**，列出对应的 `decisions/` 记录。规则要辩论时去那里辩，不在 skill 里堆证据。（照抄 dsh 的 `## Sources of truth`。）

**三 · 每个 skill 声明野心上限**：「本 skill 是判据，不是完整清单。」（照抄 dsh 的 "This skill is guidance, not a complete checklist."）

**四 · 门禁判别式**（`sync-skills.sh`，不是词黑名单）：

- 科学计数法出现在 SKILL.md ⇒ 红。它几乎只作为实测值出现，而判据的参数都是小整数
- 四位及以上裸数字**且该行无出处** ⇒ 红。引用编号（process-note 序号、记录文件名）不是实测值，所以判据落在「有没有出处」上，不落在数值大小上
- `## 跨角色必读` 内**零容忍**（即便带出处）——该节投影进每个项目执行端**每轮必读**的文件
- enabled skill 缺 `## 判据来源`，或该节无任何 `decisions/` 引用 ⇒ 红

## 为什么

### 与 dsh 的差异：不是抽象程度不同，是载体层级不同

**dsh 的 skill 一点都不抽象。** 三个 skill 里满是具体：本仓命令（`pnpm --silent run change-scope --base <verified-base-ref>`）、本仓配置事实（`packages/*/*/src` per-file 100% 覆盖率、`vitest` 不做 typecheck）、外部系统行为事实（PR 处于 `CONFLICTING` 时 GitHub 不创建 workflow run，`total_count` 恒 0）、点名的偷懒手法（不得用 `--passWithNoTests` / 降阈值 / 缩 `--coverage.include` 去藏没覆盖的文件）。

**但事故叙事三个 skill 加起来 0 处。** 没有一句「我们曾经测到 X 是错的」。

决定性的差别是**载体层级**：

| | dsh | 本框架 |
|---|---|---|
| skill 位置 | `.agents/skills/`，**项目级**，仓内 | `~/claude-agent/skills/` → `enabled/` → 用户级客户端目录 |
| 加载范围 | **只在该仓** | **每个仓每次会话** |
| 「合法的具体」 | 该仓的命令、路径、门禁阈值、工具行为 | **框架自身**的脚本名、目录、闭集、角色、`--check/--handoff` 三档 |
| 某个受管项目的实测值 | 不存在这个问题 | **禁止**——别的仓永久付出上下文成本 |

⇒ 我把「项目级 skill 可以写项目事实」错抄成了「用户级 skill 可以写**某个**项目的实测值」。这条错误还命中了本框架自己列的诱人错误「**跨仓错位**」。

### 「为什么」在 dsh 放哪：Agent Notes = 我的 `decisions/`

`2026-06-11-quality-gates.md` 的结构是 `## Problem` / `## Decision` / `## Consequences`，顶部带取代链接（`The hook/CI symmetry in this record is superseded by …`）。事故证据在 `## Problem`：「Early evidence: tests that didn't typecheck shipped (vitest doesn't typecheck) and were only caught by a review.」而 `dsh-code-review` 只在 `## Sources of truth` 里链到这条 note，正文一个字都不重复它。

**本仓的结构本来就是对的**（`decisions/` + `已取代` 闭集 + 引用不复制），我只是没用它——把 `## Problem` 的内容抄进了 skill 正文。

### 这次搬家是无损的：SKILL.md 那份本来就是冗余副本

搬家前逐个核对每个实测值是否另有出处：

| 实测值 | `decisions/` | `evals/` |
|---|---|---|
| 界与峰值、比值、口径差 | ✅ | ✅ |
| 整改声称撤下但未撤 | ✅ | ✅ |
| 计数口径（目录篇数 vs 单语言篇数） | 部分 | ✅ |
| 口述人数 vs 实测贡献者数 | ✗ | ✅ |
| 门禁在还原过的树上空转 | ✗ | ✅ |
| 提取器格式假设不符、报满分 | ✗ | ✅ |

**每一条在 `evals/` 里都已有家。** 所以 SKILL.md 里那份是第二个可编辑源 —— 正是本仓已采纳的「止血副本会漂」那个病。三轮里犯第二次：上一次是同一段判据散在 3–5 处（靠生成块修掉），这次是实证。

`evals/` 是正确的去处还有一个独立理由：**eval 就该具体**——没有具体数据的 eval 恰好是外部 review 刚抓到的那种空数据行；而 `evals/` **不在 context 加载路径上**，写多少都不花每轮的钱。

### 为什么不是「把规则写抽象些」

框架原有的信条是「**点名具体手法，不写抽象原则**」，它有实测依据：抽象版失败过——`task-contract-design` 早就有「盯住复发」，项目侧**确实盯住了**，然后仍然只能再补一格。所以答案不是回到抽象，而是**分清「形态」与「案例」**：形态可执行且与领域无关（dsh 那句 "Probe tiny and exact limits, oversized single chunks, and multibyte text for byte limits" 就是形态），案例只是它的一次出现。

规则弱的修法是**更锐的检查，不是附一段轶事**。

## 备选方案

- **保留案例，只把 `## 跨角色必读` 清干净。** 放弃：投影块只是成本最高的那一处，不是唯一一处。整个 SKILL.md 都是用户级、每仓加载；而且两套标准会让下一次「这条算不算案例」变成逐条裁量，判别式立刻退化成人工清单。
- **把案例移进 skill 目录下的 `CASES.md`，不进 `decisions/`。** 放弃：那会造出第三个地方，而 `decisions/` 已经承载「为什么 + 备选 + 取代链」并已被 `check-decisions.sh` 守护。多一个未被门禁覆盖的目录 = 多一个会漂的源。
- **用领域名词黑名单做门禁**（`credit`、`saturation`、`dt_ps`…）。放弃：那是手工维护的清单，下一个项目引入的名词一律漏过——本仓刚用两轮把同类问题从「手工清单」改成判别式，不能在这里反向走。改为按**形态**判定（科学计数法 / 无出处的大数值），对任意新项目都成立。
- **门禁只警告不失败。** 放弃：本仓已有实证「只往 stderr 打一行 = 没人会发现」。
- **给门禁留一个显式豁免标记**（如 `<!-- allow-case -->`）。**暂不做**：豁免标记会成为第一选择，判别式随即失效。若将来出现真正需要大数值的框架级事实，那本身是重新评估这条判别式的信号，不是加豁免的理由。

## 验收证据

搬家后：**24 处实测数字 + 18 处领域名词 → 0 处**（`grep -E '实证|credit|saturation|dt_ps|台账|[0-9]e[+-]?[0-9]|\b8192\b'` 在 8 个 enabled skill 的 SKILL.md 上无命中）；`DS-common.md` 生成块里的 6 处泄漏（`dt_ps`、`1e-8`、`1e12`、`saturation`、`8192`）随重新渲染消失。

`sync-skills.sh --check`：19 个规范源 / 8 个启用 / **0 处错误**。

门禁负测试（隔离副本，均已还原）：

| 输入 | 期望 | 实测 |
|---|---|---|
| 正文加一处科学计数法 | 红 | ✅ `[FAIL] … 出现科学计数法` |
| 正文加无出处的四位数 | 红 | ✅ `[FAIL] … 四位以上数字且该行无出处` |
| 同一个四位数但同行带 `decisions/` 出处 | **放过** | ✅ FAIL 数 0 |
| `跨角色必读` 内带出处的四位数 | 仍红（零容忍） | ✅ `[FAIL] §跨角色必读 出现实测值形态的数字` |
| 把 `## 判据来源` 改名 | 红 | ✅ 两条 FAIL（缺节 + 无 `decisions/` 引用） |

**未验证**：判据从正文搬走后，规则的说服力是否下降到影响执行。dsh 能做到这么短，部分靠它有一整套 notes 语料被 skill 顶部链着；本仓 `decisions/` 只有 16 条，密度还不到那个水平 ⇒ 短期内「规则为什么长这样」更依赖点开链接。观察点是下一轮执行端/reviewer 是否仍按这些判据行动。
