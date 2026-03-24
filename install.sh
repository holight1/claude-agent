#!/usr/bin/env bash
# install.sh — claude-agent 安装/升级脚本
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

# ── 1. Skills ──────────────────────────────────────────────────────────────
echo "[1/5] Installing skills..."
mkdir -p "${CLAUDE_DIR}/skills"
for skill_dir in "${REPO_DIR}/skills"/*/; do
    skill_name="$(basename "${skill_dir}")"
    mkdir -p "${CLAUDE_DIR}/skills/${skill_name}"
    cp "${skill_dir}"*.md "${CLAUDE_DIR}/skills/${skill_name}/"
    echo "  + ${skill_name}"
done

# ── 2. Agents ──────────────────────────────────────────────────────────────
echo "[2/5] Installing agents..."
mkdir -p "${CLAUDE_DIR}/agents"
agent_count=0
for f in "${REPO_DIR}/agents"/*.md; do
    [ -f "$f" ] || continue
    cp "$f" "${CLAUDE_DIR}/agents/"
    echo "  + $(basename "$f")"
    agent_count=$((agent_count + 1))
done
[ "$agent_count" -eq 0 ] && echo "  (no agents)"

# ── 3. Roles (unified AI config files) ────────────────────────────────────
echo "[3/5] Installing roles..."
mkdir -p "${CLAUDE_DIR}/roles"
for f in "${REPO_DIR}/roles"/*.md; do
    [ -f "$f" ] || continue
    cp "$f" "${CLAUDE_DIR}/roles/"
    echo "  + $(basename "$f")"
done

# ── 4. collab-framework ────────────────────────────────────────────────────
echo "[4/5] Installing collab-framework..."
mkdir -p "${CLAUDE_DIR}/collab-framework"
rsync -a "${REPO_DIR}/collab-framework/" "${CLAUDE_DIR}/collab-framework/"
echo "  + collab-framework"

# ── 5. Global memory (~/  context) ────────────────────────────────────────
echo "[5/5] Global memory (~/  context)..."
if [ ! -d "${MEMORY_DIR}" ]; then
    mkdir -p "${MEMORY_DIR}"
    cp "${REPO_DIR}/memory-template/MEMORY.md"       "${MEMORY_DIR}/MEMORY.md"
    cp "${REPO_DIR}/memory-template/gpt-registry.md" "${MEMORY_DIR}/gpt-registry.md"
    echo "  + Created at ${MEMORY_DIR}"
else
    echo "  ~ Already exists at ${MEMORY_DIR}, skipping"
    echo "    (use /project-add to register new projects)"
fi

echo ""
echo "Installation complete."
echo ""
echo "Next steps:"
echo "  1. cd ~ && claude          # launch in global coordinator mode"
echo "  2. /project-add <path>     # register your first project"
echo "     (copies CHATGPT/GEMINI templates from ~/.claude/collab-framework/)"
