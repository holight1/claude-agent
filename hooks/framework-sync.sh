#!/usr/bin/env bash
# framework-sync.sh — PostToolUse hook
# 每次 Edit/Write 修改 ~/.claude/skills/ 或 ~/.claude/collab-framework/ 时，
# 自动同步到 ~/claude-agent/ 并显示 git status。

CLAUDE_DIR="$HOME/.claude"
AGENT_REPO="$HOME/claude-agent"

# 从 stdin 读取 hook JSON，提取 file_path
FILE=$(python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    ti = d.get('tool_input', {})
    print(ti.get('file_path', ''))
except Exception:
    print('')
" 2>/dev/null)

[ -z "$FILE" ] && exit 0

# 只处理 ~/.claude/skills/、~/.claude/collab-framework/、~/.claude/roles/ 下的文件
if [[ "$FILE" != "$CLAUDE_DIR/skills/"* ]] && \
   [[ "$FILE" != "$CLAUDE_DIR/collab-framework/"* ]] && \
   [[ "$FILE" != "$CLAUDE_DIR/roles/"* ]]; then
    exit 0
fi

# 确保文件真实存在
[ -f "$FILE" ] || exit 0

# 计算在 claude-agent/ 中的目标路径
REL="${FILE#$CLAUDE_DIR/}"
DEST="$AGENT_REPO/$REL"

# 同步
mkdir -p "$(dirname "$DEST")"
cp "$FILE" "$DEST"

# 输出提示（Claude 会看到 stderr）
echo "[framework-sync] synced: $REL → claude-agent/" >&2
git -C "$AGENT_REPO" status --short >&2
