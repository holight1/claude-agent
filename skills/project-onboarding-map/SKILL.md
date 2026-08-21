---
name: project-onboarding-map
description: Use when initializing a newly managed repository — identifies authoritative docs, build and test entry points, extension points, persisted data, model-visible surfaces, and high-risk lifecycles, producing the initial project adapter and knowledge index.
---

# 新项目摸底建图

**状态**：stub
**消费者**：架构师（CC）
**来源**：dsh 的仓库自述结构 + 本框架 DSH-001a 调研任务
**触发条件**：新项目纳管时；平时休眠
**核心判断**：这个仓的权威源在哪、写入边界在哪？

## 待补内容

正文未写。已知必须覆盖的：

- 识别权威文档、构建 / 测试入口、扩展点、持久数据、模型可见面、文档树、高风险生命周期
- **判定并记录该仓的写入策略**：自有仓 / 上游 clone（不可污染）/ 只读镜像
- 产出项目 `DS.md` 与知识库索引的初始材料
- 工具链未就绪时**只下只读任务**，产出一律标注「未验证」，禁止出现「实测 / PASS / 跑通」字样

见 `../README.md §补写一个 skill`。
