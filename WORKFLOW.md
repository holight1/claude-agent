# WORKFLOW.md — CC + Codex + DS 协作框架

## 角色

Claude Code（CC）是架构师/协调者：制定计划、判断 review 意见、分配修复、维护 memory。  
DeepSeek/Gemini（DS）执行具体任务（实现/调研/测试）。  
Codex 做代码 review，结果写入任务文件 `## Codex Review` section。

---

## 任务文件标准格式

```markdown
# <前缀>-NNNx：任务标题
**状态**：待执行 / 已完成
**执行环境**：本地 DS · <仓库名> / 远端 <name> DS · <仓库名>

## 前置知识
## 任务描述
## 验收条件

## 完成区            ← DS 填写
**状态**：
**修改文件**：
**验收结果**：
**遗留问题**：

## Codex Review     ← Codex 追加，每轮一个子节
### Round N（commit xxxxxxx）
- 高：...
- 中：...
- 低：...
```

DS 只填 `## 完成区`，不修改其他 section。

---

## Review 流程

当用户说 **"XYZ review 了"**，立即执行三步（无需用户再解释）：

1. **读任务文件**：找 `## Codex Review` 最新 Round + `## 完成区`
2. **逐条判断 + 分配修复**：

   | 情况 | 处理 |
   |------|------|
   | 意见不合理 | 说明原因，跳过 |
   | 1-3 行，完全确定改法 | CC 直接改，运行验收命令 |
   | 需读代码确定，≤1 函数 | 分配给 Codex |
   | 多文件 / 设计判断 / 需编译验证 | 分配给 DS |

3. **更新 memory**：更新 `project_*.md` 任务状态和关键发现，更新 `MEMORY.md` 摘要行

---

## Dispatch 流程

下发任务前：
1. 在对应仓库 `code-agent/tasks/` 确认任务文件存在
2. 查 `memory/gpt-registry.md` 找执行环境对应的路由规则
3. 若为远端，执行表中 scp 命令同步任务文件
4. 输出指令格式：

```
## 下一步（→ 本地/远端 DS · <仓库名>）
**AI：Gemini / DeepSeek**（理由：一句话）
> 请先读取 DS.md，然后执行 code-agent/tasks/<文件名>.md
```

---

## 任务编号规范

- 三位数字 + 字母后缀：`001a`、`001b`
- 前缀按仓库约定（如 `DL-` / `DA-`），在各仓库 DS.md 中定义

---

## DS 会话标注

任务文件 `**执行环境**` 字段格式：
- `本地 DS · <仓库名>`
- `远端 <nickname> DS · <仓库名>`

---

## Memory 维护

- 任务完成/review 后主动更新，不等用户触发
- `MEMORY.md`：每条目一行，≤150 字符，超 200 行把细节移到子文件
- 不写代码细节进 memory（代码在仓库，memory 只写结论和规律）
- 不自动 push 任何仓库
