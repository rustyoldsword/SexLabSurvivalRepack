# Build the standalone SexLab Survival repack (FOMOD) from the tested MO2 layers.
#   python -I build_repack.py [--archive]
# Core = Monoman1's SexLab Survival 0.685 SE assets < crajjjj 0.716 < SL Survival - Patches < P+ 2.19 patch,
# + the AutoSEQ .seq for the cleaned plugin and the 0.716 sources from crajjjj's repo (tag 0.716).
# Options = SexLab Survival Framework (DLL + scripts) and its two extras, the SLS SlaveTats pack, crajjjj's optionals.
# Our own .pex get neutral header strings; the whole stage is grepped for private strings before packing.
import os, sys, shutil, hashlib, json, subprocess, re, struct

ROOT = r'C:\Modding\MO2'
M = os.path.join(ROOT, 'mods')
HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
REPO = os.path.join(ROOT, r'work\SLS_integration\sls_repo')
FW = os.path.join(ROOT, r'work\SLSFramework')
STAGE = os.path.join(HERE, 'stage')
NAME = 'SexLab Survival Repack'
VERSION = '0.716.1-alpha2'
INCLUDE_SPANKED = True    # slavetats_spanked_1.0 marks (permission confirmed by the owner)

sys.path.insert(0, os.path.join(HERE, 'tools'))
from pex_scrub import scrub

def walk(root):
    for dp, dn, fn in os.walk(root):
        for f in fn:
            full = os.path.join(dp, f)
            yield os.path.relpath(full, root), full

CANON = {'scripts': 'Scripts', 'source': 'Source', 'skse': 'SKSE', 'plugins': 'Plugins', 'textures': 'textures',
         'meshes': 'meshes', 'interface': 'interface', 'sound': 'sound', 'seq': 'SEQ'}
def canon(rel):
    parts = rel.replace('/', '\\').split('\\')
    out = [CANON.get(p.lower(), p) if i < len(parts) - 1 else p for i, p in enumerate(parts)]
    if len(out) > 2 and out[0] == 'Scripts' and out[1] == 'Source': pass
    return '\\'.join(out)

class Layer:
    """case-insensitive file map: key -> (relpath, source, origin)"""
    def __init__(s): s.files = {}
    def add(s, rel, src, origin):
        rel = canon(rel); s.files[rel.lower()] = (rel, src, origin)
    def add_tree(s, root, origin, skip=lambda r: False, prefix=''):
        n = 0
        for rel, full in walk(root):
            if skip(rel.replace('/', '\\').lower()): continue
            s.add(os.path.join(prefix, rel), full, origin); n += 1
        return n

def skip_common(r):
    return r == 'meta.ini' or r.endswith('.pdb')

# ---------------------------------------------------------------- core
core = Layer()
opt_tongue = {r.lower() for r, _ in walk(os.path.join(REPO, r'optional\SmpTongue'))}
opt_wounds = {r.lower() for r, _ in walk(os.path.join(REPO, r'optional\BattleWounds'))}
print('0.685 base  ', core.add_tree(os.path.join(M, 'Sexlab Survival'), '0.685',
      lambda r: skip_common(r) or r.startswith('seq\\') or r.startswith('scripts\\source\\')))
print('0.716       ', core.add_tree(os.path.join(M, 'SexLab Survival 0.716'), '0.716',
      lambda r: skip_common(r) or r == 'zzz_sls_bikiniarmor_kid.ini' or r in opt_tongue or r in opt_wounds))
print('0.716 source', core.add_tree(os.path.join(REPO, r'scripts\source'), 'repo', prefix=r'Scripts\Source'))
print('patches     ', core.add_tree(os.path.join(M, 'SL Survival - Patches'), 'ours',
      lambda r: skip_common(r) or r.startswith('docs\\') or r.startswith('textures\\') or r.endswith('.md')))
print('P+ 2.19     ', core.add_tree(os.path.join(M, 'SL Survival - SexLab P+ 2.19 Patch'), 'ours',
      lambda r: skip_common(r) or r.startswith('docs\\')))
core.add(r'SEQ\SL Survival.seq', os.path.join(M, r'AutoSEQ\Seq\SL Survival.seq'), 'autoseq')
for k in [k for k in core.files if k.startswith('seq\\') and k != r'seq\sl survival.seq']:
    del core.files[k]

# ---------------------------------------------------------------- framework (built tree, not the deployed mod)
fw = Layer()
fw.add(r'SKSE\Plugins\SLSurvivalFramework.dll', os.path.join(FW, r'build\windows\x64\releasedbg\SLSurvivalFramework.dll'), 'ours')
for f in os.listdir(os.path.join(FW, r'papyrus\source')):
    if not f.lower().endswith('.psc'): continue
    psc = os.path.join(FW, r'papyrus\source', f); pex = os.path.join(FW, r'papyrus\out', f[:-4] + '.pex')
    if not os.path.exists(pex) or os.path.getmtime(pex) < os.path.getmtime(psc): sys.exit('stale or missing ' + pex)
    fw.add(r'Scripts\\' + f[:-4] + '.pex', pex, 'ours'); fw.add(r'Scripts\Source\\' + f, psc, 'ours')
fw_steep = Layer(); fw_steep.add_tree(os.path.join(FW, r'data'), 'ours', lambda r: 'storageutildata' not in r)
fw_tng = Layer(); fw_tng.add_tree(os.path.join(FW, r'data'), 'ours', lambda r: 'skypatcher' not in r)
fw.add(r'docs\SexLab Survival Framework__README.md', os.path.join(FW, r'docs\SexLab Survival Framework__README.md'), 'ours')

# ---------------------------------------------------------------- SlaveTats pack (SLS's own overlays + UBE variants)
tats = Layer()
tats.add_tree(os.path.join(M, r'SL Survival - Patches\textures'), 'ours',
              lambda r: (not INCLUDE_SPANKED) and 'spanked' in r, prefix='textures')

# ---------------------------------------------------------------- crajjjj's optionals, as his FOMOD ships them
def repo_opt(name, skip=lambda r: False):
    l = Layer(); l.add_tree(os.path.join(REPO, 'optional', name), 'repo', skip); return l
o_kid = repo_opt('BikiniArmorKID'); o_tongue = repo_opt('SmpTongue'); o_wounds = repo_opt('BattleWounds')
o_wounds2 = Layer()
for k, (rel, src, org) in o_wounds.files.items(): o_wounds2.add('textures\\' + rel[len('textures\\'):], src, org)
o_tawoba = repo_opt('TewobaBikiniBreak'); o_animal = repo_opt('AnimalFriendTeammate')
# SunHelm: only its plugin and json - our _SLS_Needs (core) already carries crajjjj's SunHelm state
o_sunhelm = repo_opt('SunHelm', lambda r: r.startswith('scripts\\'))

OPTIONS = [  # folder, layer, priority
    ('00 Core', core, 0), ('10 Framework', fw, 10), ('11 Gentler Steep Fall', fw_steep, 11), ('12 TNG revealing cover', fw_tng, 11),
    ('20 SlaveTats Pack', tats, 5), ('30 Bikini Armor KID', o_kid, 5), ('31 SMP Tongue', o_tongue, 5),
    ('32 Battle Wounds', o_wounds2, 5), ('33 TAWoBA Bikini Break', o_tawoba, 5), ('34 Animal Friend Teammates', o_animal, 5),
    ('35 SunHelm', o_sunhelm, 5)]

# ---------------------------------------------------------------- overlap report (higher priority wins)
seen = {}
for folder, layer, pri in OPTIONS:
    for k in layer.files:
        if k in seen and folder != '00 Core': print(f'  overlap {k}: {seen[k]} < {folder}')
        seen.setdefault(k, folder)

# ---------------------------------------------------------------- stage
if os.path.exists(STAGE): shutil.rmtree(STAGE)
for folder, layer, pri in OPTIONS:
    for rel, src, origin in layer.files.values():
        dst = os.path.join(STAGE, folder, rel)
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        shutil.copy2(src, dst)
        if origin == 'ours' and dst.lower().endswith('.pex'): scrub(dst)

# docs
docs = os.path.join(STAGE, '00 Core', 'docs'); os.makedirs(docs, exist_ok=True)
shutil.copy2(os.path.join(HERE, 'docs', NAME + '__README.md'), docs)

# ---------------------------------------------------------------- privacy sweep
BAD = re.compile(os.environ.get('LEAK_PATTERNS', r'(?i)users[\\/]').encode())
TEXT = ('.pex', '.psc', '.json', '.ini', '.txt', '.md', '.xml', '.dll', '.esp', '.seq')
hits = []
for rel, full in walk(STAGE):
    if full.lower().endswith(TEXT):
        b = open(full, 'rb').read()
        m = BAD.search(b)
        if m: hits.append(f'{rel}: {m.group(0)!r}')
if hits:
    print('PRIVATE STRINGS:'); [print('  ' + h) for h in hits[:40]]; sys.exit(1)
pexs = [f for r, f in walk(STAGE) if f.lower().endswith('.pex')]
print('pex', len(pexs), 'privacy sweep clean')

# ---------------------------------------------------------------- fomod + manifest
fomod = os.path.join(STAGE, 'fomod'); os.makedirs(fomod)
for f in ('info.xml', 'ModuleConfig.xml'):
    t = open(os.path.join(HERE, 'fomod', f), encoding='utf-8').read().replace('@VERSION@', VERSION).replace('@NAME@', NAME)
    open(os.path.join(fomod, f), 'w', encoding='utf-8').write(t)
man = {'name': NAME, 'version': VERSION, 'files': []}
for rel, full in sorted(walk(STAGE)):
    if rel.startswith('fomod'): continue
    man['files'].append({'path': rel, 'size': os.path.getsize(full), 'sha256': hashlib.sha256(open(full, 'rb').read()).hexdigest()})
open(os.path.join(docs, NAME + '__manifest.json'), 'w', encoding='utf-8').write(json.dumps(man, indent=1))
tot = sum(f['size'] for f in man['files'])
print(f'staged {len(man["files"])} files, {tot / 1e6:.0f} MB')
for folder, layer, pri in OPTIONS: print(f'  {folder:28} {len(layer.files):5}')

if '--archive' in sys.argv:
    out = os.path.join(os.path.expanduser('~'), 'Desktop', f'{NAME} {VERSION}.7z')
    if os.path.exists(out): os.remove(out)
    subprocess.check_call([r'C:\Program Files\7-Zip\7z.exe', 'a', '-t7z', '-mx=7', '-mmt=on', out, '.\\*'], cwd=STAGE,
                          stdout=subprocess.DEVNULL)
    print('archive', out, f'{os.path.getsize(out) / 1e6:.0f} MB')
