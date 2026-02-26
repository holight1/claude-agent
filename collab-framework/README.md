# AI 协作框架模板

Claude（设计/协调）+ ChatGPT Codex（编码）的极简可移植模板。

通用 skill（architect/dispatch/task/save/restore/optimize）已全局安装在
`~/.claude/skills/`，无需单独配置。

## 2 步部署新项目

### 步骤 1：配置 CHATGPT.md

```bash
cp ~/.claude/collab-framework/CHATGPT-template.md <新项目根目录>/CHATGPT.md
```

打开文件，在顶部"项目定制"区块替换占位符：
- `[AUTHOR]` → 作者姓名（如 `SUI Yan`）
- `[COMPANY]` → 公司名（如 `Sunmmio Inc.`）
- `[PROJECT_SCOPE]` → 版权范围描述（如 `MyProject, Company's Device`）
- `[YEAR]` → 当前年份（如 `2026`）
- `[TYPECHECK_STATUS]` → **默认填"不启用"**；首个调研任务完成后，由 GPT 报告项目是否配置了 lint/typecheck 工具，再按实际情况更新

### 步骤 2：复制 code-agent/ 骨架

```bash
cp -r ~/.claude/collab-framework/code-agent/ <新项目根目录>/code-agent/
```

完成！**推荐从 `~/` 启动 Claude Code**（而非项目目录），
memory 将存储在全局路径 `~/.claude/projects/-home-<user>/memory/`，
实现跨项目的协调者视角。Claude 仍可正常读取各项目的 CLAUDE.md。

Claude 的全局 skill 立即可用：
- `/architect` — 系统设计、任务创建、代码 Review
- `/dispatch <task-id>` — 下发任务给 GPT
- `/save` — 保存会话上下文
- `/restore` — 恢复会话上下文
- `/task` — 查看当前任务状态
- `/optimize` — 归档已完成任务

## 可选：CLAUDE.md

若项目有构建/测试命令，复制并填写 CLAUDE-template.md：

```bash
cp ~/.claude/collab-framework/CLAUDE-template.md <新项目根目录>/CLAUDE.md
```
