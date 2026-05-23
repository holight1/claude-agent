# claude-agent

多 AI 协作框架：Claude 担任架构师，DS / Gemini 执行编码和调研任务。

Claude 设计接口、拆任务、Review 代码；DS / Gemini 聚焦单一任务执行。任务文件是双方之间的"合同"——描述架构约束和验收条件，不写实现步骤，由 DS 读现有代码自行推导实现。

---

## 前置条件

- [Claude Code](https://claude.ai/code)（架构师端）
- DeepSeek / Gemini 访问权限（执行端，本地会话或远端机器均可）

---

## 快速开始

```bash
git clone <this-repo> ~/claude-agent
cd ~ && claude
```

然后把这句话发给 Claude（架构师 Agent）：

> 请阅读 `~/claude-agent/USAGE.md`，按其中的 Setup 指南完成环境初始化，完成后告诉我做了哪些步骤。

Claude 会自动完成：部署通用规则文件、初始化 memory、在 `~/.claude/CLAUDE.md` 中注册框架。

---

## 使用示例

### 场景一：调研一个模块

```
我：serverd 守护进程是怎么初始化设备的？让 DS 调研一下。

Claude：好，我来创建调研任务。
[创建 code-agent/tasks/041a-research-serverd-init.md]

---
下一步（→ 本地 DS · myproject）
AI：Gemini（调研类，无限量）

请将以下指令发给 Gemini：
> 请先读取 DS.md，然后执行 code-agent/tasks/041a-research-serverd-init.md
```

Gemini 完成后：

```
我：041a 返回了

Claude：[读完成区，提取技术结论，更新知识库]
        发现设备初始化分三步：枚举 → 上电 → 注册中断。
        已更新 code-agent/knowledge/03-serverd.md §3.1。
```

---

### 场景二：实现一个功能

```
我：LLVM 后端需要支持 float 调用约定，DS 来实现。

Claude：好，设计决策如下：
        - f32/f64 参数通过 RF1-RF15 寄存器传递（Full LocInfo）
        - 不走 BCvt 路径，避免无效 stt/ldt roundtrip
        [创建 code-agent/tasks/027c-implement-float-cc.md]
        任务包含：架构决策 + 测试场景（新增 float-calling-conv.ll 的行为特征）

---
下一步（→ 本地 DS · llvm-unicore）
AI：DeepSeek（实现类）
> 请先读取 DS.md，然后执行 code-agent/tasks/027c-implement-float-cc.md
```

DS 实现后：

```
我：027c 返回了

Claude：[读完成区] DS 实现了 LowerCCCArguments f32/f64 case，
        新增 float-calling-conv.ll，CHECK-NOT stt 确认无无效 roundtrip。
        发现一处测试断言口径不一致，直接修复。
        lit 4/4 PASS → commit 027c。
```

---

### 场景三：多仓库并行推进

```
我：027d 和 196a 都可以并行，DS 各发一个。

Claude：[创建两个任务文件]

---
下一步（→ 本地 DS · llvm-unicore）
AI：DeepSeek
> 请先读取 DS.md，然后执行 code-agent/tasks/027d-remove-dead-bitcast.md

---
下一步（→ 远端 21 DS · SuBase-SY）
AI：DeepSeek
> 请先读取 DS.md，然后执行 code-agent/tasks/196a-hotpath-analysis.md
```

不同会话的任务并行推进；同一会话内等上一个返回再发下一个。

---

### 场景四：Review 返回结果

```
我：027d 返回了（/ /rt 027d）

Claude：[读任务文件 ## Codex Review 最新 Round]
        高：getTargetNodeName 漏了 BITCAST_FP_TO_RD case — 直接修复
        中：—
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
