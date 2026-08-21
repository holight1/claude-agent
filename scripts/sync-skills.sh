#!/usr/bin/env bash
# sync-skills.sh — 校验 skills/ 规范源，并把 enabled/ 投影到各客户端。
#
# 用法：scripts/sync-skills.sh [--check]
#   --check  只校验，不改动任何客户端目录
#
# 纪律：本脚本打印它实际处理了多少个单元。0 个单元不得返回成功。

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT/skills"
ENABLED="$ROOT/enabled"
CHECK_ONLY=0
[ "${1:-}" = "--check" ] && CHECK_ONLY=1

CLAUDE_DIR="$HOME/.claude/skills"
CODEX_DIR="$HOME/.codex/skills"
OPENCODE_CFG="$HOME/.config/opencode/opencode.jsonc"

STATUSES="enabled dormant stub dropped"
# 具体项目命令：skill 正文不得出现（skill 与被约束的仓不同版本，会漂）
LEAK_RE='\b(pnpm|npx|yarn|pytest|tox|vitest|jest|cargo|gradle|mvn)\b|\bnpm run\b|\bmake (test|build|clean|check)\b|\bgo test\b'

errors=0
fail() { printf '  [FAIL] %s\n' "$1"; errors=$((errors + 1)); }

# ---------- 1. 校验规范源 ----------
echo "== 校验规范源 $SRC =="
n_src=0
declare -A STATUS_OF
for d in "$SRC"/*/; do
  [ -d "$d" ] || continue
  name="$(basename "$d")"
  n_src=$((n_src + 1))
  f="$d/SKILL.md"

  if [ ! -f "$f" ]; then fail "$name: 缺少 SKILL.md"; continue; fi

  fm_name="$(sed -n '2,10{/^name:[[:space:]]*/{s///p;q}}' "$f")"
  [ -n "$fm_name" ] || fail "$name: frontmatter 缺 name"
  [ "$fm_name" = "$name" ] || fail "$name: frontmatter name='$fm_name' 与目录名不符"
  grep -qE '^description:[[:space:]]*\S' "$f" || fail "$name: frontmatter 缺 description"

  st="$(sed -n 's/^\*\*状态\*\*：\([a-z]*\).*/\1/p' "$f" | head -1)"
  if [ -z "$st" ]; then
    fail "$name: 正文缺 '**状态**：<x>' 行"
  elif ! printf '%s' " $STATUSES " | grep -q " $st "; then
    fail "$name: 状态 '$st' 不在闭集 [$STATUSES] 内"
  fi
  STATUS_OF["$name"]="$st"

  if hit="$(grep -nEo "$LEAK_RE" "$f" | head -3)"; then
    [ -n "$hit" ] && fail "$name: 正文出现具体项目命令（见 skills/README.md §硬规则）: $(echo "$hit" | tr '\n' ' ')"
  fi
done

if [ "$n_src" -eq 0 ]; then
  echo "  [FAIL] skills/ 下 0 个 skill —— 校验没有作用对象，结果无效"
  exit 1
fi
echo "  校验了 $n_src 个 skill"
for s in $STATUSES; do
  c=0; for k in "${!STATUS_OF[@]}"; do [ "${STATUS_OF[$k]}" = "$s" ] && c=$((c + 1)); done
  printf '    %-8s %d\n' "$s" "$c"
done

# ---------- 2. 校验启用池 ----------
echo "== 校验启用池 $ENABLED =="
n_enabled=0
enabled_names=()
for l in "$ENABLED"/*; do
  [ -e "$l" ] || [ -L "$l" ] || continue
  name="$(basename "$l")"
  n_enabled=$((n_enabled + 1))
  enabled_names+=("$name")
  [ -L "$l" ] || { fail "enabled/$name 不是符号链接"; continue; }
  [ -e "$l" ] || { fail "enabled/$name 是悬空链接"; continue; }
  tgt="$(cd "$(dirname "$l")" && cd "$(readlink "$l")" && pwd)"
  [ "$tgt" = "$SRC/$name" ] || fail "enabled/$name 指向 $tgt，应指向 $SRC/$name"
  [ "${STATUS_OF[$name]:-}" = "enabled" ] || fail "enabled/$name 的状态是 '${STATUS_OF[$name]:-缺失}'，只有 enabled 可入启用池"
done
# 反向：状态 enabled 却不在启用池
for k in "${!STATUS_OF[@]}"; do
  if [ "${STATUS_OF[$k]}" = "enabled" ] && [ ! -L "$ENABLED/$k" ]; then
    fail "$k 状态为 enabled，但 enabled/ 里没有链接"
  fi
done
if [ "$n_enabled" -eq 0 ]; then
  echo "  启用池为空（0 个）—— 若这不是预期，说明投影会是空操作"
else
  echo "  启用了 $n_enabled 个：${enabled_names[*]}"
fi

# ---------- 3. 投影到客户端 ----------
echo "== 客户端投影 =="
if [ "$CHECK_ONLY" -eq 1 ]; then
  echo "  --check：跳过投影"
else
  # Claude Code：整目录符号链接
  if [ -L "$CLAUDE_DIR" ]; then
    cur="$(readlink "$CLAUDE_DIR")"
    [ "$cur" = "$ENABLED" ] || fail "$CLAUDE_DIR 已是链接但指向 $cur"
    echo "  Claude Code: 已就位 ($CLAUDE_DIR -> $ENABLED)"
  elif [ -e "$CLAUDE_DIR" ]; then
    fail "$CLAUDE_DIR 已存在且不是符号链接 —— 不覆盖，请人工处理"
  else
    mkdir -p "$(dirname "$CLAUDE_DIR")" && ln -s "$ENABLED" "$CLAUDE_DIR"
    echo "  Claude Code: 新建链接 $CLAUDE_DIR -> $ENABLED"
  fi

  # Codex：逐个链接（~/.codex/skills 已有 .system/，不能整目录替换）
  n_codex=0
  if [ -d "$CODEX_DIR" ]; then
    for l in "$CODEX_DIR"/*; do
      [ -L "$l" ] || continue
      case "$(readlink "$l")" in "$SRC"/*)
        nm="$(basename "$l")"
        [ -L "$ENABLED/$nm" ] || { rm "$l"; echo "  Codex: 移除已停用 $nm"; } ;;
      esac
    done
    for nm in "${enabled_names[@]:-}"; do
      [ -n "$nm" ] || continue
      [ -L "$CODEX_DIR/$nm" ] || ln -s "$SRC/$nm" "$CODEX_DIR/$nm"
      n_codex=$((n_codex + 1))
    done
    echo "  Codex: $n_codex 个链接就位于 $CODEX_DIR"
  else
    echo "  Codex: $CODEX_DIR 不存在，跳过"
  fi
fi

# opencode：配置项指绝对路径。本脚本**不改写**含密钥的用户配置，
# 但必须把「没配」变成一条会失败的校验 —— 否则启用池与 opencode 配置
# 各自漂移且无人发现（2026-08-21 sim SIM-001a 终审 C5）。
if [ ! -f "$OPENCODE_CFG" ]; then
  echo "  opencode: $OPENCODE_CFG 不存在，跳过"
elif grep -q "$ENABLED" "$OPENCODE_CFG"; then
  echo "  opencode: 配置已指向 $ENABLED"
else
  fail "opencode 配置未指向启用池 —— 请在 $OPENCODE_CFG 顶层加入（本脚本不改写含密钥的用户配置）:
            \"skills\": { \"paths\": [\"$ENABLED\"] }"
fi

echo "== 结果：$n_src 个规范源 / $n_enabled 个启用 / $errors 处错误 =="
[ "$errors" -eq 0 ] || exit 1
