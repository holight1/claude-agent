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

架构师会自动完成：部署通用规则文件、初始化 memory、在全局配置中注册框架。

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
    code-agent/                    # 新项目 code-agent/ 目录模板
  memory-template/
    MEMORY.md                      # 全局记忆初始模板
    gpt-registry-template.md       # DS 实例注册表模板
```

各项目的 `DS.md` 和 `code-agent/` 随项目仓库携带，不在此目录中。

---

## 更多参考

- 架构师工作流完整参考 → `USAGE.md`
- 通用 DS 规则 → `collab-framework/DS-common.md`
- 各项目 DS.md → 对应仓库根目录
