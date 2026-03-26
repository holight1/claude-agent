---
description: "Review returned task and update memory/knowledge files - check if MEMORY.md, project/feedback files, or knowledge base need updating after a task completes"
allowed-tools: ["Read", "Write", "Edit", "Glob", "Grep", "Bash"]
argument-hint: "<task-id>"
---

# /review-task <task-id> - 任务返回后更新 memory 和本地 MD

任务从 GPT/Gemini 返回后，检查是否有新发现需要写入 memory 或知识库。

## 执行步骤

### 1. 找到并读取任务文件

在所有仓库的 `code-agent/tasks/` 中搜索 `<task-id>*.md`，优先查：
- `~/SuBase-SY/code-agent/tasks/`
- `~/gem5-a4e/code-agent/tasks/`
- `~/a4e_single_core/code-agent/tasks/`
- 其他仓库

**找到文件后，先检查 `**执行环境**` 字段是否含 `远端`**：
- 若是远端任务，**必须先从远端拉取最新版本**，再读取，否则读到的是发出时的旧版本（完成区为空）。
- 拉取命令从 `gpt-registry.md` 的 dispatch 路由规则中反推：push 命令 `scp [-P port] <file> user@host:remote_path` → pull 命令 `scp [-P port] user@host:remote_path/<file> <local_file>`。
- 路由表示例（实际从 memory 读取）：
  - `远端 B GPT · repo-name` → `scp [-P port] user@host-B:~/repo-name/code-agent/tasks/<file> ~/repo-name/code-agent/tasks/<file>`
- 拉取失败时报错，不继续。

读取任务文件的 **完成区**（`## 完成区` / `## 执行结果` / `## 结论` 等）。
若任务文件没有完成区内容（仍是模板占位），说明结果还没写回，提示用户。

### 2. 代码 Review（若任务有代码改动）

若完成区提到修改了源码文件，**必须 review 代码**，再进行 memory 更新。

- 先用 `git status` 了解改动范围（modified + untracked），再按需读取相关文件；不要只依赖 `git diff HEAD`（会漏掉新增的未跟踪文件）
- **review 范围**：任务修改的所有源码文件均需 review，包括测试脚本、工具脚本等
- 检查逻辑是否正确、是否与任务设计一致、有无明显 bug
- 若发现问题，直接告知用户，不要继续写 memory（等用户决定是否返工）
- 若代码无问题，在后续 memory 更新中注明"代码已 review"

### 3. 判断需要更新哪些文件

对照完成区内容，逐一检查：

**A. MEMORY.md 摘要行**
- `~/.claude/projects/-home-holight/memory/MEMORY.md`
- 若任务结论改变了某个项目的状态/进展，更新对应摘要行

**B. project_*.md 文件**
- 若任务涉及某个活跃项目（gem5 H2D、backend-refactor、cuda-mocking 等），
  找到对应的 `memory/project_*.md` 并更新进展/状态

**C. feedback_*.md 文件**
- 若任务暴露了新的操作规范（"应该这样做"/"不该那样做"），
  新建或更新对应 `memory/feedback_*.md`

**D. 知识库文件**（`code-agent/knowledge/`）
- 若任务包含新的技术结论，检查对应仓库的知识库是否需要新增章节
- 知识库更新较重，若结论确定才写；若还有后续验证，先写 memory 即可

**E. 10-changelog.md**
- 若任务对仓库代码有实质改动，在对应仓库的 `code-agent/knowledge/10-changelog.md`
  添加一行记录（格式：`| 日期 | 描述 | GPT/Claude |`）

### 3. 判断规则

| 有新发现 | 推翻旧结论 | 操作 |
|---------|----------|------|
| 是 | 否 | 追加到现有 memory 文件 |
| 是 | 是 | 更新现有记录，标注旧结论已过时 |
| 否（复现已知结论） | — | 无需写 memory，告知用户 |
| 纯调研、无决策 | — | 视内容决定：若有可复用的技术细节则写知识库 |

### 4. 执行更新

直接更新文件，**不要等用户确认**（用户的意图就是让 Claude 自动做这件事）。
更新后列出修改了哪些文件、改了什么。

若改动较多（超过 3 个文件），先列出清单让用户确认再写。

## 注意

- MEMORY.md 超过 200 行时把细节移入子文件，只留摘要行
- 知识库章节号从现有最大章节号 +1 递增
- 不写代码细节进 memory（代码在仓库里，memory 只写结论和规律）
- 不写临时路径、临时文件名进 memory
- 任务文件本身不修改（保持完成区原样）
