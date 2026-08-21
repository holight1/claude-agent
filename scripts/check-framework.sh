#!/usr/bin/env bash
# check-framework.sh — 框架仓的总门禁。
#
#   scripts/check-framework.sh --check      只校验，不投影；工作树状态只提示
#   scripts/check-framework.sh              校验 + 投影 skill；工作树状态只提示
#   scripts/check-framework.sh --handoff    校验 + 投影；**工作树必须干净**，否则失败
#
# 为什么分三档：改动进行中随时可跑 --check 或默认档；工作树守卫只在 --handoff
# 生效，否则任何待提交改动都会让门禁必然失败，它就没法在提交前用。
# 守卫的理由见 decisions/2026-08-21-framework-repo-shared-by-sessions.md
# ——本仓被多个架构师会话共写，未提交状态会被下一个会话误扫或误删。

set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

MODE="sync"        # sync | check | handoff
case "${1:-}" in
  "")         MODE="sync" ;;
  --check)    MODE="check" ;;
  --handoff)  MODE="handoff" ;;
  *) echo "用法：$(basename "$0") [--check|--handoff]" >&2
     echo "未知参数：$1" >&2
     exit 2 ;;
esac

rc=0
[ "$MODE" = "check" ] && SYNC_ARG="--check" || SYNC_ARG=""
bash "$ROOT/scripts/sync-skills.sh" $SYNC_ARG || rc=1
echo
bash "$ROOT/scripts/check-decisions.sh" || rc=1
echo

echo "== 共享块投影 =="
if [ "$MODE" = "check" ]; then
  python3 "$ROOT/scripts/render-shared.py" --check || rc=1
else
  python3 "$ROOT/scripts/render-shared.py" || rc=1
fi
echo

echo "== 工作树 =="
dirty="$(git -C "$ROOT" status --short 2>/dev/null)"
if [ -z "$dirty" ]; then
  echo "  干净"
else
  n="$(printf '%s\n' "$dirty" | wc -l)"
  printf '%s\n' "$dirty" | sed 's/^/         /'
  if [ "$MODE" = "handoff" ]; then
    echo "  [FAIL] $n 处未提交改动 —— 框架仓由多会话共写，交接前不留未提交状态"
    echo "         改完当轮 commit（不 push），message 首行标明来源工作区。"
    echo "         代其他会话装箱时，必须写明改动非本会话所作、原始理由在哪里。"
    rc=1
  else
    echo "  $n 处未提交改动（本档只提示；收尾请跑 --handoff）"
  fi
fi

echo
[ "$rc" -eq 0 ] && echo "== 框架门禁（$MODE）：通过 ==" || echo "== 框架门禁（$MODE）：不通过 =="
exit "$rc"
