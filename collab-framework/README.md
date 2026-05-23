# collab-framework — 模板目录

存放可复用的初始化模板，用于新建项目的协作骨架。

---

## 文件说明

| 文件/目录 | 用途 |
|-----------|------|
| `DS-common.md` | 通用 DS 规则（部署到 `~/.claude/collab-framework/`） |
| `DS-template.md` | 新项目 `DS.md` 模板 |
| `CLAUDE-template.md` | 新项目 `CLAUDE.md` 模板（可选） |
| `dispatch.md` | 下发任务流程描述 |
| `review-task.md` | 任务返回处理流程描述 |
| `code-agent/` | 新项目 `code-agent/` 目录骨架 |

---

## 初始化新项目

详细流程见 `../USAGE.md §2`，核心是两步：

### 1. 创建 DS.md

```bash
cp ~/.claude/collab-framework/DS-template.md /path/to/project/DS.md
```

打开文件，替换占位符：

- `[PROJECT_NAME]` → 项目名（如 `llvm-unicore`）
- `[PREFIX]` → 任务文件前缀（如 `DL`，生成 `DL-001a-描述.md`）

其余章节（仓库布局、知识库、工作规则）**先留空**，第一次调研任务完成后由架构师补充。

### 2. 复制 code-agent/ 骨架

```bash
cp -r ~/.claude/collab-framework/code-agent/ /path/to/project/code-agent/
```

骨架包含：`tasks/`、`designs/`、`knowledge/README.md`、`knowledge/01-project-structure.md`、`knowledge/10-changelog.md`。
