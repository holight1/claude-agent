# Skill 的载体、启用机制与作用域

**状态**：现行
**日期**：2026-08-21
**触发**：框架早期有过一批 skill，后来大部分被删。重新引入前需要先定清楚：装在哪、怎么算启用、休眠的成本是多少。
**作用面**：新增 `skills/`、`enabled/`、`scripts/sync-skills.sh`；`USAGE.md §1.3`。

## 决定

- **规范源**：`skills/<name>/SKILL.md`，唯一可编辑源，客户端中立、项目中立
- **启用池**：`enabled/<name>` 符号链接。**链接在 = 已启用**
- **三客户端都从启用池取**：Claude Code 整目录链接 `~/.claude/skills`；Codex 逐个链接 `~/.codex/skills/<name>`（其 `.system/` 不可覆盖）；opencode 配置项 `skills.paths` 指绝对路径
- 状态闭集 `enabled / dormant / stub / dropped`，写在**正文**不写 frontmatter
- **skill 正文不得出现具体项目命令**，只能指向项目 `DS.md`

## 为什么

**为什么源与启用要分两层**：frontmatter 拦不住加载。只要 skill 在客户端的加载路径上，它的 `description` 每轮都进上下文。两层目录让休眠的上下文成本**真的是零**，也让将来那轮「删除 / 启用 / 继续休眠」评审变成 `diff <(ls skills/) <(ls enabled/)`。

**为什么必须是用户级 / 绝对路径**：架构师会话坐在**仓库之上**，而且不止一个根（`~`、`~/agent`、`~/sim`、`~/modules/base-sw`、Windows 审计路径）。仓内 `.claude/skills/` 不在它的加载路径上。更硬的约束是受管仓里有**上游 clone**，往仓里塞文件本身违规。

**为什么状态不写 frontmatter**：Codex 对 skill frontmatter 有白名单校验（二进制内含 `Unexpected key(s) in SKILL.md frontmatter`），加自定义键有风险。

**为什么禁具体项目命令**：dsh 的 skill 与被它约束的代码同仓同版本，改门禁就改 skill、一次提交。本框架的 skill 在框架仓、被约束对象在别的仓，两边会漂。

## 备选方案

- **照抄 dsh 的仓内 `.agents/skills/` + `.claude/skills` 符号链接**。放弃：dsh 的 agent 在仓内工作，本框架的架构师在仓外，且受管仓含上游 clone。
- **单目录 + frontmatter 开关表达休眠**。放弃：拦不住加载，休眠仍然吃上下文；且 Codex 的 frontmatter 白名单不接受自定义键。
- **让 `sync-skills.sh` 直接改写 opencode 配置**。放弃：那个文件含 API key。改为打印提示，后于同日升级为**会失败的校验**（见 `2026-08-21-project-to-framework-backflow.md`）。

## 验收证据

`scripts/sync-skills.sh` 的 7 条负测试逐条验证会变红：状态不在闭集 / name 与目录名不符 / 正文出现具体项目命令 / 悬空链接 / 非 enabled 混进启用池 / enabled 却不在池中 / 空 `skills/` 退出码 1。

路径解析已实证：`~/.claude/skills -> enabled -> ../skills/<name>` 两跳可读；Codex 侧逐个链接就位；opencode 配置为绝对路径 `/home/suiyan/claude-agent/enabled`。

**未验证**：DS 会话内 skill 是否真被加载并触发（端到端）。这一环至今没有证据。

**已知矛盾（未决）**：`semantic-code-review` 自述消费者是「读各仓 `CODEX.md` 的独立 reviewer」，而 `CODEX-template.md §禁止事项` 写着「收到『请先读取 CODEX.md』时，只读 `CODEX.md`，不读其他 MD 文件」。照模板初始化的新项目里，该 skill **按设计不可达**。sim 的实际做法是把 skill 正文抄进项目 `CODEX.md`，于是同一段判据有了两份手工同步的副本。两条必须改一条，尚未决定改哪条。
