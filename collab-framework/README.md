# AI 协作框架模板

Claude（设计/协调）+ ChatGPT Codex（编码）+ Gemini（大规模代码分析）的极简可移植模板。

通用 skill（architect/assign-ai/dispatch/task/optimize）已全局安装在
`~/.claude/skills/`，无需单独配置。

## 3 步部署新项目

### 步骤 1：配置 CHATGPT.md（GPT 用）

```bash
cp ~/.claude/collab-framework/CHATGPT-template.md <新项目根目录>/CHATGPT.md
```

打开文件，在顶部"项目定制"区块替换占位符：
- `[AUTHOR]` → 作者姓名（如 `SUI Yan`）
- `[COMPANY]` → 公司名（如 `Sunmmio Inc.`）
- `[PROJECT_SCOPE]` → 版权范围描述（如 `MyProject, Company's Device`）
- `[YEAR]` → 当前年份（如 `2026`）
- `[TYPECHECK_STATUS]` → **默认填"不启用"**；首个调研任务完成后，由 GPT 报告项目是否配置了 lint/typecheck 工具，再按实际情况更新

### 步骤 2：配置 GEMINI.md（Gemini 用）

```bash
cp ~/.claude/collab-framework/GEMINI-template.md <新项目根目录>/GEMINI.md
```

同样替换顶部占位符（与 CHATGPT.md 相同的四个变量）。

### 步骤 3：复制 code-agent/ 骨架

```bash
cp -r ~/.claude/collab-framework/code-agent/ <新项目根目录>/code-agent/
```

完成！Claude 的全局 skill 立即可用：
- `/architect` — 系统设计、任务创建、代码 Review
- `/dispatch <task-id>` — 下发任务给 GPT
- `/assign-ai <task-id>` — 选型路由（Gemini vs GPT 5.3）
- `/task` — 查看当前任务状态
- `/optimize` — 归档已完成任务

## AI 分工速查

| AI | 擅长 | token 限制 | 下发方式 |
|----|------|-----------|---------|
| **Gemini** | 大规模代码读取/分析、公开项目调研、知识库整理 | 无限 | 粘贴任务到 Gemini 对话（不用 CHATGPT.md） |
| **GPT 5.3** | 实现/修复/调试/多文件改动 | 有限，省着用 | `/dispatch <task-id>` |
| **Claude** | 设计/协调/架构/任务拆解/Review | — | 直接对话 |

### Gemini 任务规范

- `**执行环境**：Gemini`（不填具体仓库）
- 任务文件末尾写"下发方式"说明（上传哪些文件、如何提交）
- 输出约定：Gemini 返回 Markdown 格式知识，由 Claude 写入知识库
- 任务文件仍放在对应仓库的 `code-agent/tasks/` 下（便于追踪）

## 可选：CLAUDE.md

若项目有构建/测试命令，复制并填写 CLAUDE-template.md：

```bash
cp ~/.claude/collab-framework/CLAUDE-template.md <新项目根目录>/CLAUDE.md
```
