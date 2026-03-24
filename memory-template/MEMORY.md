# Claude 持久记忆

> 从 `~/` 启动 Claude Code 时自动加载。
> 使用 `/project-add <路径>` 添加项目，`/project-remove <名称>` 移除项目。

## 工作规则
- **不做复杂分析/调研**：创建调研任务让 GPT / Gemini 做，不要自己分析
- **想自己动手前先问用户**：编码/调研/调试必须先征求用户同意
- **任务放对应仓库**：每个项目的任务放各自的 `code-agent/tasks/`
- **知识库引用标章节号**：任务文件引用知识库只写章节号（如 §4.5），行号会变
- **下发任务格式**：每次必须标注目标 AI，格式：`## 下一步（→ [目标]）`；不清楚时先 `/assign-ai`
- **任务头必须含**：`**执行环境**` 字段
- **远端文件同步**：创建远端任务后 rsync 过去，知识库更新也同步

## 项目拓扑

```
（使用 /project-add 添加项目后自动填充）
```

## GPT 实例（详细见 `memory/gpt-registry.md`）

| 标注 | 仓库/用途 | 状态 |
|------|----------|------|
| （使用 /project-add 添加项目后自动填充） | | |

## 仓库与协作

| 仓库 | 本地路径 | 远端路径 | 状态 |
|------|---------|---------|------|
| （使用 /project-add 添加项目后自动填充） | | | |

## 跨仓库协作规则
- **[PUBLIC]**：核心库 `10-changelog.md` 行末标记 → Claude 同步到各适配器知识库
- **[CORE-BUG]**：适配器任务结果标记 → Claude 在核心库创建修复任务
- **两端同步**：rsync `knowledge/` 双向，见核心库 `code-agent/knowledge/00-sync-manifest.md`

## 协作框架
- **通用 skill 已全局化**：architect/assign-ai/dispatch/task/optimize/project-add/project-remove 在 `~/.claude/skills/`
- **新项目模板**：`~/.claude/collab-framework/`（2步部署：CHATGPT.md/GEMINI.md + code-agent/）
- **typecheck**：已有项目 Claude 自查；新项目第一个调研任务让 GPT 自查；无配置默认不启用
- 分主题知识见各仓库 `code-agent/knowledge/`（README.md 有索引）

## 踩坑速记
（在此记录跨项目通用的踩坑经验）
