#!/usr/bin/env python3
"""把「共享」skill 的 `## 跨角色必读` 渲染进投影目标的标记块。

为什么要生成而不是手抄：执行端与 reviewer 不通过 skill 机制获取判断程序
（opencode 日志实测 permission=skill 为 0），唯一有效载体是它们必读的文件。
手抄会产生第二个可编辑源——本仓已因此让同一段判据散在 3–5 处并开始不一致。

用法：
    render-shared.py            写入（幂等）
    render-shared.py --check    只校验块是否最新，不写入
退出码 1 表示有块过期或结构错误。打印处理的块数；0 块视为失败。
"""
import io
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SKILLS = os.path.join(ROOT, 'skills')
ENABLED = os.path.join(ROOT, 'enabled')
TARGET_DIR = os.path.join(ROOT, 'collab-framework')
SECTION = '## 跨角色必读'
BEGIN = '<!-- BEGIN SKILL-BLOCK: {} -->'
END = '<!-- END SKILL-BLOCK: {} -->'


def extract(skill_path: str) -> str:
    """取出 §跨角色必读 的正文，标题降一级，去掉本节标题自身。"""
    text = io.open(skill_path, encoding='utf-8').read()
    if SECTION not in text:
        return ''
    body = text.split(SECTION, 1)[1]
    # 到下一个同级标题或分隔线为止
    stop = re.search(r'\n---\n|\n## ', body)
    if stop:
        body = body[:stop.start()]
    out = []
    for line in body.strip('\n').split('\n'):
        out.append('#' + line if re.match(r'^#{2,5} ', line) else line)
    return '\n'.join(out).strip('\n')


def main() -> int:
    check = '--check' in sys.argv[1:]
    plan = {}                      # target file -> {skill: rendered}
    errors = []
    n_shared_enabled = 0
    for name in sorted(os.listdir(SKILLS)):
        sp = os.path.join(SKILLS, name, 'SKILL.md')
        if not os.path.isfile(sp):
            continue
        text = io.open(sp, encoding='utf-8').read()
        m = re.search(r'^\*\*投影\*\*：(.+)$', text, re.M)
        if not m or m.group(1).strip() == '无':
            continue
        # `**投影**` 声明的是「投到哪」，不是「现在正在投」。是否生效由
        # 状态 + 启用池决定。所以休眠/移出启用池**不是错误**，它是合法的停用态：
        # 此处直接跳过，剩余的标记块由下面的孤儿检查负责报错。
        # 由来：此前这里无条件 fail，导致共享 skill **没有任何能通过门禁的停用态**
        # ——声明投影就 fail，改 `投影：无` 又被 sync-skills 的「共享不得为无」挡住。
        # 死锁由外部 review 抓出（P1）。
        st = re.search(r'^\*\*状态\*\*：(\S+)', text, re.M)
        st = st.group(1) if st else ''
        if st != 'enabled' or not os.path.islink(os.path.join(ENABLED, name)):
            continue
        n_shared_enabled += 1
        body = extract(sp)
        if not body:
            errors.append(f'{name}: 声明了投影目标但没有 `{SECTION}` 一节')
            continue
        for tgt in [t.strip() for t in m.group(1).split(',')]:
            plan.setdefault(tgt, {})[name] = body

    # 标记块的基数与孤儿检查。
    # 🔴 基数判别式：**每个 skill 在每个目标文件里的标记块必须恰好出现一次，
    #    且 BEGIN 与 END 计数相等。** 下面用 text.index() 定位，它只看得见第一个
    #    ——第二份手抄或过期的块会完全不被检查却继续进入消费者上下文，
    #    破坏「单一可编辑源」这条本脚本存在的理由。外部 review 抓出（P1）。
    for tgt in sorted(os.listdir(TARGET_DIR)):
        path = os.path.join(TARGET_DIR, tgt)
        if not os.path.isfile(path) or not tgt.endswith('.md'):
            continue
        text = io.open(path, encoding='utf-8').read()
        begins = re.findall(r'<!-- BEGIN SKILL-BLOCK: ([^>]+?) -->', text)
        ends = re.findall(r'<!-- END SKILL-BLOCK: ([^>]+?) -->', text)
        for found in sorted(set(begins)):
            nb, ne = begins.count(found), ends.count(found)
            if nb > 1 or ne > 1:
                errors.append(f'{tgt}: {found} 的标记块出现 {nb} 次 BEGIN / {ne} 次 END'
                              f' —— 必须恰好一次。多出来的那份不会被校验，'
                              f'却仍进入消费者上下文，等于第二个可编辑源')
            elif nb != ne:
                errors.append(f'{tgt}: {found} 的 BEGIN/END 不配对（{nb}/{ne}）')
            if found not in plan.get(tgt, {}):
                errors.append(f'{tgt}: 孤儿标记块 {found} —— 该 skill 已不是生效的共享 skill，'
                              f'请删除这对标记及其内容')
        for found in sorted(set(ends) - set(begins)):
            errors.append(f'{tgt}: {found} 有 END 但无 BEGIN')


    n_blocks = 0
    for tgt, blocks in sorted(plan.items()):
        path = os.path.join(TARGET_DIR, tgt)
        if not os.path.isfile(path):
            errors.append(f'投影目标不存在：{tgt}')
            continue
        text = io.open(path, encoding='utf-8').read()
        for name, body in sorted(blocks.items()):
            b, e = BEGIN.format(name), END.format(name)
            if b not in text or e not in text:
                errors.append(f'{tgt}: 缺 {name} 的标记块（需要 {b} … {e}）')
                continue
            head = text.index(b) + len(b)
            tail = text.index(e)
            want = ('\n<!-- 自动生成，勿手改。源：~/claude-agent/skills/'
                    f'{name}/SKILL.md §跨角色必读；重新生成：scripts/render-shared.py -->\n\n'
                    + body + '\n')
            if text[head:tail] != want:
                if check:
                    errors.append(f'{tgt}: {name} 的块已过期，跑 scripts/render-shared.py')
                else:
                    text = text[:head] + want + text[tail:]
            n_blocks += 1
        if not check:
            io.open(path, 'w', encoding='utf-8').write(text)

    print(f'  处理了 {n_blocks} 个共享块，投影到 {len(plan)} 个目标文件'
          + (f'（{n_shared_enabled} 个共享 skill 在启用池）' if n_blocks == 0 else ''))
    # 0 块的判据要分两种：没有任何生效的共享 skill ⇒ 合法（全部停用是允许的状态）；
    # 有生效的共享 skill 却渲染出 0 块 ⇒ 渲染没有作用对象，无效。
    if n_blocks == 0 and n_shared_enabled > 0:
        print(f'  [FAIL] 有 {n_shared_enabled} 个生效的共享 skill，却渲染出 0 个块'
              f' —— 渲染没有作用对象，结果无效')
        return 1
    for e in errors:
        print(f'  [FAIL] {e}')
    return 1 if errors else 0


if __name__ == '__main__':
    sys.exit(main())
