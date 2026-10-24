# Full pex reader + cross-script call audit.
# Reads every SLS script (as the game would load it: our patch over 0.716 over the base mod), collects every
# callmethod/callstatic, resolves the target class through the MO2 VFS (loose files by mod priority, plus
# extracted-BSA folders passed with --extra), and reports calls to functions that do not exist or whose
# argument count differs (the VM refuses both at runtime).
import struct, os, sys, re, json, collections

class R:
    def __init__(s, b): s.b = b; s.p = 0
    def u8(s): v = s.b[s.p]; s.p += 1; return v
    def u16(s): v = struct.unpack_from('>H', s.b, s.p)[0]; s.p += 2; return v
    def u32(s): v = struct.unpack_from('>I', s.b, s.p)[0]; s.p += 4; return v
    def ws(s): n = s.u16(); v = s.b[s.p:s.p + n].decode('latin-1'); s.p += n; return v

NARGS = {0:0,1:3,2:3,3:3,4:3,5:3,6:3,7:3,8:3,9:3,0xA:2,0xB:2,0xC:2,0xD:2,0xE:2,0xF:3,0x10:3,0x11:3,0x12:3,0x13:3,
         0x14:1,0x15:2,0x16:2,0x17:3,0x18:2,0x19:3,0x1A:1,0x1B:3,0x1C:3,0x1D:3,0x1E:2,0x1F:2,0x20:3,0x21:3,0x22:4,0x23:4}

def parse(path):
    r = R(open(path, 'rb').read())
    assert r.u32() == 0xFA57C0DE
    r.u8(); r.u8(); r.u16(); r.p += 8; r.ws(); r.ws(); r.ws()
    S = [r.ws() for _ in range(r.u16())]
    if r.u8():
        r.p += 8
        for _ in range(r.u16()):
            r.u16(); r.u16(); r.u16(); r.u8(); n = r.u16(); r.p += 2 * n
    for _ in range(r.u16()): r.u16(); r.u8()
    def val():
        t = r.u8()
        if t == 0: return (0, None)
        if t in (1, 2): return (t, S[r.u16()])
        if t == 3: v = struct.unpack_from('>i', r.b, r.p)[0]; r.p += 4; return (3, v)
        if t == 4: r.p += 4; return (4, None)
        if t == 5: r.u8(); return (5, None)
        raise ValueError(t)
    def func():
        rt = S[r.u16()]; r.u16(); r.u32(); fl = r.u8()
        ps = [(S[r.u16()], S[r.u16()]) for _ in range(r.u16())]
        ls = [(S[r.u16()], S[r.u16()]) for _ in range(r.u16())]
        calls = []
        for _ in range(r.u16()):
            op = r.u8(); a = [val() for _ in range(NARGS[op])]
            if op in (0x17, 0x18, 0x19):
                c = val(); n = c[1]; a += [val() for _ in range(n)]
                calls.append((op, a))
        return dict(ret=rt, glob=bool(fl & 1), native=bool(fl & 2), params=ps, locals=ls, calls=calls)
    objs = []
    for _ in range(r.u16()):
        name = S[r.u16()]; r.u32(); parent = S[r.u16()]; r.u16(); r.u32(); r.u16()
        vars_ = {}
        for _ in range(r.u16()):
            vn = S[r.u16()]; vt = S[r.u16()]; r.u32(); val(); vars_[vn.lower()] = vt
        props = {}
        for _ in range(r.u16()):
            pn = S[r.u16()]; pt = S[r.u16()]; r.u16(); r.u32(); fl = r.u8()
            if fl & 4: r.u16()
            else:
                if fl & 1: func()
                if fl & 2: func()
            props[pn.lower()] = pt
        states = {}
        for _ in range(r.u16()):
            sn = S[r.u16()]; fs = {}
            for _ in range(r.u16()):
                fn = S[r.u16()]; fs[fn.lower()] = (fn, func())
            states[sn.lower()] = fs
        objs.append(dict(name=name, parent=parent, vars=vars_, props=props, states=states))
    return objs[0]

def build_vfs(root, profile, extra):
    """class name (lower) -> pex path, honouring MO2 priority (overwrite > top of modlist > ... > game Data)."""
    order = []
    for line in open(os.path.join(root, 'profiles', profile, 'modlist.txt'), encoding='utf-8'):
        line = line.rstrip('\n')
        if line.startswith('+'): order.append(line[1:])
    layers = [os.path.join(root, 'overwrite')] + [os.path.join(root, 'mods', m) for m in order] + extra + \
             [os.path.join(root, 'basegame', 'Data')]
    vfs = {}
    for layer in layers:
        for sub in ('scripts', 'Scripts'):
            d = os.path.join(layer, sub)
            if not os.path.isdir(d): continue
            for f in os.listdir(d):
                if f.lower().endswith('.pex'):
                    vfs.setdefault(f[:-4].lower(), (os.path.join(d, f), os.path.basename(layer)))
            break
    return vfs

PSC_FN = re.compile(r'^\s*(?:[\w\[\]]+\s+)?(?:Function|Event)\s+(\w+)\s*\(([^)]*)\)', re.I | re.M)
PSC_HDR = re.compile(r'^\s*Scriptname\s+(\w+)(?:\s+extends\s+(\w+))?', re.I | re.M)
def parse_psc(path):
    t = open(path, encoding='latin-1').read()
    t = re.sub(r'\{.*?\}', '', t, flags=re.S)
    t = re.sub(r';.*', '', t)
    t = re.sub(r'\\\s*\n', ' ', t)
    h = PSC_HDR.search(t)
    fs = {}
    for m in PSC_FN.finditer(t):
        a = m.group(2).strip()
        n = 0 if not a else a.count(',') + 1
        fs[m.group(1).lower()] = (m.group(1), dict(params=[('p', '')] * n))
    return dict(name=h.group(1) if h else '', parent=(h.group(2) or '') if h else '', vars={}, props={}, states={'': fs}, psc=True)

def build_psc(root, profile):
    order = []
    for line in open(os.path.join(root, 'profiles', profile, 'modlist.txt'), encoding='utf-8'):
        if line.startswith('+'): order.append(line[1:].rstrip(chr(10)))
    dirs = []
    for m in order:
        for sub in ('scripts/source', 'Scripts/Source', 'source/scripts', 'Source/Scripts'):
            d = os.path.join(root, 'mods', m, sub)
            if os.path.isdir(d): dirs.append(d); break
    dirs += [os.path.join(root, 'basegame', 'Data', 'Scripts', 'Source'), os.path.join(root, 'basegame', 'Data', 'Source', 'Scripts')]
    psc = {}
    for d in dirs:
        for f in os.listdir(d):
            if f.lower().endswith('.psc'): psc.setdefault(f[:-4].lower(), os.path.join(d, f))
    return psc

def main():
    root = r'C:\Modding\MO2'
    extra = [a for a in sys.argv[1:] if os.path.isdir(a)]
    vfs = build_vfs(root, 'Default', extra)
    psc = build_psc(root, 'Default')
    cache = {}
    def get(cls):
        cls = cls.lower()
        if cls not in cache:
            p = vfs.get(cls)
            try: cache[cls] = parse(p[0]) if p else (parse_psc(psc[cls]) if cls in psc else None)
            except Exception as e: cache[cls] = None; print('PARSE FAIL', cls, e)
        return cache[cls]
    def find_func(cls, fn, seen=0):
        o = get(cls)
        if o is None: return 'nopex', None
        for st in o['states'].values():
            if fn.lower() in st: return 'ok', st[fn.lower()][1]
        if o['parent'] and seen < 20: return find_func(o['parent'], fn, seen + 1)
        return 'missing', None
    def var_type(obj, f, name):
        n = name.lower()
        if n == 'self': return obj['name']
        for k, t in f['params'] + f['locals']:
            if k.lower() == n: return t
        o = obj
        for _ in range(20):
            if n in o['vars']: return o['vars'][n]
            if n in o['props']: return o['props'][n]
            if not o['parent'] or get(o['parent']) is None: break
            o = get(o['parent'])
        return None
    sls = [c for c in vfs if re.match(r'(_?sls|tif__0|pf__sls|qf__sls|sf__sls|_sls)', c) and not c.startswith('slsf') and not c.startswith('slso')]
    sls = [c for c in sls if os.path.basename(os.path.dirname(os.path.dirname(vfs[c][0]))) in ('SL Survival - Patches','SexLab Survival 0.716','Sexlab Survival')]
    stats = [0]; percls = collections.Counter(); findings = collections.defaultdict(set); nopex = collections.defaultdict(set)
    for c in sorted(sls):
        obj = get(c)
        if obj is None: continue
        for sname, st in obj['states'].items():
            for fl, (fname, f) in st.items():
                for op, a in f['calls']:
                    if op == 0x19: tcls, tfn, args = a[0][1], a[1][1], a[3:]
                    elif op == 0x17:
                        tfn = a[0][1]; selfv = a[1]; args = a[3:]
                        if selfv[0] != 1: continue
                        tcls = var_type(obj, f, selfv[1])
                        if tcls is None or tcls.endswith('[]'): continue
                    else: continue
                    where = f'{obj["name"]}.{fname}' + (f'[{sname}]' if sname else '')
                    if tcls.lower() in ('form','objectreference','actor') and False: pass
                    stats[0] += 1; percls[tcls.lower()] += 1
                    if tcls.lower() == obj['name'].lower(): res, tf = find_func(c, tfn)
                    else: res, tf = find_func(tcls, tfn)
                    if res == 'nopex': nopex[tcls.lower()].add(where); continue
                    if res == 'missing': findings[(tcls, tfn, 'MISSING')].add(where); continue
                    if len(tf['params']) != len(args):
                        findings[(tcls, tfn, f'ARGC {len(args)} vs {len(tf["params"])}')].add(where)
    print('calls checked', stats[0], 'scripts', len(sls)); print(percls.most_common(40))
    for k, v in sorted(findings.items()):
        print(f'{k[2]:14} {k[0]}.{k[1]}  <- {sorted(v)[:4]}{" +%d" % (len(v)-4) if len(v)>4 else ""}  [{vfs.get(k[0].lower(),("","?"))[1]}]')
    print('\nclasses without a loose pex (BSA or not installed):')
    for k, v in sorted(nopex.items()): print(' ', k, len(v))

if __name__ == '__main__':
    main()
