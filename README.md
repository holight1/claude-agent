# claude-agent

多 AI 协作框架：架构师 Agent 负责设计和协调，DS 执行编码和调研任务。

架构师可以是 Claude / Codex / DS，任意具备长上下文和工具调用能力的 AI 均可担任。架构师设计接口、拆任务、Review 代码；DS 聚焦单一任务执行。任务文件是双方之间的"合同"——描述架构约束和验收条件，不写实现步骤，由 DS 读现有代码自行推导实现。

---

## 前置条件

- 架构师 Agent（Claude Code / Codex 等，有工具调用和持久 memory 的 AI）
- DeepSeek 访问权限（执行端，本地会话或远端机器均可）

---

## 快速开始

```bash
git clone <this-repo> ~/claude-agent
```

然后把这句话发给架构师 Agent：

> 请阅读 `~/claude-agent/USAGE.md`，按其中的 Setup 指南完成环境初始化，完成后告诉我做了哪些步骤。

架构师会自动完成：部署通用规则文件（`DS-common.md`）、初始化 memory 记录。

---

## 建议工作流：新仓库从调研开始

> **建议**：接手一个新仓库时，第一个任务始终是调研，让 DS 读仓库结构、构建系统、关键模块边界，完成后架构师用调研结果补充 DS.md，再开始具体开发任务。

```
1. 初始 DS.md（仅角色 + 构建命令）
2. 下发调研任务 → DS 读源码，总结仓库布局、关键接口、已知约束
3. 架构师用调研结论补充 DS.md（仓库布局、任务编号规范、知识库初始章节）
4. 后续开发任务 DS 可直接读 DS.md 快速上下文
```

设计阶段也建议（非强制）先落盘设计文档到 `code-agent/designs/<name>.md`，再从设计创建任务文件。好处是多个 DS 会话可以共享同一份设计背景。

---

## 使用示例

### 场景一：新仓库调研

```
我：llvm-unicore 新接手，先让 DS 摸底。

架构师：好，创建调研任务。
[创建 code-agent/tasks/001a-research-repo-structure.md]

---
下一步（→ 本地 DS · llvm-unicore）
AI：DeepSeek

> 请先读取 DS.md，然后执行 code-agent/tasks/001a-research-repo-structure.md
```

DS 返回后：

```
我：001a 返回了

架构师：[读完成区] DS 总结了：Target 目录结构、CMake 配置方式、已有测试套件位置。
        [用结论补充 DS.md §仓库布局、§构建环境、§知识库初始化]
        DS.md 已更新，可以开始开发任务。
```

---

### 场景二：实现一个功能

```
我：LLVM 后端需要支持 float 调用约定，DS 来实现。

架构师：好，设计决策如下：
        - f32/f64 参数通过 RF1-RF15 寄存器传递（Full LocInfo）
        - 不走 BCvt 路径，避免无效 stt/ldt roundtrip
        [（可选）落盘 code-agent/designs/float-cc.md]
        [创建 code-agent/tasks/027c-implement-float-cc.md]
        任务包含：架构决策 + 测试场景（新增 float-calling-conv.ll 的行为特征）

---
下一步（→ 本地 DS · llvm-unicore）
AI：DeepSeek
> 请先读取 DS.md，然后执行 code-agent/tasks/027c-implement-float-cc.md
```

DS 实现后：

```
我：027c 返回了

架构师：[读完成区] DS 实现了 LowerCCCArguments f32/f64 case，
        新增 float-calling-conv.ll，CHECK-NOT stt 确认无无效 roundtrip。
        发现一处测试断言口径不一致，直接修复。
        lit 4/4 PASS → commit 027c。
```

---

### 场景三：多仓库并行推进

```
我：027d 和 196a 都可以并行，DS 各发一个。

架构师：[创建两个任务文件]

---
下一步（→ 本地 DS · repo-A）
AI：DeepSeek
> 请先读取 DS.md，然后执行 code-agent/tasks/027d-remove-dead-bitcast.md

---
下一步（→ 远端 21 DS · repo-B）
AI：DeepSeek
> 请先读取 DS.md，然后执行 code-agent/tasks/196a-hotpath-analysis.md
```

不同会话的任务并行推进；同一会话内等上一个返回再发下一个。

---

### 场景四：Review 返回结果

```
我：027d 返回了（/rt 027d）

架构师：[读任务文件 ## 完成区]
        状态：已完成，修改了 DadaoISelLowering.cpp
        发现：getTargetNodeName 漏了 BITCAST_FP_TO_RD case — 直接修复
        [修复 + 运行 lit + 通过 → commit]
```

---

## 文件结构

```
~/claude-agent/
  README.md                        # 本文件（人读）
  USAGE.md                         # 架构师 Agent Setup + 工作流参考（Agent 读）
  collab-framework/
    DS-common.md                   # 通用 DS 规则（部署到 ~/.claude/collab-framework/）
    DS-template.md                 # 新项目 DS.md 模板
    REVIEWER-template.md           # 新项目 REVIEWER.md 模板（独立 reviewer）
    CLAUDE-template.md             # 新项目 CLAUDE.md 模板
    dispatch.md                    # 下发流程
    review-task.md                 # 验收流程
    code-agent/                    # 新项目 code-agent/ 目录模板
  skills/<name>/SKILL.md           # 判断型 skill 的规范源（制度见 skills/README.md）
  enabled/<name> -> ../skills/...  # 启用池：链接在 = 已启用
  decisions/                       # 框架决策记录（制度见 decisions/README.md）
  scripts/
    check-framework.sh             # 总门禁：skill + 决策记录 + 工作树守卫
    sync-skills.sh                 # skill 校验与三客户端投影
    check-decisions.sh             # 决策记录校验
  memory-template/
    MEMORY.md                      # 全局记忆初始模板
    gpt-registry-template.md       # DS 实例注册表模板
```

各项目的 `DS.md` 和 `code-agent/` 随项目仓库携带，不在此目录中。

---

## 谁是什么的权威源

同一条信息只有一个可编辑源。改错地方会造成两份各自漂移，而漂移不会被任何门禁发现。

| 内容 | 权威源 | 说明 |
|---|---|---|
| 通用执行端规则 | `collab-framework/DS-common.md` | 改完必须同步到 `~/.claude/collab-framework/` |
| 独立 reviewer 的通用检查 | `collab-framework/REVIEWER-template.md` | 项目 `REVIEWER.md` 从它初始化 |
| 判断程序（需要判断，不是固定步骤） | `skills/<name>/SKILL.md` | 不得写具体项目命令 |
| 某条 skill 是否启用 | `enabled/` 里有没有链接 | 不看 frontmatter |
| **改框架的理由** | `decisions/` | 项目任务文件只留指针 |
| 变更轨迹 | `git log` | 不设追加式变更日志 |
| 项目专属命令、路径、写入策略 | 该项目的 `DS.md` / `REVIEWER.md` | 可覆盖框架默认，覆盖须写明理由 |

**项目层立的纪律，当轮判定通用还是项目特有。** 通用的同轮回流到 `DS-common.md` / `REVIEWER-template.md`，不回流该项整改不算完成。判据：换一个项目，这条还成立吗？

---

## 框架自身的门禁

```bash
scripts/check-framework.sh --check    # 只校验
scripts/check-framework.sh            # 校验 + 投影 skill 到三个客户端
```

**框架仓由多个架构师会话共写**（各自坐在不同项目根上），所以工作树不留未提交状态——改完当轮 commit（不 push），message 首行标明来源工作区。理由见 `decisions/2026-08-21-framework-repo-shared-by-sessions.md`。

---

## 更多参考

- 架构师工作流完整参考 → `USAGE.md`
- 通用 DS 规则 → `collab-framework/DS-common.md`
- 各项目 DS.md → 对应仓库根目录
