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
case "${1:-}" in
  "")       ;;
  --check)  CHECK_ONLY=1 ;;
  *) echo "用法：$(basename "$0") [--check]" >&2
     echo "未知参数：$1（参数是闭集，不静默落进写模式）" >&2
     exit 2 ;;
esac

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

  # 消费者 / 投影：闭集，dropped 免除
  if [ "$st" != "dropped" ]; then
    cons="$(sed -n 's/^\*\*消费者\*\*：\(.*\)$/\1/p' "$f" | head -1)"
    proj="$(sed -n 's/^\*\*投影\*\*：\(.*\)$/\1/p' "$f" | head -1)"
    case "$cons" in
      架构师|共享) ;;
      "") fail "$name: 缺 '**消费者**：架构师|共享' 行" ;;
      *)  fail "$name: 消费者 '$cons' 不在闭集 [架构师 共享] 内" ;;
    esac
    [ -n "$proj" ] || fail "$name: 缺 '**投影**：无|<目标文件>' 行"
    if [ "$cons" = "共享" ]; then
      [ "$proj" = "无" ] && fail "$name: 消费者为共享，投影不得为「无」"
      if grep -q '^## 跨角色必读' "$f"; then
        # 跨角色必读要短：它进的是执行端每轮必读的文件
        n_cross="$(sed -n '/^## 跨角色必读/,/^---$/p' "$f" | wc -l)"
        [ "$n_cross" -le 45 ] || fail "$name: §跨角色必读 $n_cross 行，超过 45 行上限（它进执行端每轮必读的文件，只放真正跨角色的那部分）"
      else
        fail "$name: 消费者为共享，但缺 '## 跨角色必读' 一节"
      fi
    else
      [ "$proj" = "无" ] || fail "$name: 消费者为架构师，投影应为「无」（当前 '$proj'）"
      grep -q '^## 跨角色必读' "$f" && fail "$name: 消费者为架构师，不该有 '## 跨角色必读'"
    fi
  fi

  # ---------- 具体案例不得进 SKILL.md 正文 ----------
  # 🔴 判别式（不是词黑名单）：**skill 正文里的数字只能是判据的参数，不得是无出处的实测值。**
  # 实测值有两个机械可判的特征：科学计数法，以及四位及以上的裸数字字面量。
  # 框架级判据的参数（行数上限、第几次、闭集大小）都是小整数，不需要这两种形态。
  #
  # 分档按**上下文成本**，不按喜好：
  #   - `## 跨角色必读` 零容忍 —— 它投影进每个项目执行端**每轮必读**的文件；
  #   - 正文其余部分：科学计数法一律禁；四位以上数字**只允许出现在带出处的行上**
  #     （行内含 `decisions/`、`process-note`、`~/` 或 `.md`）。引用编号不是实测值，
  #     而无出处的实测值就是本条要挡的东西。
  #
  # 为什么必须挡：skill 是**用户级**载体，每个仓都加载。某个受管项目的实测值写在这里
  # = 别的仓永久付出上下文成本 + 命中「跨仓错位」这一类诱人错误。
  # 对照 dsh：它的 skill 在 `.agents/skills/`（**项目级**），永远不会在别的仓被读到，
  # 所以写满本仓命令与阈值是对的；而它三个 skill 里的事故叙事是 **0 处**，
  # 事故证据全在 Agent Notes 的 `## Problem`。
  # 详见 decisions/2026-08-21-skill-carries-criteria-not-cases.md
  if [ "$st" != "dropped" ]; then
    sci="$(grep -nE '[0-9]\.?[0-9]*e[+-]?[0-9]+' "$f" | head -3 | cut -c1-60 | tr '\n' ' ' || true)"
    [ -z "$sci" ] || fail "$name: SKILL.md 出现科学计数法（$sci）——实测值的特征，案例数字放 evals/ 或 decisions/，正文只留判据"

    big="$(grep -nE '(^|[^0-9A-Za-z_.-])[0-9]{4,}([^0-9A-Za-z_%-]|$)' "$f" \
           | grep -vE 'decisions/|process-note|~/|\.md' | head -3 | cut -c1-60 | tr '\n' ' ' || true)"
    [ -z "$big" ] || fail "$name: SKILL.md 有四位以上数字且该行无出处（$big）——判据的参数是小整数，无出处的大数值多为某仓实测值"

    if grep -q '^## 跨角色必读' "$f"; then
      cross="$(sed -n '/^## 跨角色必读/,/^---$/p' "$f" \
               | grep -nE '[0-9]\.?[0-9]*e[+-]?[0-9]+|(^|[^0-9A-Za-z_.-])[0-9]{4,}([^0-9A-Za-z_%-]|$)' \
               | head -3 | cut -c1-60 | tr '\n' ' ' || true)"
      [ -z "$cross" ] || fail "$name: §跨角色必读 出现实测值形态的数字（$cross）——该节投影进每个项目每轮必读的文件，零容忍"
    fi
  fi

  # enabled 必须有 evals/EVALS.md，且「判据：§…」指向 SKILL.md 里真实存在的小节
  if [ "$st" = "enabled" ]; then
    ev="$d/evals/EVALS.md"
    if [ ! -f "$ev" ]; then
      fail "$name: 状态 enabled 但缺 evals/EVALS.md（见 skills/README.md §Eval 约定）"
    else
      # 判据来源：正文不留实证，那实证必须有个家。这条是「案例外置」的另一半——
      # 只挡不许写、不给它去处，结果是判据失去可辩论的依据。
      grep -q '^## 判据来源' "$f" || \
        fail "$name: 状态 enabled 但缺 '## 判据来源' 一节（正文不放案例，实证必须指向 decisions/ 与 evals/）"
      grep -A20 '^## 判据来源' "$f" | grep -q 'decisions/' || \
        fail "$name: §判据来源 里没有任何 decisions/ 引用——判据的由来无处可查"
      for sec in 正触发 负触发 诱人错误; do
        grep -q "^## $sec" "$ev" || fail "$name: EVALS.md 缺 '## $sec' 小节"
      done
      # 🔴 数据行判别式：一条**有效**数据行 = 去掉表头行、分隔行后，**每一格都非空**。
      # 只数表格行是不够的：`| | |` 是一行合法 markdown、能过计数，却什么用例也没描述。
      # 由来：本仓 eval 门禁第二次在同一个对象上失效（第一次是「只查小节标题、
      # 不查每行是否绑定判据」），外部 review 抓出（P2）。按
      # skills/gate-design-and-negative-testing §2，这里给判别式而不是再补一种特例：
      # 判据是「格内有无实质内容」，对任意新表格都能回答。
      # 正/负触发至少各一条**有效**数据行
      for sec in 正触发 负触发; do
        n_row=0; n_empty=0
        while IFS= read -r row; do
          case "$row" in
            '|---'*|'| ---'*|'|--'*) continue ;;
            '| 场景 '*|'|场景'*) continue ;;
          esac
          n_row=$((n_row + 1))
          # 去掉首尾竖线后按 | 拆格，任一格无非空白字符即为空行
          cells="$(printf '%s' "$row" | sed 's/^|//; s/|$//')"
          if printf '%s' "$cells" | awk -F'|' '{for(i=1;i<=NF;i++){g=$i; gsub(/[[:space:]]/,"",g); if(g=="") exit 1}}'; then :; else
            n_empty=$((n_empty + 1))
          fi
        done <<< "$(sed -n "/^## $sec/,/^## /p" "$ev" | grep '^|' || true)"
        [ "$n_row" -ge 1 ] || fail "$name: EVALS.md §$sec 没有数据行"
        [ "$n_empty" -eq 0 ] || fail "$name: EVALS.md §$sec 有 $n_empty/$n_row 条数据行存在空格子——空行能过计数但没描述任何用例"
      done
      # 诱人错误：每条数据行都必须绑定判据，且不得有空格子
      n_row=0; n_bad=0; n_empty=0
      while IFS= read -r row; do
        case "$row" in
          '|---'*|'| ---'*|'|--'*) continue ;;
          '| 场景 '*|'|场景'*) continue ;;
        esac
        n_row=$((n_row + 1))
        case "$row" in *'判据：§'*) ;; *) n_bad=$((n_bad + 1)) ;; esac
        cells="$(printf '%s' "$row" | sed 's/^|//; s/|$//')"
        if printf '%s' "$cells" | awk -F'|' '{for(i=1;i<=NF;i++){g=$i; gsub(/[[:space:]]/,"",g); if(g=="") exit 1}}'; then :; else
          n_empty=$((n_empty + 1))
        fi
      done <<< "$(sed -n '/^## 诱人错误/,/^## /p' "$ev" | grep '^|')"
      [ "$n_row" -ge 1 ] || fail "$name: EVALS.md §诱人错误 没有数据行"
      [ "$n_bad" -eq 0 ] || fail "$name: EVALS.md §诱人错误 有 $n_bad/$n_row 条缺「判据：§」——决策要求每条都绑定"
      [ "$n_empty" -eq 0 ] || fail "$name: EVALS.md §诱人错误 有 $n_empty/$n_row 条数据行存在空格子"
      while IFS= read -r frag; do
        [ -n "$frag" ] || continue
        grep -qE "^#{1,4} .*$(printf '%s' "$frag" | sed 's/[][\.*^$/]/\\&/g')" "$f" || \
          fail "$name: EVALS.md 的「判据：§$frag」在 SKILL.md 里找不到对应小节标题"
      done <<< "$(sed -n 's/.*判据：§\([^|]*\).*/\1/p' "$ev" | sed 's/[[:space:]]*$//')"
    fi
  fi

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
      want="$SRC/$nm"; link="$CODEX_DIR/$nm"
      if [ -L "$link" ]; then
        cur="$(readlink "$link")"
        if [ "$cur" = "$want" ]; then
          :
        elif case "$cur" in "$SRC"/*) true ;; *) false ;; esac; then
          rm "$link" && ln -s "$want" "$link" || { fail "Codex: 无法修正 $nm 的链接"; continue; }
          echo "  Codex: 修正 $nm（原指向 $cur）"
        else
          fail "Codex: $link 是指向本仓之外的链接（$cur），不覆盖，请人工处理"
          continue
        fi
      elif [ -e "$link" ]; then
        fail "Codex: $link 已存在且不是符号链接，不覆盖，请人工处理"
        continue
      else
        ln -s "$want" "$link" || { fail "Codex: 创建 $nm 链接失败"; continue; }
      fi
      # 建完必须复核实际指向，不能因为命令没报错就算数
      [ "$(readlink "$link" 2>/dev/null)" = "$want" ] || { fail "Codex: $nm 链接未指向 $want"; continue; }
      n_codex=$((n_codex + 1))
    done
    if [ "$n_codex" -eq "${#enabled_names[@]}" ]; then
      echo "  Codex: $n_codex 个链接已复核指向，位于 $CODEX_DIR"
    else
      echo "  Codex: 仅 $n_codex/${#enabled_names[@]} 个链接可用（见上方 FAIL）"
    fi
  else
    echo "  Codex: $CODEX_DIR 不存在，跳过"
  fi
fi

# opencode：配置项指绝对路径。本脚本**不改写**含密钥的用户配置，
# 但必须把「没配」变成一条会失败的校验 —— 否则启用池与 opencode 配置
# 各自漂移且无人发现（2026-08-21 sim SIM-001a 终审 C5）。
# opencode：必须解析 JSONC 后核对顶层 skills.paths，不能用字符串搜索——
# 注释掉的配置同样会被 grep 命中，那是把失败报成成功。
if [ ! -f "$OPENCODE_CFG" ]; then
  echo "  opencode: $OPENCODE_CFG 不存在，跳过"
elif ! command -v python3 >/dev/null 2>&1; then
  fail "opencode: 缺 python3，无法解析 JSONC 配置 —— 本项无法校验，不按通过处理"
else
  oc_out="$(python3 "$ROOT/scripts/_opencode_skills_path.py" "$OPENCODE_CFG" "$ENABLED" 2>&1)"
  case "$oc_out" in
    OK*)   echo "  opencode: 顶层 skills.paths 已含 $ENABLED" ;;
    *)     fail "opencode: $oc_out
            请在 $OPENCODE_CFG 顶层加入（本脚本不改写含密钥的用户配置）:
            \"skills\": { \"paths\": [\"$ENABLED\"] }" ;;
  esac
fi
echo "== 结果：$n_src 个规范源 / $n_enabled 个启用 / $errors 处错误 =="
[ "$errors" -eq 0 ] || exit 1
