---
name: semantic-code-review
description: Use when reviewing a code diff or implementation task — pins the exact base and head, reads both sides of each interface, and prioritizes lifecycle, ownership, security, and real-entry-point defects over style.
---

# 语义化代码审查

**状态**：stub
**消费者**：**Codex**（读 `CODEX.md`，不加载 Claude Code skill）+ 架构师
**来源**：dsh `dsh-code-review`
**触发条件**：review 代码 diff 或实现任务
**核心判断**：这个改动在真实入口上跑起来会怎样，而不是在测试里怎样？

## 载体注意

主消费者是 Codex。Codex 的 skill 目录是 `~/.codex/skills/`，格式与 Claude Code 相同（`SKILL.md` + `name` / `description` frontmatter，且 frontmatter 有白名单校验），但触发形态偏**显式调用**。

若启用，本 skill 需要额外提供 Codex 侧接口描述：

```
semantic-code-review/agents/openai.yaml
  interface:
    display_name / short_description / default_prompt
```

形态照抄 dsh 的 `.agents/skills/*/agents/openai.yaml`（与 Codex 自带 `.system/review-agent/agents/openai.yaml` 同构）。

## 待补内容

正文未写。已知必须覆盖的：

- 锁定精确 base / head；retarget 或 merge 之后重新确立并重跑
- 读周边代码和接口**两端**，不只读 diff
- 检查生命周期、所有权、安全、模型可见面、真实入口、绕过路径、测试强度、文档同步
- 按严重度排列；**建议与阻断分开**；一条有实据的阻断胜过一串 nit
- 区分「我核对到不对」与「我认为不对」

见 `../README.md §补写一个 skill`。
