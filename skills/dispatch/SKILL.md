---
description: "Dispatch a task to DeepSeek - find or create task file and output standard instruction"
allowed-tools: ["Read", "Write", "Glob", "Bash"]
argument-hint: "<task-id>"
---

# /dispatch <task-id> - 下发任务给 DS

根据 task-id 找到任务文件，判断目标 DS，输出标准下发指令。

## 执行步骤

### 1. 查找任务文件

在 `code-agent/tasks/` 中搜索匹配 `<task-id>` 的文件：
- 搜索模式：`code-agent/tasks/<task-id>*.md`
- 找到多个时列出让用户选择
- 找不到时提示用户先创建任务文件

### 2. 读取任务文件，提取关键字段

- **执行环境**：判断目标 DS
  - `本地 DS` → 本地执行，无需同步
  - `远端 * DS · <仓库名>`（如 `远端 21 DS · <repo-name>`）→ 需同步到远端机器

- **知识库引用检查**：引用格式应为 `§章节号`（如 §20.10），行号会变不要要求。
  若引用完全缺失章节号则提醒补充。

- **实现/修复类任务规格检查**（类型为 `实现 / fix / refactor` 时才检查，调研/debug 跳过）：
  - ✓ 有接口定义（Args struct / 函数签名）或明确的改动目标
  - ✓ 有参考指针（"参考 xxx.c 的 yyy 模式"）或工具链路径
  - ✗ 不应包含大量 for 循环伪码或 Step-by-step 手把手分解——实现细节让 DS 读现有代码
  若有大量伪码，提醒用户简化（不阻塞下发，仅提示）。

### 3. 远端任务：同步到远端机器

若 `执行环境` 含 `远端`，**先查阅 memory 中的 `ds-registry.md`**，
在 dispatch 路由规则表中找到匹配的行，**直接使用表中记录的传输命令**同步任务文件：

路由表示例（实际值见 ds-registry.md）：
```
| `远端 21 DS · <repo>` | `scp <file> user@host-21:~/<repo>/code-agent/tasks/` | 远端 21 DeepSeek |
| `远端 152 DS · <repo>` | `scp -P 22005 <file> user@host-152:~/<repo>/code-agent/tasks/` | 远端 152 DeepSeek |
```

将 `<file>` 替换为本地任务文件实际路径，执行传输命令。确认成功后再输出下发指令。

> **不要**假设一律用 `rsync`，传输命令以路由表为准（可能是 scp / scp -P / rsync）。

### 4. AI 选型

根据任务类型决定发给 **Gemini** 还是 **DeepSeek**：

| → DeepSeek（更强，省着用） | → Gemini（无限量） |
|--------------------------|------------------|
| 实现/修复/重构（impl/fix/refactor） | 调研/搜索/recon |
| 多文件改动 | 构建/运行/测试执行 |
| 调试排错 | 单文件只读或结构化输出 |
| 算法实现 & 结果验证 | 知识库整理/changelog |
| 复杂配置脚本修改 | smoke test / 回归测试 |

默认：调研 → Gemini；实现/调试 → DeepSeek；有疑问时任务简单选 Gemini，任务复杂选 DeepSeek。

### 5. 输出下发指令

指令中**必须标注目标 AI**（Gemini / DeepSeek）。

**本地 DS 格式：**
```
---
## 下一步（→ 本地 DS）

**AI：Gemini / DeepSeek**（理由：一句话）

请将以下指令发送给 [Gemini / DeepSeek]：

> 请先读取 DS.md，然后执行 code-agent/tasks/<完整文件名>.md
```

**远端 DS 格式：**
```
---
## 下一步（→ 远端 <nickname> DS · <仓库名>）

**AI：Gemini / DeepSeek**（理由：一句话）

任务文件已同步到远端。请将以下指令发送给 [Gemini / DeepSeek]（<仓库名>）：

> 请先读取 DS.md，然后执行 code-agent/tasks/<完整文件名>.md
```

## 注意

- 下发指令中的目标（本地 / 远端）必须与任务文件 `执行环境` 字段一致
- 路由规则从 memory 的 `ds-registry.md` 读取，不要硬编码主机地址
- 知识库引用用章节号（§4.5），不要要求行号
- 传输失败时报错，不要继续输出下发指令
