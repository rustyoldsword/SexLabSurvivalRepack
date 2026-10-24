import os, sys, collections
M = r'C:\Modding\MO2\mods'
for d in sys.argv[1:]:
    root = os.path.join(M, d); c = collections.Counter(); sz = collections.Counter()
    for dp, dn, fn in os.walk(root):
        for f in fn:
            rel = os.path.relpath(os.path.join(dp, f), root).split(os.sep)
            key = os.sep.join(rel[:2]) if len(rel) > 2 else (rel[0] if len(rel) == 2 else '.')
            c[key.lower()] += 1; sz[key.lower()] += os.path.getsize(os.path.join(dp, f))
    print('===', d)
    for k in sorted(c): print(f'{c[k]:6} {sz[k]/1e6:9.1f}MB  {k}')
