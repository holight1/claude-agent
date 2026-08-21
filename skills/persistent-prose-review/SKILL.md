---
name: persistent-prose-review
description: Use when writing or reviewing persistent prose — Markdown, doc comments, prompts, diagnostics, and user-visible strings — applying the test of whether a reader at HEAD can parse and verify each proposition without the authoring session.
---

# 持久散文审查

**状态**：stub
**消费者**：架构师 + 执行端
**来源**：dsh `dsh-prose-standard` + `dsh-trim-cot-leakage`（初期合并）
**触发条件**：写或审持久 Markdown、注释、prompt、诊断与可见字符串
**核心判断**：只读 HEAD 的读者，能不能独立解析并核验这句话？

## 合并说明

初期合并 dsh 的 prose standard 与 CoT leakage 两个 skill，**避免过早拆分**。当召回规则或样例库明显膨胀时再分开。

## 待补内容

正文未写。已知必须覆盖的：

- 编辑前**枚举完整命题**，再分类 keep / add / trim / restore
- 删除会话视角、review 对话复述、控制流复述；保留真正的约定与抑制理由
- 推理转录泄漏的判定测试
- 用词精确性：写 `response fields` / `JSON validation` 而不是 `response shape` / `validation boundary`
- 保留行为者、条件、时序、情态、否定保证与例外

见 `../README.md §补写一个 skill`。
