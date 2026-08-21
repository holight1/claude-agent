---
name: research-evidence-audit
description: Use when a research, source-reading, knowledge-extraction, or fact-reporting task returns — audits coverage, paths, verbatim quotes, counting basis, and confidence, and catches modality inflation, double counting, and stitched citations.
---

# 研究证据审计

**状态**：stub
**消费者**：架构师（CC）
**来源**：本框架抽取记录的 Codex review 阻断项（7 处引文 / 情态 / 泛化 / 出处 / 人数推断）
**触发条件**：调研、源码解读、知识抽取或事实报告返回
**核心判断**：这条引文，原文里真的连着这么一句吗？

## 待补内容

正文未写。已知必须覆盖的（每条都对应一次真实事故）：

- **情态失真**：`may` 被写成「会」；设计意图被写成既成行为；他方文档自带的限定（区间估算 / 非实测 / 产品目标）被丢掉
- **引文缝合**：非连续原文不得缝成一条连续引文（曾把 §Archiving 的主语和 §Layout 的谓语拼在一起）
- **计数口径**：中英文译文双计（1446 → 723）；每个数字附产生它的命令
- **校验对象偷换**：脚本的正则只匹配列表格式，而被校验的文件是表格 → 实际处理 0 条，却报告「40/40 逐字命中」
- **口述数字当事实**：「3 人开发几个月」vs `git log --format=%an | sort -u` = 43
- **设计 ≠ 效果**：没有反事实或运行证据时不宣称制度有效
- 报告分开写：「我核对到不对」/「我认为不合适」/「我无法自我验证」

见 `../README.md §补写一个 skill`。
