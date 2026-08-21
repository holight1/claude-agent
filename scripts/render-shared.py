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
    for name in sorted(os.listdir(SKILLS)):
        sp = os.path.join(SKILLS, name, 'SKILL.md')
        if not os.path.isfile(sp):
            continue
        text = io.open(sp, encoding='utf-8').read()
        m = re.search(r'^\*\*投影\*\*：(.+)$', text, re.M)
        if not m or m.group(1).strip() == '无':
            continue
        # 休眠或移出启用池的 skill 不得继续投影——否则它对执行端仍然生效
        st = re.search(r'^\*\*状态\*\*：(\S+)', text, re.M)
        st = st.group(1) if st else ''
        if st != 'enabled' or not os.path.islink(os.path.join(ENABLED, name)):
            errors.append(f'{name}: 声明了投影目标，但状态为「{st or "缺失"}」'
                          f'{"、且不在启用池" if not os.path.islink(os.path.join(ENABLED, name)) else ""}。'
                          f'请先删除目标文件里它的标记块，再改状态')
            continue
        body = extract(sp)
        if not body:
            errors.append(f'{name}: 声明了投影目标但没有 `{SECTION}` 一节')
            continue
        for tgt in [t.strip() for t in m.group(1).split(',')]:
            plan.setdefault(tgt, {})[name] = body

    # 孤儿标记块：目标文件里有块，但没有对应的、当前生效的共享 skill
    for tgt in sorted(os.listdir(TARGET_DIR)):
        path = os.path.join(TARGET_DIR, tgt)
        if not os.path.isfile(path) or not tgt.endswith('.md'):
            continue
        text = io.open(path, encoding='utf-8').read()
        for found in re.findall(r'<!-- BEGIN SKILL-BLOCK: ([^>]+?) -->', text):
            if found not in plan.get(tgt, {}):
                errors.append(f'{tgt}: 孤儿标记块 {found} —— 该 skill 已不是生效的共享 skill，'
                              f'请删除这对标记及其内容')

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

    print(f'  处理了 {n_blocks} 个共享块，投影到 {len(plan)} 个目标文件')
    if n_blocks == 0:
        print('  [FAIL] 0 个共享块 —— 渲染没有作用对象，结果无效')
        return 1
    for e in errors:
        print(f'  [FAIL] {e}')
    return 1 if errors else 0


if __name__ == '__main__':
    sys.exit(main())
