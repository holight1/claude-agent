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
declare -A STATUS_OF
declare -A SUPERSEDED_BY
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

  # 日期行必须与文件名里的日期一致，且必须是真实存在的日历日
  # 🔴 判别式：**日期必须能被日期库解析，且往返回来与原串逐字相等。**
  # 只校验外形（`^[0-9]{4}-[0-9]{2}-[0-9]{2}$`）挡不住 2026-99-99 / 2026-02-30。
  # 这是同一个对象（日期字段）第二次失效——第一次是正则 `[0-9-]*` 匹配空串，
  # 修到了形状层就停了。按 skills/gate-design-and-negative-testing §2 不再补特例
  # 枚举（不去列「月不得 >12」「2 月不得 >29」…），改用往返相等这条判别式：
  # 它对任意日期串都能回答，且自动覆盖闰年。外部 review 抓出（P2）。
  fn_date="${name%%-*}-$(echo "$name" | cut -d- -f2)-$(echo "$name" | cut -d- -f3)"
  doc_date="$(sed -n 's/^\*\*日期\*\*：[[:space:]]*\(.*\)$/\1/p' "$f" | head -1 | sed 's/[[:space:]]*$//')"
  if [ -z "$doc_date" ]; then
    fail "$name: 缺 '**日期**：' 行或其值为空"
  elif ! printf '%s' "$doc_date" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
    fail "$name: 日期 '$doc_date' 不是 YYYY-MM-DD"
  elif [ "$(date -d "$doc_date" +%Y-%m-%d 2>/dev/null || true)" != "$doc_date" ]; then
    fail "$name: 日期 '$doc_date' 外形合法但不是真实日历日（date -d 往返不相等）"
  elif [ "$(date -d "$fn_date" +%Y-%m-%d 2>/dev/null || true)" != "$fn_date" ]; then
    fail "$name: 文件名日期 '$fn_date' 不是真实日历日"
  elif [ "$doc_date" != "$fn_date" ]; then
    fail "$name: 日期行 '$doc_date' 与文件名日期 '$fn_date' 不一致"
  fi

  STATUS_OF["$name"]="$st"
  # 已取代必须写明去向，且目标可达、非自指
  if [ "$st" = "已取代" ]; then
    tgt="$(sed -n 's/.*被 `\([^`]*\)` 取代.*/\1/p' "$f" | head -1)"
    if [ -z "$tgt" ]; then
      fail "$name: 状态为已取代，但正文没有「被 \`<文件名>\` 取代」"
    elif [ "$tgt" = "$name" ]; then
      fail "$name: 声称被自己取代"
    elif [ ! -f "$DEC/$tgt" ] && [ ! -f "$DEC/archive/$tgt" ]; then
      fail "$name: 声称被 '$tgt' 取代，但该文件不存在"
    else
      SUPERSEDED_BY["$name"]="$tgt"
    fi
  fi
done

# 归档记录也要进状态表：它们是取代链的合法终点（见 decisions/README.md §归档）
for f in "$DEC"/archive/*.md; do
  [ -f "$f" ] || continue
  a_name="$(basename "$f")"
  [ "$a_name" = "README.md" ] && continue
  STATUS_OF["$a_name"]="已归档"
done

# 取代链：不得成环，终点必须是一条有效的当前记录
for src in "${!SUPERSEDED_BY[@]}"; do
  seen=" $src "; cur="$src"; steps=0
  while [ -n "${SUPERSEDED_BY[$cur]:-}" ]; do
    nxt="${SUPERSEDED_BY[$cur]}"
    case "$seen" in *" $nxt "*) fail "$src: 取代关系成环（… -> $cur -> $nxt）"; cur=""; break ;; esac
    seen="$seen$nxt "; cur="$nxt"; steps=$((steps + 1))
    [ "$steps" -gt 64 ] && { fail "$src: 取代链过长，疑似成环"; cur=""; break; }
  done
  [ -n "$cur" ] || continue
  end_st="${STATUS_OF[$cur]:-}"
  case "$end_st" in
    现行|已归档) ;;
    "") fail "$src: 取代链终点 '$cur' 不在本目录（可能已归档到 archive/，请核对）" ;;
    *)  fail "$src: 取代链终点 '$cur' 状态是 '$end_st'，应落到「现行」或「已归档」" ;;
  esac
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
#
# 🔴 成员资格判别式（不是白名单）：**反引号内的 token，剥掉定位后缀后，只要以 `~` 开头
# 或含 `/`，就进入本集合。** 进集合后**要么被核，要么落进可被 --verbose 列出的「跳过」**，
# 不存在第三种下场——**任何 token 都不得在进入集合之前被丢弃**。
#   - 定位后缀 = `:行号`（`foo.py:34`、`foo.py:10-20`）或 ` §章节`（`../USAGE.md §2`）。
#     它们是合法引用形态，剥掉后解析，不是排除理由。
#   - 绝对路径要求**至少两段**（`/a/b`）。斜杠命令（`/rt`）与单段绝对路径（`/tmp`）
#     因此落进跳过项 —— **是被列出，不是被静默丢弃**，抽查时看得见。
# 由来：此前用 `\.(md|sh|py|...)$` 做入集条件，把扩展名锚在词尾，于是 `foo.py:34`
# 这种带行号的引用**既不被核、也不进跳过计数**——整条静默消失，--verbose 也看不见。
# 那是本仓引用集合第二次悄悄缩小（第一次是 glob），按
# skills/gate-design-and-negative-testing §2 禁止再用「扩大覆盖」修法（补一个 `:[0-9]+`），
# 必须改成判别式。
# ⚠️ 第一版判别式（`^~/|.+/`）仍把 `/rt` 挡在集合外、既不核也不列，与本注释声称的
# 性质不符 —— 由本轮负测试 3 抓出（`gate-design-and-negative-testing §7`：
# 声称的性质必须有会失败的输入去验）。现改为「进集合后必有下场」。
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
      /*/*)    n_ext_or_in=1; abs="$ref" ;;
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
  done <<< "$(grep -oE '`[^`]+`' "$f" | tr -d '`' \
              | sed -E 's/:[0-9]+(-[0-9]+)?$//; s/ +§.*$//' \
              | grep -E '^~|/')"
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
