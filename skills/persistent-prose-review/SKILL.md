---
name: persistent-prose-review
description: Use when writing or reviewing persistent prose — Markdown, doc comments, prompts, diagnostics, and user-visible strings — applying the test of whether a reader at HEAD can parse and verify each proposition without access to the authoring session.
---

# 持久散文审查

**状态**：dormant
**消费者**：架构师
**投影**：无
**来源**：dsh `dsh-prose-standard` + `dsh-trim-cot-leakage`（初期合并）
**核心判断**：只读 HEAD 的读者，能不能独立解析并核验这句话？

## 何时用

**触发**：写或审持久 Markdown、文档注释、prompt、诊断信息、用户可见字符串。

**不触发**：一次性的对话回复、任务完成区的现场记录。

## 合并说明

初期合并 dsh 的 prose standard 与 CoT leakage 两个 skill，**避免过早拆分**。当召回规则或样例库明显膨胀时再分开。

## 判断程序

### 1. 编辑前先枚举命题

把这段文字**声称的每一件事**列出来，再逐条分类：

| 分类 | 处理 |
|---|---|
| keep | 仍然成立且必要 |
| add | 缺失的约定、失败模式、安全用法 |
| trim | 会话视角、控制流复述、review 对话残留 |
| restore | 之前被误删、但读者确实需要的 |

不先枚举就直接改，会在删冗余的同时删掉唯一记着某个约束的那句话。

### 2. HEAD 读者测试

> 一个只能看到当前代码和当前文档的人，能不能**独立解析**这句话，并**自己核验**它？

不能 → 要么补上缺的上下文，要么删掉。常见的不能：

- 引用了只存在于当轮对话里的东西（「按上面说的」「如前所述那个方案」）
- 引用了已经不存在的文件、函数或流程
- 结论正确但没写它成立的条件

### 3. 推理转录泄漏

文档陈述**完整的契约与上下文**，不是推理过程。判定测试：

> 这句话是在告诉读者**规则是什么**，还是在告诉读者**我是怎么想到这条规则的**？

后者删。典型形态：「我们先考虑了 A，发现不行，所以…」——属于决策记录的 `## 备选方案`，不属于正文。

**但注意区分**：抑制某条规则的**理由**要留（「这里不加锁，因为调用方已持锁」），那是安全用法信息，不是推理转录。

### 4. 用词精确

写 `contract` / `boundary` / `shape` 之前，先问有没有更准确的词直接命名对象：

- `response shape` → `response fields`
- `validation boundary` → `JSON validation`
- `module shape` → `ESM exports`

`contract` 留给**前置条件、后置条件、不变量、兼容性承诺**这类调用方真正依赖的义务。`boundary` 留给真实的进程、传输、安全、事务或生命周期边界。

不用比喻。

### 5. 保留清单

转述任何来源时，必须原样保留：**行为者、条件、时序、情态（may / 建议 / 预计）、否定保证、例外**。

实证：源文 "a reporter **may** open a model turn synchronously" 被写成「其作业完成通知**会**同步开一个模型 turn」——丢了情态、丢了主语，还把一个正面论据倒过来当成了反例。

拿不准就**给原文，不只给转述**。

### 6. 不要复述代码和测试

「本函数遍历列表并累加」这类句子随实现漂移，且读者看代码更快。要写的是**代码看不出来的**：行为、失败模式、时序、所有权、安全用法。

## 停止条件

- 枚举命题时发现自己在猜作者想说什么 → 去问，或标注「意图不明」，不要替它写一个
- 一段话删到只剩正确但无信息的空话 → 整段删掉
