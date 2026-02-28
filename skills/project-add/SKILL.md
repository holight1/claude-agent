---
description: "Add a project to Claude's global management - register in memory with local and optional remote GPT instances"
allowed-tools: ["Read", "Write", "Edit", "Bash", "Glob"]
argument-hint: "<project-path> [remote: user@host:remote-path]"
---

# /project-add - 添加项目到全局管理

将本地（可选+远端）项目注册到 Claude 的 global memory，
使其可被 `/dispatch`、`/architect` 等 skill 协调管理。

## 执行步骤

### 1. 解析参数

从用户输入提取：
- `project-path`：本地项目路径（支持绝对路径或 `~/xxx`）
- `remote`（可选）：格式 `user@host:remote-path`

派生：
- `project-name`：`basename(project-path)`

### 2. 检查并创建项目配置文件

```bash
ls <project-path>/CHATGPT.md 2>/dev/null && echo "OK" || echo "缺失"
ls <project-path>/GEMINI.md  2>/dev/null && echo "OK" || echo "缺失"
ls <project-path>/code-agent/ 2>/dev/null && echo "OK" || echo "缺失"
```

- 若 `CHATGPT.md` 缺失，创建 symlink（不阻止注册）：
  ```bash
  ln -s ~/.claude/roles/gpt.md <project-path>/CHATGPT.md
  ```
- 若 `GEMINI.md` 缺失，创建 symlink（不阻止注册）：
  ```bash
  ln -s ~/.claude/roles/gemini.md <project-path>/GEMINI.md
  ```
- 若 `code-agent/` 缺失，复制骨架并替换 ai-collaboration-framework.md 为 symlink（不阻止注册）：
  ```bash
  cp -r ~/.claude/collab-framework/code-agent/ <project-path>/code-agent/
  rm <project-path>/code-agent/ai-collaboration-framework.md
  ln -s ~/.claude/collab-framework/code-agent/ai-collaboration-framework.md \
        <project-path>/code-agent/ai-collaboration-framework.md
  ```
- 若 `code-agent/` 已存在但 `ai-collaboration-framework.md` 不是 symlink，替换之：
  ```bash
  ln -sf ~/.claude/collab-framework/code-agent/ai-collaboration-framework.md \
         <project-path>/code-agent/ai-collaboration-framework.md
  ```

### 3. 确认 memory 路径

```bash
MEMORY_DIR="${HOME}/.claude/projects/-home-$(whoami)/memory"
```

读取 `${MEMORY_DIR}/MEMORY.md` 和 `${MEMORY_DIR}/gpt-registry.md`。

若项目已存在于 memory，提示用户并询问是否覆盖，不覆盖则退出。

### 4. 更新 MEMORY.md（三处）

**项目拓扑**：在代码块内追加（若有远端则含远端行，否则省略）：
```
<project-name>
├── 本地   <project-path>
└── 远端   <user@host:remote-path>
```

**GPT 实例表**：追加行：
```
| `本地 GPT · <project-name>` | <project-name> 本地 | 活跃 |
| `远端 GPT · <project-name>` | <project-name> 远端 | 活跃 |   ← 仅当有远端
```

**仓库与协作表**：追加行：
```
| <project-name> | `<project-path>` | `<remote>` 或 — | 进行中 |
```

### 5. 更新 gpt-registry.md

在"当前活跃实例"区末尾追加（N 为下一个序号）：

```markdown
### N. 本地 GPT · <project-name>
- **标注**：`本地 GPT · <project-name>`
- **CHATGPT.md**：`<project-path>/CHATGPT.md`
- **任务目录**：`<project-path>/code-agent/tasks/`
- **知识库**：`<project-path>/code-agent/knowledge/`
- **状态**：活跃
```

若有远端，追加：
```markdown
### N+1. 远端 GPT · <project-name>
- **标注**：`远端 GPT · <project-name>`
- **SSH**：`<user@host>`
- **任务目录**：`<remote-path>/code-agent/tasks/`
- **rsync 目标**：`<user@host>:<remote-path>/code-agent/tasks/`
- **状态**：活跃
```

同时在 dispatch 路由规则表中追加远端条目（若有远端）：
```
| `远端 GPT · <project-name>` | `<user@host>:<remote-path>/code-agent/tasks/` | 远端 ChatGPT |
```

### 6. 输出确认

展示注册摘要：
- 项目名和本地路径
- 注册的 GPT 实例列表
- 若有缺失文件，给出补全命令
- 下一步建议：`/architect` 开始设计，或 `/dispatch <task-id>` 下发任务

## 注意

- **只注册，不创建/修改项目文件**
- 若项目已注册，询问用户是否覆盖
