---
description: "Dispatch a task to ChatGPT - find or create task file and output standard instruction"
allowed-tools: ["Read", "Write", "Glob", "Bash"]
argument-hint: "<task-id>"
---

# /dispatch <task-id> - 下发任务给 GPT

根据 task-id 找到任务文件，判断目标 GPT，输出标准下发指令。

## 执行步骤

### 1. 查找任务文件

在 `code-agent/tasks/` 中搜索匹配 `<task-id>` 的文件：
- 搜索模式：`code-agent/tasks/<task-id>*.md`
- 找到多个时列出让用户选择
- 找不到时提示用户先创建任务文件

### 2. 读取任务文件，提取关键字段

- **执行环境**：判断目标 GPT
  - `本地 GPT` → 本地执行，无需 rsync
  - `远端 GPT · <仓库名>` → 需 rsync 到远端机器

- **知识库引用检查**：引用格式应为 `§章节号`（如 §20.10），行号会变不要要求。
  若引用完全缺失章节号则提醒补充。

### 3. 远端任务：rsync 到远端机器

若 `执行环境` 为 `远端 GPT`，**先查阅 memory 中的 `gpt-registry.md`**
获取该 GPT 实例的 rsync 目标路径，然后同步任务文件：

```bash
# 路由规则来自 memory/gpt-registry.md 的 dispatch 路由表，示例：
# 远端 GPT · <仓库名>  → user@remote-host:/path/to/repo/code-agent/tasks/
rsync -av <本地任务文件路径> user@remote-host:<远端对应路径>
```

确认 rsync 成功后再输出下发指令。

### 4. 输出下发指令

**本地 GPT 格式：**
```
---
## 下一步（→ 本地 GPT）

请将以下指令发送给本地 ChatGPT：

> 请先读取 CHATGPT.md，然后执行 code-agent/tasks/<完整文件名>.md
```

**远端 GPT 格式：**
```
---
## 下一步（→ 远端 GPT · <仓库名>）

任务文件已 rsync 到远端。请将以下指令发送给远端 GPT（<仓库名>）：

> 请先读取 CHATGPT.md，然后执行 code-agent/tasks/<完整文件名>.md
```

## 注意

- 下发指令中的目标（本地 / 远端）必须与任务文件 `执行环境` 字段一致
- 路由规则从 memory 的 `gpt-registry.md` 读取，不要硬编码主机地址
- 知识库引用用章节号（§4.5），不要要求行号
- rsync 失败时报错，不要继续输出下发指令
