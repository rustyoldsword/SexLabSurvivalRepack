"""Turn a Papyrus source into a compile-time stub: keep the script header, imports, properties, variables,
states and every function/event signature, drop every body (typed functions return a default value).

The Bethesda compiler parses every script a compiled script references; when one of those cannot be parsed
(missing third-party types, mismatched state defaults) a stub with the same signatures stands in for it.
The VM binds calls by name at runtime, so the stub never ships.

Usage: python stubify.py <in.psc> <out.psc> [--fix-state-defaults]
  --fix-state-defaults  give every state function the parameter defaults of the empty-state function
                        of the same name (the compiler insists they match)
"""
import re
import sys

FUNC = re.compile(r'^\s*(?:(\w+(?:\s*\[\])?)\s+)?(Function|Event)\s+(\w+)\s*\((.*)\)(.*)$', re.I)
DEFAULTS = {'int': '0', 'float': '0.0', 'bool': 'False', 'string': '""'}


def logical_lines(text):
    buf = ''
    for raw in text.splitlines():
        line = raw.rstrip()
        # strip ; comments that are not inside strings (good enough for signatures)
        if ';' in line and '"' not in line.split(';', 1)[0]:
            line = line.split(';', 1)[0].rstrip()
        if line.endswith('\\'):
            buf += line[:-1] + ' '
            continue
        yield buf + line
        buf = ''


BACKSLASH = chr(92)
NEWLINE = chr(10)


def strip_block_comments(text):
    """Drop ;/ ... /; and { ... } comments, never inside string literals (\" escapes respected)."""
    out, i, n = [], 0, len(text)
    in_str = False
    while i < n:
        c = text[i]
        if in_str:
            out.append(c)
            if c == BACKSLASH and i + 1 < n:
                out.append(text[i + 1]); i += 2; continue
            if c == '"' or c == NEWLINE:
                in_str = False
            i += 1
            continue
        if c == '"':
            in_str = True; out.append(c); i += 1; continue
        if c == ';' and text.startswith(';/', i):
            j = text.find('/;', i + 2)
            i = n if j < 0 else j + 2
            continue
        if c == ';':  # line comment: keep it (logical_lines strips it), but skip to end of line so braces in it are ignored
            j = text.find(NEWLINE, i)
            j = n if j < 0 else j
            out.append(text[i:j]); i = j; continue
        if c == '{':
            j = text.find('}', i + 1)
            i = n if j < 0 else j + 1
            continue
        out.append(c); i += 1
    return ''.join(out)


def params_with_defaults(params):
    out = {}
    for p in [x.strip() for x in params.split(',') if x.strip()]:
        m = re.match(r'(\w+(?:\[\])?)\s+(\w+)(?:\s*=\s*(.+))?$', p)
        if m:
            out[m.group(2).lower()] = (m.group(1), m.group(2), m.group(3))
    return out


def stubify(text, fix_defaults=False):
    lines = list(logical_lines(strip_block_comments(text)))
    empty_sigs = {}
    state = None
    for line in lines:
        s = line.strip()
        if re.match(r'^(auto\s+)?state\s+\w+', s, re.I):
            state = s
        elif re.match(r'^endstate\b', s, re.I):
            state = None
        elif state is None:
            m = FUNC.match(line)
            if m:
                empty_sigs[m.group(3).lower()] = m.group(4)

    out, depth, state, in_prop = [], 0, None, False
    for line in lines:
        s = line.strip()
        low = s.lower()
        if depth:
            if re.match(r'^end(function|event)\b', low):
                depth = 0
            continue
        if not s:
            continue
        # callers only see the empty state's signatures: drop state blocks (the Bethesda compiler also
        # rejects some state overrides whose defaults do match, e.g. negative float literals)
        if re.match(r'^(auto\s+)?state\s+\w+', low):
            state = s
            continue
        if low.startswith('endstate'):
            state = None
            continue
        if state is not None:
            m = FUNC.match(line)
            if m and not re.search(r'native', m.group(5), re.I):
                depth = 1
            continue
        m = FUNC.match(line)
        if m:
            rtype, kind, name, params, tail = m.groups()
            if fix_defaults and state is not None and name.lower() in empty_sigs:
                params = empty_sigs[name.lower()]
            header = f"{rtype + ' ' if rtype else ''}{kind} {name}({params}){tail}"
            out.append(header)
            if re.search(r'\bnative\b', tail, re.I):
                continue
            if rtype and rtype.lower() != 'none':
                out.append('\tReturn ' + DEFAULTS.get(rtype.lower(), 'None'))
            out.append('End' + kind)
            depth = 1
            continue
        if re.match(r'^(auto\s+)?state\s+\w+', low):
            state = s
        elif low.startswith('endstate'):
            state = None
        if re.match(r'^(scriptname|import|endstate|(auto\s+)?state\b)', low) or re.search(r'\sproperty\s', f' {low} ') or low.startswith('endproperty'):
            out.append(line)
            continue
        # top-level variable declarations
        if state is None and re.match(r'^\w+(\[\])?\s+\w+(\s*=.*)?$', s) and not low.startswith(('return', 'if', 'while')):
            out.append(line)
    return '\n'.join(out) + '\n'


if __name__ == '__main__':
    src, dst = sys.argv[1], sys.argv[2]
    text = open(src, encoding='utf-8-sig', errors='replace').read()
    open(dst, 'w', encoding='utf-8').write(stubify(text, '--fix-state-defaults' in sys.argv))
