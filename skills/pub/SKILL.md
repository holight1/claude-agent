---
description: "After reviewing and committing UPU source code, update UPU/release and commit it"
allowed-tools: ["Read", "Write", "Edit", "Bash"]
argument-hint: "[runtime|gem5|compiler|all]"
---

# /pub [component] - 更新 UPU release 并提交

在 UPU 某个仓库代码 review 通过、commit 完成之后，将最新产物 install 到 `UPU/release/` 并提交 release 仓库。

## 自动触发时机

在 `/rt` review 通过且 Claude 已完成 git commit 之后，**若改动仓库为 runtime / gem5 / compiler，Claude 自动调用 /pub 对应组件，无需用户确认**。llama-cpp / operators 等不产生 release 产物，不触发 /pub。

## 参数

- `runtime`  — 只更新 libupu-rt.so + 头文件
- `gem5`     — 只更新 gem5.opt（~900MB，慢）
- `compiler` — 只更新 clang/llc/lld
- `all`      — 三者全更新
- 无参数     — 根据当前上下文自动判断（见下）

## 执行步骤

### 1. 确定 component

若用户未指定参数，根据本次对话中 review 的任务文件或 commit 所在仓库自动判断：
- 任务前缀 `R-*` 或仓库 `UPU/runtime` → `runtime`
- 任务前缀 `G-*` 或仓库 `UPU/gem5`    → `gem5`
- 任务前缀 `C-*` 或仓库 `UPU/compiler` → `compiler`
- 不确定时询问用户

### 2. 确认源仓库已 commit

```bash
cd /home/holight/UPU/<repo> && git status
```

若有未提交改动，**停止并提示用户先 commit**，不继续。

### 3. 运行 update.sh

```bash
cd /home/holight/UPU/release
bash update.sh <component>
```

- `runtime` 会执行 `make -C UPU/runtime/UBase/rt install`（约 10-30s）
- `gem5` 会 cp gem5.opt（约 900MB，慢，询问用户是否确认）
- `compiler` 会 cp clang/llc/lld

### 4. 检查 release 变化

```bash
cd /home/holight/UPU/release && git status && git diff VERSION
```

若无变化（产物和上次相同），报告"release 无变化，无需 commit"并退出。

### 5. Commit release 仓库

取源仓库最近一条 commit 的短 hash 和 message：

```bash
git -C /home/holight/UPU/<repo> log -1 --oneline
```

用以下格式 commit release：

```bash
cd /home/holight/UPU/release
git add -A
git commit -m "release: update <component> from <source-short-hash> (<source-commit-title>)"
```

### 6. 输出摘要

报告：
- 更新了哪些文件（lib/libupu-rt.so、include/、VERSION 等）
- release commit hash
- 来源 commit hash

## 注意

- **不自动 push** release 仓库，push 需用户确认
- gem5.opt 体积 ~900MB，拷贝前必须询问用户是否确认
- `make install` 失败（编译错误）时停止，不 commit release
- release 仓库 `.gitignore` 忽略 `bin/`（大二进制），`include/` 和 `lib/` 需 git track
