# dispatch — 下发任务流程

架构师向 DS 下发任务时执行以下步骤。

---

## 1. 确认任务文件存在

在对应仓库的 `code-agent/tasks/` 中找到任务文件（格式 `NNNx-描述.md`）。
文件不存在时先创建，再下发。

## 2. 读取执行环境字段

任务文件头部的 `**执行环境**` 字段决定路由：

| 值 | 含义 |
|----|------|
| `本地 DS · <仓库名>` | 本地执行，无需同步 |
| `远端 <nickname> DS · <仓库名>` | 需先同步任务文件到远端 |

## 3. 远端任务：同步文件

若为远端，从 `memory/gpt-registry.md` 的路由表中找到对应行，
取出 scp 命令，将任务文件同步到远端机器，确认成功后继续。

路由表示例：
```
| 远端 21 DS · repo-A | scp <file> user@192.168.x.x:~/repo-A/code-agent/tasks/ |
| 远端 152 DS · repo-B | scp -P 22005 <file> user@192.168.x.x:~/repo-B/code-agent/tasks/ |
```

同步失败时报错，不继续输出下发指令。

## 4. AI 选型

根据任务类型决定发给 **Gemini** 还是 **DeepSeek**：

| → DeepSeek（更强，省着用） | → Gemini（无限量） |
|--------------------------|------------------|
| 实现/修复/重构（impl/fix/refactor） | 调研/搜索/recon |
| 多文件改动 | 构建/运行/测试执行 |
| 调试排错 | 单文件只读或结构化输出 |
| 算法实现 & 结果验证 | 知识库整理/changelog |
| 复杂配置脚本修改 | smoke test / 回归测试 |

默认：调研 → Gemini；实现/调试 → DeepSeek。

## 5. 输出下发指令

指令中**必须标注目标 AI**（Gemini / DeepSeek）。

```
---
## 下一步（→ 本地/远端 <nickname> DS · <仓库名>）

**AI：Gemini / DeepSeek**（理由：一句话）

请将以下指令发送给 [Gemini / DeepSeek]：

> 请先读取 DS.md，然后执行 code-agent/tasks/<完整文件名>.md
```

多仓库并行时，每条指令前都必须有完整标注，用户一眼看清发给哪个会话。
