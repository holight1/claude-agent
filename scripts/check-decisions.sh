#!/usr/bin/env bash
# check-decisions.sh — 校验 decisions/ 的格式、状态闭集与取代关系。
#
# 纪律：打印实际处理了多少个单元。0 个单元不得返回成功。
# archive/ 下的记录已冻结，免除本门禁（见 decisions/README.md §归档）。

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEC="$ROOT/decisions"
STATUSES="现行 已取代 已否决 已归档"
SECTIONS="## 决定|## 为什么|## 备选方案|## 验收证据"

errors=0
fail() { printf '  [FAIL] %s\n' "$1"; errors=$((errors + 1)); }
VERBOSE=0
[ "${1:-}" = "--verbose" ] && VERBOSE=1
skipped=""

echo "== 校验决策记录 $DEC =="
n=0
for f in "$DEC"/*.md; do
  [ -f "$f" ] || continue
  name="$(basename "$f")"
  [ "$name" = "README.md" ] && continue
  n=$((n + 1))

  case "$name" in
    [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-*.md) ;;
    *) fail "$name: 文件名不是 YYYY-MM-DD-<topic>.md" ;;
  esac

  st="$(sed -n 's/^\*\*状态\*\*：\([^ ]*\).*/\1/p' "$f" | head -1)"
  if [ -z "$st" ]; then
    fail "$name: 缺 '**状态**：<x>' 行"
  elif ! printf '%s' " $STATUSES " | grep -q " $st "; then
    fail "$name: 状态 '$st' 不在闭集 [$STATUSES] 内"
  fi

  grep -q '^\*\*日期\*\*：' "$f" || fail "$name: 缺 '**日期**：' 行"
  grep -q '^\*\*触发\*\*：' "$f" || fail "$name: 缺 '**触发**：' 行"
  grep -q '^\*\*作用面\*\*：' "$f" || fail "$name: 缺 '**作用面**：' 行"

  for sec in 决定 为什么 备选方案 验收证据; do
    grep -q "^## $sec" "$f" || fail "$name: 缺 '## $sec' 小节"
  done

  # 备选方案不得为空：要么有内容，要么显式写「无备选：<理由>」
  body="$(sed -n '/^## 备选方案/,/^## /p' "$f" | sed '1d;$d' | tr -d '[:space:]')"
  if [ -z "$body" ]; then
    fail "$name: '## 备选方案' 为空。没有真实备选就写「无备选：<理由>」，不要留白也不要编造"
  fi

  # 已取代必须写明去向，且目标可达
  if [ "$st" = "已取代" ]; then
    tgt="$(sed -n 's/.*被 `\([^`]*\)` 取代.*/\1/p' "$f" | head -1)"
    if [ -z "$tgt" ]; then
      fail "$name: 状态为已取代，但正文没有「被 \`<文件名>\` 取代」"
    elif [ ! -f "$DEC/$tgt" ] && [ ! -f "$DEC/archive/$tgt" ]; then
      fail "$name: 声称被 '$tgt' 取代，但该文件不存在"
    fi
  fi
done

if [ "$n" -eq 0 ]; then
  echo "  [FAIL] decisions/ 下 0 条记录 —— 校验没有作用对象，结果无效"
  exit 1
fi

n_arch=0
for f in "$DEC"/archive/*.md; do [ -f "$f" ] && n_arch=$((n_arch + 1)); done

echo "  校验了 $n 条记录（另有 $n_arch 条已归档，免除本门禁）"
for s in $STATUSES; do
  c="$(grep -l "^\*\*状态\*\*：$s" "$DEC"/*.md 2>/dev/null | grep -v '/README\.md$' | wc -l)"
  printf '    %-6s %d\n' "$s" "$c"
done

# ---------- 证据链：被引用的路径必须可达 ----------
# 仓内引用断了 = 硬失败（我们控制得了）；仓外引用断了 = 警告（别的仓可能改名或删除）。
echo "== 证据链可达性 =="
SCAN=$(ls "$DEC"/*.md "$ROOT"/skills/*/SKILL.md "$ROOT"/skills/README.md \
         "$ROOT"/collab-framework/*.md "$ROOT"/README.md "$ROOT"/USAGE.md 2>/dev/null)
n_in=0; n_ext=0; n_skip=0; warn=0
for f in $SCAN; do
  while IFS= read -r ref; do
    [ -n "$ref" ] || continue
    case "$ref" in *'<'*|*'>'*) n_skip=$((n_skip + 1)); skipped="$skipped$ref
"; continue ;; esac  # 模板占位符
    # 含 glob 的引用：退到第一个 * 之前的目录检查，不整条放过
    case "$ref" in *'*'*) ref="${ref%%\**}"; ref="${ref%/}" ;; esac
    case "$ref" in
      "~/"*)   n_ext_or_in=1; abs="$HOME/${ref#\~/}" ;;
      "/"*)    n_ext_or_in=1; abs="$ref" ;;
      skills/*|decisions/*|scripts/*|collab-framework/*|memory-template/*|enabled/*)
               abs="$ROOT/$ref" ;;
      ../*)    abs="$(dirname "$f")/$ref" ;;
      *)       n_skip=$((n_skip + 1)); skipped="$skipped$ref
"; continue ;;
    esac
    case "$abs" in
      "$ROOT"/*) n_in=$((n_in + 1))
                 [ -e "$abs" ] || fail "$(basename "$f") 引用了不存在的仓内路径：$ref" ;;
      *)         n_ext=$((n_ext + 1))
                 if [ ! -e "$abs" ]; then
                   printf '  [WARN] %s 引用的仓外路径不可达：%s\n' "$(basename "$f")" "$ref"
                   warn=$((warn + 1))
                 fi ;;
    esac
  done <<< "$(grep -oE '`[^`]+`' "$f" | tr -d '`' | grep -E '(/|^~)' | grep -E '\.(md|sh|py|yaml|yml|json|jsonc)$|/$')"
done
echo "  核了 $n_in 条仓内引用、$n_ext 条仓外引用；跳过 $n_skip 个（模板占位符或非路径 token）；$warn 条仓外不可达"
# 本检查自身也是「规则 + 作用集合」。集合缩小是最容易发生且最不可见的失效，
# 所以跳过项必须可被列出抽查，不能只报数量。判据见
# decisions/2026-08-21-adopt-sim-process-notes.md（采纳 sim process-note 0004）。
if [ "$VERBOSE" -eq 1 ] && [ -n "$skipped" ]; then
  echo "  被跳过的 token（--verbose）："
  printf '%s' "$skipped" | sort -u | sed 's/^/    /'
fi

echo "== 结果：$n 条记录 / $errors 处错误 =="
[ "$errors" -eq 0 ] || exit 1
