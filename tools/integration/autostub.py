r"""Compile a script repeatedly; every third-party source the Bethesda compiler fails on is replaced by a stub
(stubify.py) in stubs\\, unknown types inside a stub become Form. Stops when the script compiles.

Usage: python autostub.py <script.psc> [--sources src] [--max 15]
Other projects: set AUTOSTUB_ROOT (project dir with <sources>\ and stubs\) and AUTOSTUB_IMPORTS (';'-separated).
"""
import os
import re
import subprocess
import sys
import xml.etree.ElementTree as ET

sys.path.insert(0, os.path.dirname(__file__))
from stubify import stubify

ROOT = os.environ.get('AUTOSTUB_ROOT') or os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.join(ROOT, 'sls_repo')
STUBS = os.path.join(ROOT, 'stubs')
COMPILER = r'C:\Modding\MO2\basegame\Papyrus Compiler\PapyrusCompiler.exe'
SKSE = r'C:\Modding\MO2\basegame\Data\Scripts\Source'
VANILLA = r'C:\Modding\MO2\basegame\Data\Source\Scripts'
WFNG = r'C:\Modding\MO2\work\WetFunctionNG\papyrus\source'


def imports(sources):
    if os.environ.get('AUTOSTUB_IMPORTS'):  # another project: its own ';'-separated list, its stubs dir second
        return [os.path.join(ROOT, sources), STUBS] + [p for p in os.environ['AUTOSTUB_IMPORTS'].split(';') if os.path.isdir(p)]
    tree = ET.parse(os.path.join(REPO, 'skyrimse.ppj'))
    out = [os.path.join(ROOT, sources), STUBS, WFNG]
    for el in tree.iter():
        if el.tag.endswith('Import'):
            v = el.text.strip()
            if v == '@ImportsFolder':
                out.append(os.path.join(REPO, 'scripts', 'source'))
            elif v == '@SkyrimScripts':
                out += [SKSE, VANILLA]
            else:
                out.append(os.path.join(REPO, re.sub(r'^\.\\', '', v)))
    return [p for p in out if os.path.isdir(p)]


def compile_once(script, sources):
    tmp = os.path.join(ROOT, 'out_probe')
    os.makedirs(tmp, exist_ok=True)
    r = subprocess.run([COMPILER, script, '-f=TESV_Papyrus_Flags.flg', '-i=' + ';'.join(imports(sources)), '-o=' + tmp],
                       capture_output=True, text=True, cwd=os.environ.get('TEMP', '.'))
    return r.stdout + r.stderr


def main():
    script = sys.argv[1]
    sources = sys.argv[sys.argv.index('--sources') + 1] if '--sources' in sys.argv else 'src'
    limit = int(sys.argv[sys.argv.index('--max') + 1]) if '--max' in sys.argv else 15
    own = os.path.normcase(os.path.join(ROOT, sources))
    for round_ in range(limit):
        log = compile_once(script, sources)
        errs = re.findall(r'^(.*?\.psc)\((\d+),(\d+)\): (.*)$', log, re.M)
        if not errs:
            print('compiled:', os.path.basename(script))
            return 0
        changed = False
        for path in sorted({e[0] for e in errs}):
            np = os.path.normcase(path)
            if np.startswith(own):
                continue  # our own source: report, never stub
            name = os.path.basename(path)
            dst = os.path.join(STUBS, name)
            msgs = [e[3] for e in errs if e[0] == path]
            if os.path.normcase(os.path.dirname(path)) == os.path.normcase(STUBS):
                # an existing stub still fails: unknown types -> Form
                text = open(dst, encoding='utf-8').read()
                for t in set(re.findall(r'unknown type (\w+)', ' '.join(msgs))):
                    text = re.sub(r'\b' + t + r'\b(?=(\[\])?\s+\w)', 'Form', text, flags=re.I)
                    changed = True
                open(dst, 'w', encoding='utf-8').write(text)
                print(f'round {round_}: retyped unknowns in stub {name}')
            else:
                text = open(path, encoding='utf-8-sig', errors='replace').read()
                open(dst, 'w', encoding='utf-8').write(stubify(text))
                changed = True
                print(f'round {round_}: stubbed {name} ({msgs[0][:80]})')
        if not changed:
            print(log[-3000:])
            return 1
    print('gave up after', limit, 'rounds')
    print(log[-3000:])
    return 1


if __name__ == '__main__':
    sys.exit(main())
