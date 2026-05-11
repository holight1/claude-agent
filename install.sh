#!/usr/bin/env bash
# install.sh — CC+Codex+DS 协作框架安装脚本
# 用法：bash install.sh
# 幂等：可重复执行，已有 memory 不覆盖

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"
MEMORY_DIR="${CLAUDE_DIR}/projects/-home-$(whoami)/memory"

echo "=== claude-agent installer ==="
echo "Repo  : ${REPO_DIR}"
echo "Claude: ${CLAUDE_DIR}"
echo ""

# ── 1. WORKFLOW.md ────────────────────────────────────────────────────────────
echo "[1/3] Installing WORKFLOW.md..."
cp "${REPO_DIR}/WORKFLOW.md" "${CLAUDE_DIR}/WORKFLOW.md"
echo "  + ~/.claude/WORKFLOW.md"

# 在 ~/.claude/CLAUDE.md 中注册（若不存在则创建，若已有 @WORKFLOW.md 则跳过）
CLAUDE_MD="${CLAUDE_DIR}/CLAUDE.md"
if [ ! -f "${CLAUDE_MD}" ]; then
    echo "@WORKFLOW.md" > "${CLAUDE_MD}"
    echo "  + ~/.claude/CLAUDE.md (created)"
elif ! grep -q "@WORKFLOW.md" "${CLAUDE_MD}"; then
    echo "@WORKFLOW.md" >> "${CLAUDE_MD}"
    echo "  + @WORKFLOW.md appended to ~/.claude/CLAUDE.md"
else
    echo "  ~ ~/.claude/CLAUDE.md already has @WORKFLOW.md"
fi

# ── 2. RTK hook（由 RTK 工具自管理）─────────────────────────────────────────
echo "[2/3] RTK hook..."
if command -v rtk &>/dev/null; then
    rtk init --global 2>/dev/null && echo "  + rtk init --global OK" || echo "  ~ rtk init skipped"
else
    echo "  ! rtk not found — install RTK then run: rtk init --global"
    echo "    https://github.com/anthropics/rtk"
fi

# ── 3. Memory 初始化（新机器）────────────────────────────────────────────────
echo "[3/3] Memory..."
if [ ! -d "${MEMORY_DIR}" ]; then
    mkdir -p "${MEMORY_DIR}"
    cp "${REPO_DIR}/memory-template/MEMORY.md"              "${MEMORY_DIR}/MEMORY.md"
    cp "${REPO_DIR}/memory-template/gpt-registry-template.md" "${MEMORY_DIR}/gpt-registry.md"
    echo "  + Created ${MEMORY_DIR}"
    echo "  ! 记得编辑 gpt-registry.md，填入实际仓库路径和 SSH 地址"
else
    echo "  ~ ${MEMORY_DIR} 已存在，跳过（不覆盖现有 memory）"
fi

echo ""
echo "安装完成。后续步骤："
echo "  1. 把 ~/CLAUDE.md（全局协调者规则）放到此机器上"
echo "  2. 编辑 ${MEMORY_DIR}/gpt-registry.md，填入实际 SSH 地址"
echo "  3. Clone 项目仓库（DS.md 和 code-agent/ 随仓库一起带来）"
echo "  4. cd ~ && claude"
