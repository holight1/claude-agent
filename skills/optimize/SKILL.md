---
description: "Optimize context - archive completed tasks, sync knowledge base, reduce context consumption"
allowed-tools: ["Read", "Write", "Glob", "Grep", "Bash", "Edit"]
---

# /optimize - 任务清理（Claude 自己执行）

Claude 直接执行清理，不创建任务文件，不下发给 GPT/Gemini。

## 执行流程

### 步骤 1：列出各仓库任务文件及状态

```bash
ls ~/SuBase-SY/code-agent/tasks/
ls ~/gem5-a4e/code-agent/tasks/
ls ~/a4e_multi_core/code-agent/tasks/
ls ~/llama.cpp-SY/ggml/code-agent/tasks/
ls ~/SuBase-review/code-agent/tasks/
ls ~/code-agent/tasks/
# 根据实际项目调整
```

批量读取状态字段：
```bash
grep -m1 "^\*\*状态\*\*" ~/SuBase-SY/code-agent/tasks/*.md
# 对每个仓库执行
```

### 步骤 2：分类处理

| 状态 | 操作 |
|------|------|
| 已完成 / done / 已作废 | 归档到 `archived/` |
| 作废且无价值 | 直接删除 |
| pending / 待执行 / 执行中 / 暂停 | 保留 |

```bash
# 归档
mv <repo>/code-agent/tasks/<task>.md <repo>/code-agent/tasks/archived/

# 删除（仅作废无价值的）
rm <repo>/code-agent/tasks/<task>.md
```

### 步骤 3：验证

列出各仓库剩余任务文件，确认清理结果正确。

## 注意事项

- Claude 直接用 Bash 执行 mv/rm，不创建中间任务文件
- 归档而非删除（已完成任务），便于回溯
- 不检查知识库覆盖（那是 GPT 的工作），只做文件整理
- 设计文档（`code-agent/designs/`）由用户手动清理，不纳入此任务
