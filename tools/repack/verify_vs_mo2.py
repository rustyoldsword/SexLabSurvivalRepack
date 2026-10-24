# Compare the repack (core + the options the owner runs) with the SLS layers the owner's MO2 serves now.
# pex compare ignores the header strings (scrubbed), the framework DLL is reported separately (rebuilt, paths trimmed).
import os, sys, hashlib, struct
M = r'C:\Modding\MO2\mods'; S = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'stage')
LAYERS = ['Sexlab Survival', 'SexLab Survival 0.716', 'SL Survival - Patches', 'SL Survival - SexLab P+ 2.19 Patch', 'SexLab Survival Framework']  # low -> high
OPTS = ['00 Core', '20 SlaveTats Pack', '30 Bikini Armor KID', '31 SMP Tongue', '32 Battle Wounds', '10 Framework', '11 Gentler Steep Fall', '12 TNG revealing cover']
def skip(r):
    r = r.lower()
    return r == 'meta.ini' or r.endswith(('.pdb', '.md', '.psc')) or r.startswith(('docs' + os.sep, 'seq' + os.sep, 'fomod'))
def body(f):
    b = open(f, 'rb').read()
    if f.lower().endswith('.pex'):
        p = 16
        for _ in range(3): p += 2 + struct.unpack_from('>H', b, p)[0]
        b = b[:8] + b[p:]  # skip compile time + identity strings
    return hashlib.md5(b).hexdigest()
def vfs(roots):
    d = {}
    for r in roots:
        for dp, dn, fn in os.walk(r):
            for f in fn:
                full = os.path.join(dp, f); rel = os.path.relpath(full, r)
                if not skip(rel): d[rel.lower()] = full
    return d
a = vfs([os.path.join(M, l) for l in LAYERS]); b = vfs([os.path.join(S, o) for o in OPTS])
miss = sorted(set(a) - set(b)); extra = sorted(set(b) - set(a))
diff = [k for k in sorted(set(a) & set(b)) if body(a[k]) != body(b[k])]
print('mo2', len(a), 'repack', len(b)); print('missing in repack', len(miss)); [print('  ', k) for k in miss[:30]]
print('only in repack', len(extra)); [print('  ', k) for k in extra[:30]]
print('different', len(diff)); [print('  ', k) for k in diff[:30]]
