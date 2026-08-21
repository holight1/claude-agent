#!/usr/bin/env bash
# check-framework.sh — 框架仓的总门禁。
#
#   scripts/check-framework.sh            校验 + 投影 skill
#   scripts/check-framework.sh --check    只校验，不动客户端目录
#
# 三件事：skill 规范源与启用池、决策记录、工作树守卫。
# 工作树守卫的理由见 decisions/2026-08-21-framework-repo-shared-by-sessions.md
# ——本仓被多个架构师会话共写，未提交状态会被下一个会话误扫或误删。

set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
rc=0

bash "$ROOT/scripts/sync-skills.sh" "${1:---check}" || rc=1
echo
bash "$ROOT/scripts/check-decisions.sh" || rc=1
echo

echo "== 工作树守卫 =="
dirty="$(git -C "$ROOT" status --short 2>/dev/null)"
if [ -z "$dirty" ]; then
  echo "  工作树干净"
else
  n="$(printf '%s\n' "$dirty" | wc -l)"
  echo "  [FAIL] 工作树有 $n 处未提交改动 —— 框架仓由多会话共写，不留未提交状态"
  printf '%s\n' "$dirty" | sed 's/^/         /'
  echo "         改完当轮 commit（不 push），message 首行标明来源工作区。"
  echo "         代其他会话装箱时，必须写明改动非本会话所作、原始理由在哪里。"
  rc=1
fi

echo
[ "$rc" -eq 0 ] && echo "== 框架门禁：通过 ==" || echo "== 框架门禁：不通过 =="
exit "$rc"
