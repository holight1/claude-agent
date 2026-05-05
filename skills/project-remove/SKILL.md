---
description: "Remove a project from Claude's global management - unregister from memory without touching any project files"
allowed-tools: ["Read", "Write", "Edit", "Bash"]
argument-hint: "<project-name>"
---

# /project-remove - 从全局管理中移除项目

将项目从 Claude 的 global memory 注销。

**重要：不会修改项目的任何文件。**
`DS.md`、`code-agent/`、知识库、任务文件全部保持原样，随时可用 `/project-add` 重新注册。

## 执行步骤

### 1. 读取 memory

```bash
MEMORY_DIR="${HOME}/.claude/projects/-home-$(whoami)/memory"
```

在以下位置搜索 `<project-name>`：
- `MEMORY.md` 的项目拓扑代码块
- `MEMORY.md` 的 DS 实例表
- `MEMORY.md` 的仓库与协作表
- `ds-registry.md` 的当前活跃实例

若所有位置均未找到，告知用户项目未注册，退出。

### 2. 展示将要移除的内容，请用户确认

```
将从 global memory 中移除 <project-name>：

  [移除] 项目拓扑块
  [移除] DS 实例：本地 DS · <project-name>
  [移除] DS 实例：远端 DS · <project-name>（若存在）
  [移除] 仓库与协作表中的对应行

以下内容不受影响：
  [保留] <project-path>/DS.md
  [保留] <project-path>/code-agent/

确认移除？(y/N)
```

### 3. 执行移除

**MEMORY.md**：
- 删除项目拓扑代码块中该项目的块（项目名行 + 所有 `├──`/`└──` 子行）
- 删除 DS 实例表中 `本地 DS · <project-name>` 和 `远端 DS · <project-name>` 行
- 删除仓库与协作表中对应行

**ds-registry.md**：
- 删除"当前活跃实例"中对应的 `### N. 本地/远端 DS · <project-name>` 整块
- 在"历史停用实例"表追加：
  ```
  | `本地 DS · <project-name>` | <YYYY-MM-DD> | 项目注销 |
  | `远端 DS · <project-name>` | <YYYY-MM-DD> | 项目注销 |   ← 若存在
  ```
- 删除 dispatch 路由规则表中对应的远端条目（若存在）

### 4. 输出确认

```
已从 global memory 移除项目：<project-name>

未修改的文件：
  <project-path>/DS.md
  <project-path>/code-agent/

如需重新管理，运行：/project-add <project-path>
```

## 注意

- 不删除任何项目文件（DS.md、code-agent/ 等）
- 移除后可随时用 `/project-add` 重新注册，不影响已有知识库和任务文件
