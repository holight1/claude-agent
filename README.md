# claude-agent

Claude（设计/协调）+ ChatGPT Codex（编码）协作框架的全局配置与可移植模板。

## 目录结构

```
claude-agent/
├── skills/                         # Claude Code 全局 skill
│   ├── architect/SKILL.md          # 架构师角色：系统设计、任务创建、代码 Review
│   ├── dispatch/SKILL.md           # /dispatch <task-id>：下发任务给 GPT
│   ├── task/SKILL.md               # /task：查看当前任务状态
│   ├── save/SKILL.md               # /save：保存会话上下文
│   ├── restore/SKILL.md            # /restore：恢复会话上下文
│   └── optimize/SKILL.md           # /optimize：归档已完成任务
├── agents/
│   └── research-task-creator.md   # 自动生成调研任务文件的 agent
└── collab-framework/               # 新项目 2 步部署模板
    ├── README.md                   # 部署说明
    ├── CHATGPT-template.md         # GPT 配置模板（含占位符）
    ├── CLAUDE-template.md          # 项目说明模板
    └── code-agent/                 # GPT 工作区骨架
        ├── ai-collaboration-framework.md
        └── knowledge/
            ├── README.md
            └── 01-project-structure.md
```

## 安装

将 `skills/` 和 `agents/` 安装到 Claude Code 全局目录：

```bash
# Clone
git clone <repo-url> ~/claude-agent

# 安装 skills（全局可用）
cp -r ~/claude-agent/skills/* ~/.claude/skills/

# 安装 agents
cp ~/claude-agent/agents/* ~/.claude/agents/

# 安装 collab-framework 模板
cp -r ~/claude-agent/collab-framework ~/.claude/collab-framework
```

安装后，所有项目下的 Claude Code 可直接使用
`/architect`、`/dispatch`、`/save`、`/restore`、`/task`、`/optimize` 命令。

## 为新项目部署协作框架

详见 `collab-framework/README.md`，核心是 2 步：

1. 复制 `CHATGPT-template.md` → 项目根目录 `CHATGPT.md`，替换 `[PLACEHOLDER]`
2. 复制 `code-agent/` 骨架到项目根目录

## 升级

```bash
cd ~/claude-agent
git pull
cp -r skills/* ~/.claude/skills/
cp agents/*    ~/.claude/agents/
cp -r collab-framework ~/.claude/collab-framework
```
