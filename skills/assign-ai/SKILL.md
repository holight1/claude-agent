---
description: "Route tasks to the right AI - Gemini (unlimited, simple first) or GPT 5.3 (stronger, complex tasks)"
allowed-tools: ["Read", "Glob"]
argument-hint: "<task-id or task description>"
---

# /assign-ai - 路由到合适的 AI

根据任务类型决定发给 **Gemini** 还是 **GPT 5.3**。

## 路由规则

| → GPT 5.3（更强，省着用） | → Gemini（无限量） |
|--------------------------|------------------|
| 实现/修复/重构（impl/fix/refactor） | 调研/搜索/recon |
| 多文件改动 | 构建/运行/测试执行 |
| 调试排错 | 单文件只读或结构化输出 |
| 算法实现 & 结果验证 | 知识库整理/changelog |
| 复杂配置脚本修改 | smoke test / 回归测试 |

**默认原则**：调研 → Gemini；实现/调试 → GPT 5.3；有疑问时任务简单选 Gemini，任务复杂选 GPT 5.3。

## 执行步骤

### 1. 解析输入

- 若输入是 task-id（如 `035a`），读取 `code-agent/tasks/<task-id>*.md` 获取任务描述
- 若输入是自然语言描述，直接分析

### 2. 分析任务类型

根据任务描述中的关键词判断：

- **偏 GPT 5.3**：implement、fix、refactor、debug、rewrite、multi-file、algorithm
- **偏 Gemini**：research、investigate、survey、read、analyze、summarize、list、test-run

### 3. 输出建议

```
**AI 建议：[Gemini / GPT 5.3]**
理由：<一句话说明原因>

下一步：使用 `/dispatch <task-id>` 下发（dispatch skill 会按此路由执行）
```

## 注意

- 此 skill 只给出建议，不实际下发任务；下发用 `/dispatch`
- 若任务文件中已有 `**AI**` 字段，以任务文件为准
