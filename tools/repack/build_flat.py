# Build the single-archive SexLab Survival Repack (no FOMOD): exactly what the owner's MO2 profile resolves from the
# "SexLab Survival" separator block, minus the private / third-party-dependent mods, plus AutoSEQ's .seq.
#   python -I build_flat.py [--archive]
# Layering = MO2 priority (profiles\Default\modlist.txt, top wins). Our .pex headers get neutral strings, per-mod docs
# are dropped (one repack README instead), the stage is grepped for private strings before packing.
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys

ROOT = r'C:\Modding\MO2'
M = os.path.join(ROOT, 'mods')
HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
STAGE = os.path.join(HERE, 'stage_flat')
NAME = 'SexLab Survival Repack'
VERSION = '0.716.2'
BLOCK_SEP = 'SexLab Survival_separator'
EXCLUDE = {
    'Amputator NG - SL Survival Patch',            # needs Amputator.esm; ships with Amputator Framework Reborn
    'SL Survival Guards - Viking Patch',           # own page (needs Vikings armor)
    'SL Survival.esp-VoiceFiles',                  # own page (voice pack)
}
SEQ = {r'SEQ\SL Survival.seq': os.path.join(M, r'AutoSEQ\Seq\SL Survival.seq')}  # owner: AutoSEQ's regenerated one
# release-only replacements: the begging patch without the Diary of Mine master (work\SLS_begging\release_no_dom.py)
OVERRIDE = {'SLS Begging Conditions.esp': os.path.join(ROOT, r'work\SLS_begging\release\SLS Begging Conditions.esp')}

sys.path.insert(0, os.path.join(HERE, 'tools'))
from pex_scrub import scrub  # noqa: E402

CANON = {'scripts': 'Scripts', 'source': 'Source', 'skse': 'SKSE', 'plugins': 'Plugins', 'textures': 'textures',
         'meshes': 'meshes', 'interface': 'interface', 'sound': 'Sound', 'voice': 'Voice', 'seq': 'SEQ'}


def canon(rel):
    parts = rel.replace('/', '\\').split('\\')
    return '\\'.join(CANON.get(p.lower(), p) if i < len(parts) - 1 else p for i, p in enumerate(parts))


def skip(rel):
    r = rel.lower()
    top = r.split('\\')[0]
    return (top in ('docs', 'fomod') or r == 'meta.ini' or r.endswith(('.pdb', '.bak', '.log')) or
            r.endswith('.md') and '\\' not in r)


def block_mods():
    body = open(os.path.join(ROOT, 'profiles', 'Default', 'modlist.txt'), encoding='utf-8').read().splitlines()[1:]
    end = body.index('-' + BLOCK_SEP)
    start = max(i for i, l in enumerate(body[:end]) if l.endswith('_separator')) + 1
    return [l[1:] for l in body[start:end] if l.startswith('+') and l[1:] not in EXCLUDE]  # top = highest priority


def main():
    mods = block_mods()
    files = {}  # key -> (rel, src, mod); lowest priority first so higher overwrites
    for mod in reversed(mods):
        base = os.path.join(M, mod)
        for dp, dn, fn in os.walk(base):
            for f in fn:
                rel = os.path.relpath(os.path.join(dp, f), base)
                if not skip(rel):
                    files[canon(rel).lower()] = (canon(rel), os.path.join(dp, f), mod)
    for rel, src in SEQ.items():
        files[rel.lower()] = (rel, src, 'AutoSEQ')
    for rel, src in OVERRIDE.items():
        if rel.lower() not in files:
            sys.exit('override target not staged: ' + rel)
        files[rel.lower()] = (rel, src, 'release')
    for k in [k for k in files if k.startswith('seq\\') and k not in {r.lower() for r in SEQ}
              and not k.endswith('hopeless escorts dialogue.seq')]:
        del files[k]
    if os.path.exists(STAGE):
        shutil.rmtree(STAGE)
    ours = {'SL Survival - Patches', 'SexLab Survival Framework', 'SL Survival - SexLab P+ 2.19 Patch',
            'houseCARL - SL Survival - Hopeless Escorts Generic Voice', 'SL Survival - Hopeless Escorts Faces'}
    scrubbed = 0
    for rel, src, mod in files.values():
        dst = os.path.join(STAGE, rel)
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        shutil.copy2(src, dst)
        if mod in ours and dst.lower().endswith('.pex') and scrub(dst):
            scrubbed += 1
    docs = os.path.join(STAGE, 'docs')
    os.makedirs(docs, exist_ok=True)
    shutil.copy2(os.path.join(HERE, 'docs', NAME + '__README.md'), docs)
    # privacy sweep: private paths/names and the pseudonym in our text, plugins, scripts and the DLL
    bad = re.compile(os.environ.get('LEAK_PATTERNS', r'(?i)users[\\/]').encode())
    text = ('.pex', '.psc', '.json', '.ini', '.txt', '.md', '.xml', '.dll', '.esp', '.esl', '.seq')
    hits = []
    for dp, dn, fn in os.walk(STAGE):
        for f in fn:
            full = os.path.join(dp, f)
            if f.lower().endswith(text):
                m = bad.search(open(full, 'rb').read())
                if m:
                    hits.append(f'{os.path.relpath(full, STAGE)}: {m.group(0)!r}')
    if hits:
        print('PRIVATE STRINGS:')
        for h in hits[:60]:
            print('  ' + h)
        sys.exit(1)
    man = {'name': NAME, 'version': VERSION, 'mods': mods, 'files': []}
    for dp, dn, fn in os.walk(STAGE):
        for f in sorted(fn):
            full = os.path.join(dp, f)
            man['files'].append({'path': os.path.relpath(full, STAGE), 'size': os.path.getsize(full),
                                 'sha256': hashlib.sha256(open(full, 'rb').read()).hexdigest()})
    open(os.path.join(docs, NAME + '__manifest.json'), 'w', encoding='utf-8').write(json.dumps(man, indent=1))
    by = {}
    for rel, src, mod in files.values():
        by[mod] = by.get(mod, 0) + 1
    print('layers (top wins):', *[f'\n  {m}: {by.get(m, 0)}' for m in mods + ['AutoSEQ']])
    print(f'staged {len(man["files"])} files, {sum(x["size"] for x in man["files"]) / 1e6:.0f} MB, pex scrubbed {scrubbed}')
    if '--archive' in sys.argv:
        out = os.path.join(os.path.expanduser('~'), 'Desktop', f'{NAME}.7z')  # owner: no version in the file name
        if os.path.exists(out):
            os.remove(out)
        subprocess.check_call([r'C:\Program Files\7-Zip\7z.exe', 'a', '-t7z', '-mx=7', '-mmt=on', out, '.\\*'], cwd=STAGE,
                              stdout=subprocess.DEVNULL)
        print('archive', out, f'{os.path.getsize(out) / 1e6:.0f} MB')


if __name__ == '__main__':
    main()
