#!/usr/bin/env python3
"""核对 opencode 的 JSONC 配置里，顶层 skills.paths 是否含指定目录。

字符串搜索会把注释掉的配置当成生效配置——那是把失败报成成功。
本脚本剥掉注释后按 JSON 解析，只认顶层 skills.paths 数组的成员。
输出 OK 或一行原因；解析失败也报原因，绝不静默通过。
"""
import json
import os
import re
import sys


def strip_jsonc(text: str) -> str:
    """去掉 // 与 /* */ 注释，保留字符串字面量内的相同字符。"""
    out, i, n = [], 0, len(text)
    while i < n:
        c = text[i]
        if c == '"':
            j = i + 1
            while j < n:
                if text[j] == '\\':
                    j += 2
                    continue
                if text[j] == '"':
                    break
                j += 1
            out.append(text[i:j + 1])
            i = j + 1
        elif text.startswith('//', i):
            j = text.find('\n', i)
            i = n if j == -1 else j
        elif text.startswith('/*', i):
            j = text.find('*/', i + 2)
            i = n if j == -1 else j + 2
        else:
            out.append(c)
            i += 1
    s = ''.join(out)
    return re.sub(r',(\s*[}\]])', r'\1', s)  # 容忍尾随逗号


def main() -> int:
    cfg_path, wanted = sys.argv[1], sys.argv[2]
    try:
        raw = open(cfg_path, encoding='utf-8').read()
    except OSError as exc:
        print(f'读取配置失败：{exc}')
        return 1
    try:
        cfg = json.loads(strip_jsonc(raw))
    except json.JSONDecodeError as exc:
        print(f'JSONC 解析失败（{exc.lineno} 行）：{exc.msg}')
        return 1
    if not isinstance(cfg, dict):
        print('配置顶层不是对象')
        return 1
    skills = cfg.get('skills')
    if skills is None:
        print('顶层缺 skills 键')
        return 1
    if not isinstance(skills, dict):
        print('顶层 skills 不是对象')
        return 1
    paths = skills.get('paths')
    if not isinstance(paths, list):
        print('skills.paths 缺失或不是数组')
        return 1
    norm = [os.path.realpath(os.path.expanduser(p)) for p in paths if isinstance(p, str)]
    if os.path.realpath(wanted) not in norm:
        print(f'skills.paths 未含启用池（当前 {paths}）')
        return 1
    print('OK')
    return 0


if __name__ == '__main__':
    sys.exit(main())
