# claude-agent

Claude（设计/协调）+ GPT / Gemini（编码与调研）协作框架的全局配置与可移植模板。

## 目录结构

```
claude-agent/
├── install.sh                      # 一键安装/升级脚本
├── skills/                         # Claude Code 全局 skill
│   ├── architect/SKILL.md          # 架构师角色：系统设计、任务创建、代码 Review
│   ├── assign-ai/SKILL.md          # /assign-ai <task>：路由到 GPT 或 Gemini
│   ├── dispatch/SKILL.md           # /dispatch <task-id>：下发任务给指定 AI
│   ├── task/SKILL.md               # /task：查看当前任务状态
│   ├── optimize/SKILL.md           # /optimize：归档已完成任务
│   ├── project-add/SKILL.md        # /project-add <path>：注册项目到全局管理
│   └── project-remove/SKILL.md     # /project-remove <name>：注销项目（不删文件）
├── memory-template/                # 首次安装时的 global memory 模板
│   ├── MEMORY.md
│   └── gpt-registry.md
├── agents/
│   └── research-task-creator.md   # 自动生成调研任务文件的 agent
└── collab-framework/               # 新项目部署模板
    ├── README.md                   # 部署说明
    ├── CHATGPT-template.md         # GPT 配置模板（含占位符）
    ├── GEMINI-template.md          # Gemini 配置模板
    ├── CLAUDE-template.md          # 项目说明模板
    └── code-agent/                 # GPT 工作区骨架
        ├── ai-collaboration-framework.md
        ├── tasks/                  # 任务文件目录
        ├── designs/                # 设计文档目录
        └── knowledge/
            ├── README.md
            └── 01-project-structure.md
```

## 安装

```bash
git clone <repo-url> ~/claude-agent
bash ~/claude-agent/install.sh
```

脚本完成：skills 安装、agents 安装、collab-framework 安装、global memory 初始化（已有则跳过）。

安装后可用命令：
`/architect`、`/assign-ai`、`/dispatch`、`/task`、`/optimize`、`/project-add`、`/project-remove`

## 详细使用说明

见 [USAGE.md](USAGE.md)，涵盖：调研任务/开发任务下发、任务文件格式、知识库管理、多项目关系处理、AI 选型和典型场景示例。

## 为新项目部署协作框架

详见 `collab-framework/README.md`，核心是 3 步：

1. 复制 `CHATGPT-template.md` → 项目根目录 `CHATGPT.md`，替换占位符
2. 复制 `GEMINI-template.md` → 项目根目录 `GEMINI.md`（可选）
3. 复制 `code-agent/` 骨架到项目根目录

## 升级

```bash
cd ~/claude-agent
git pull
bash install.sh   # 幂等，已有 memory 不覆盖
```
