# DS 协作实例注册表

> 维护原则：新增/停用 DS 实例时同步更新此文件 + MEMORY.md 仓库表。
> 推荐使用 `/project-add` 和 `/project-remove` 自动维护。

## 当前活跃实例

（使用 `/project-add` 添加项目后自动填充）

## dispatch 路由规则

| 执行环境字段 | rsync 目标 | 下发对象 |
|-------------|-----------|---------|
| `本地 DS` | 无需 rsync | 本地 DeepSeek |
| `本地 DS · <仓库名>` | 无需 rsync | 本地 DeepSeek |
| `远端 DS · <仓库名>` | 见各实例"rsync 目标"字段 | 远端 DeepSeek |
| `Gemini` | 无需 rsync | 本地 Gemini（联网） |

## 历史停用实例

| 实例 | 停用时间 | 原因 |
|------|---------|------|
