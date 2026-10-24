"""Which enabled mods ship SlaveTats packs / overlay textures, and do they carry UBE variants?"""
import os

MODS = r'C:\Modding\MO2\mods'
mods = [l[1:].strip() for l in open(r'C:\Modding\MO2\profiles\Default\modlist.txt', encoding='utf8') if l.startswith('+')]
for m in mods:
    tot = ube = 0
    for dp, dn, fn in os.walk(os.path.join(MODS, m)):
        low = dp.lower().replace(os.sep, '/')
        if '/slavetats' in low:
            for f in fn:
                if f.lower().endswith('.dds'):
                    tot += 1
                    if '/slavetats/ube' in low:
                        ube += 1
    if tot:
        print(f'{m}: slavetats dds={tot}, under slavetats/UBE={ube}')
