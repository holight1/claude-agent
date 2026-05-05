---
description: "Add a project to Claude's global management - register in memory with local and optional remote DS instances"
allowed-tools: ["Read", "Write", "Edit", "Bash", "Glob"]
argument-hint: "<project-path> [remote: user@host:remote-path [server-nickname]]"
---

# /project-add - 添加项目到全局管理

将本地（可选+远端）项目注册到 Claude 的 global memory，
使其可被 `/dispatch`、`/architect` 等 skill 协调管理。

## 执行步骤

### 1. 解析参数

从用户输入提取：
- `project-path`：本地项目路径（支持绝对路径或 `~/xxx`）
- `remote`（可选）：格式 `user@host:remote-path`
- `server-nickname`（可选）：远端服务器简称，如 `21`、`51`、`152`；未提供则从 host 末段自动推导

派生：
- `project-name`：`basename(project-path)`
- 远端 DS 标注：`远端 <server-nickname> DS · <project-name>`（例：`远端 21 DS · <repo-name>`）

### 2. 检查并创建项目配置文件

```bash
ls <project-path>/DS.md 2>/dev/null && echo "OK" || echo "缺失"
ls <project-path>/GEMINI.md  2>/dev/null && echo "OK" || echo "缺失"
ls <project-path>/code-agent/ 2>/dev/null && echo "OK" || echo "缺失"
```

- 若 `DS.md` 缺失，从模板复制并提示用户填写占位符（不阻止注册）：
  ```bash
  cp ~/.claude/collab-framework/DS-template.md <project-path>/DS.md
  ```
  复制完成后告知用户：需打开 `DS.md`，替换顶部占位符（[AUTHOR]、[COMPANY]、[PROJECT_SCOPE]、[YEAR]、[TYPECHECK_STATUS]）。
- 若 `GEMINI.md` 缺失，从模板复制（不阻止注册）：
  ```bash
  cp ~/.claude/collab-framework/GEMINI-template.md <project-path>/GEMINI.md
  ```
  同样提示用户替换占位符（如模板中有）。
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

读取 `${MEMORY_DIR}/MEMORY.md` 和 `${MEMORY_DIR}/ds-registry.md`。

若项目已存在于 memory，提示用户并询问是否覆盖，不覆盖则退出。

### 4. 更新 MEMORY.md（三处）

**项目拓扑**：在代码块内追加（若有远端则含远端行，否则省略）：
```
<project-name>
├── 本地   <project-path>
└── 远端   <user@host:remote-path>
```

**DS 实例表**：追加行：
```
| `本地 DS · <project-name>` | <project-name> 本地 | 活跃 |
| `远端 <nickname> DS · <project-name>` | <project-name> 远端 | 活跃 |   ← 仅当有远端
```

**仓库与协作表**：追加行：
```
| <project-name> | `<project-path>` | `<remote>` 或 — | 进行中 |
```

### 5. 更新 ds-registry.md

在"当前活跃实例"区末尾追加（N 为下一个序号）：

```markdown
### N. 本地 DS · <project-name>
- **标注**：`本地 DS · <project-name>`
- **DS.md**：`<project-path>/DS.md`
- **任务目录**：`<project-path>/code-agent/tasks/`
- **知识库**：`<project-path>/code-agent/knowledge/`
- **状态**：活跃
```

若有远端，追加：
```markdown
### N+1. 远端 <nickname> DS · <project-name>
- **标注**：`远端 <nickname> DS · <project-name>`
- **SSH**：`<user@host>`
- **DS.md**：`<remote-path>/DS.md`
- **任务目录**：`<remote-path>/code-agent/tasks/`
- **知识库**：`<remote-path>/code-agent/knowledge/`
- **知识库同步**：DS 生成的知识文件需 scp 回本地 `<project-path>/code-agent/knowledge/`
- **状态**：活跃
```

同时在 dispatch 路由规则表中追加远端条目（若有远端）：
```
| `远端 <nickname> DS · <project-name>` | `scp <local-task-file> <user@host>:<remote-path>/code-agent/tasks/` | 远端 DeepSeek |
```

> **注意传输命令**：标准 SSH 端口用 `scp`，非标准端口用 `scp -P <port>`，无法用 rsync 时同样用 scp。
> 路由表中直接写完整传输命令，dispatch skill 据此执行。

### 6. 远端初始文件同步

若有远端，注册完成后立即将必要文件同步到远端，避免 DS 执行任务时缺少上下文：

```bash
# 确保远端目录结构存在
ssh <user@host> 'mkdir -p <remote-path>/code-agent/knowledge <remote-path>/code-agent/designs <remote-path>/code-agent/tasks'

# 同步必要 MD 文件（使用路由表中对应的传输命令）
scp <project-path>/DS.md <user@host>:<remote-path>/DS.md
scp <project-path>/code-agent/ai-collaboration-framework.md \
    <user@host>:<remote-path>/code-agent/ai-collaboration-framework.md
scp <project-path>/code-agent/knowledge/README.md \
    <user@host>:<remote-path>/code-agent/knowledge/README.md  # 若存在
```

若首次下发的任务引用了设计文档，提醒用户在 `/dispatch` 前手动 scp 对应文件。

### 7. 输出确认

展示注册摘要：
- 项目名和本地路径
- 注册的 DS 实例列表（含远端标注全名）
- 远端已同步文件清单
- 若有缺失文件，给出补全命令
- 下一步建议：`/architect` 开始设计，或 `/dispatch <task-id>` 下发任务

## 注意

- **只注册，不创建/修改项目文件**（远端初始同步除外）
- 若项目已注册，询问用户是否覆盖
