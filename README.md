# claude-agent

CC + Codex + DS 协作框架，用于在新机器上快速部署相同的协作环境。

## 包含内容

| 文件 | 用途 |
|------|------|
| `WORKFLOW.md` | 协作行为规则（review流程、dispatch格式、任务文件规范） |
| `memory-template/MEMORY.md` | 全局记忆模板 |
| `memory-template/gpt-registry-template.md` | DS 实例注册表模板（填入实际 SSH 地址） |
| `collab-framework/DS-template.md` | 新项目 DS.md 模板 |
| `install.sh` | 一键安装脚本 |

## 快速部署

```bash
# 1. 安装工具
# - Claude Code: https://claude.ai/code
# - RTK: https://github.com/anthropics/rtk

# 2. 克隆并安装
git clone <this-repo> ~/claude-agent
bash ~/claude-agent/install.sh

# 3. 补充机器相关配置
# - 把 ~/CLAUDE.md（全局协调者规则）复制过来
# - 编辑 ~/.claude/projects/.../memory/gpt-registry.md，填入实际 SSH 地址
# - Clone 项目仓库（DS.md 和 code-agent/ 随仓库一起带来）
```

## 升级

```bash
cd ~/claude-agent && git pull && bash install.sh
```

## 说明

- **Skills 已废弃**：行为规则迁移至 `WORKFLOW.md`，由 CC 从 memory 驱动
- **RTK hook** 由 `rtk init --global` 自管理，不在此仓库维护
- **Memory** 不随此仓库迁移——项目上下文随工作自然重建，gpt-registry.md 按新机器网络填写
