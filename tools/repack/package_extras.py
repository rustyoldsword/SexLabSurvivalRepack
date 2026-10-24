# Package the two SLS companion mods as separate FOMOD archives on the Desktop:
#   SL Survival Guards - Viking and NPC Replacer  (mods\SL Survival Guards - Viking Patch)
#   SL Survival Voice Pack                        (mods\SL Survival.esp-VoiceFiles)
# Files are hardlinked into stage\<name>\00 Main (same drive), so staging costs no space.
#   python -I package_extras.py [guards] [voice]
import os, sys, shutil, subprocess, re

M = r'C:\Modding\MO2\mods'
HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DESKTOP = os.path.join(os.path.expanduser('~'), 'Desktop')
SEVENZIP = r'C:\Program Files\7-Zip\7z.exe'
BAD = re.compile(os.environ.get('LEAK_PATTERNS', r'(?i)users[\\/]').encode())

PACKS = {
    'guards': dict(name='SL Survival Guards - Viking and NPC Replacer', version='1.0.0', src='SL Survival Guards - Viking Patch',
                   mx='-mx=7', summary='Viking armor, Skyrim Weapons Expansion weapons and unique faces for the 89 SL Survival guards (SkyPatcher).'),
    'voice': dict(name='SL Survival Voice Pack', version='1.0.0', src='SL Survival.esp-VoiceFiles',
                  mx='-mx=0', summary='Voiced dialogue for SexLab Survival: 51,013 lines in 50 vanilla voice types (two BSA archives).'),
}

INFO = '''<?xml version="1.0" encoding="utf-8"?>
<fomod>
    <Name>{name}</Name>
    <Author>SexLab Survival Repack</Author>
    <Version>{version}</Version>
    <Description>{summary}</Description>
</fomod>
'''
CONFIG = '''<?xml version="1.0" encoding="utf-8"?>
<config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://qconsulting.ca/fo3/ModConfig5.0.xsd">
    <moduleName>{name} {version}</moduleName>
    <moduleDependencies operator="And">
        <fileDependency file="SL Survival.esp" state="Active"/>
    </moduleDependencies>
    <installSteps order="Explicit">
        <installStep name="Main mod">
            <optionalFileGroups order="Explicit">
                <group name="Main mod" type="SelectAll">
                    <plugins order="Explicit">
                        <plugin name="{name}">
                            <description>{summary} See docs\\{name}__README.md.</description>
                            <files>
                                <folder source="00 Main" destination="" priority="0"/>
                            </files>
                            <typeDescriptor>
                                <type name="Required"/>
                            </typeDescriptor>
                        </plugin>
                    </plugins>
                </group>
            </optionalFileGroups>
        </installStep>
    </installSteps>
</config>
'''

def build(key):
    p = PACKS[key]
    stage = os.path.join(HERE, 'stage_extras', p['name'])
    if os.path.exists(stage): shutil.rmtree(stage)
    main = os.path.join(stage, '00 Main')
    src = os.path.join(M, p['src'])
    n = 0
    for dp, dn, fn in os.walk(src):
        for f in fn:
            rel = os.path.relpath(os.path.join(dp, f), src)
            if rel.lower() == 'meta.ini': continue
            dst = os.path.join(main, rel)
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            os.link(os.path.join(dp, f), dst); n += 1
    docs = os.path.join(main, 'docs'); os.makedirs(docs, exist_ok=True)
    shutil.copy2(os.path.join(HERE, 'docs', p['name'] + '__README.md'), docs)
    os.makedirs(os.path.join(stage, 'fomod'))
    open(os.path.join(stage, 'fomod', 'info.xml'), 'w', encoding='utf-8').write(INFO.format(**p))
    open(os.path.join(stage, 'fomod', 'ModuleConfig.xml'), 'w', encoding='utf-8').write(CONFIG.format(**p))
    # privacy sweep over everything except the large binary archives
    hits = []
    for dp, dn, fn in os.walk(stage):
        for f in fn:
            if f.lower().endswith(('.bsa', '.dds', '.nif', '.tri')): continue
            full = os.path.join(dp, f); m = BAD.search(open(full, 'rb').read())
            if m: hits.append(f'{os.path.relpath(full, stage)}: {m.group(0)!r}')
    if hits: print('PRIVATE STRINGS', *hits, sep='\n  '); sys.exit(1)
    out = os.path.join(DESKTOP, f'{p["name"]} {p["version"]}.7z')
    if os.path.exists(out): os.remove(out)
    subprocess.check_call([SEVENZIP, 'a', '-t7z', p['mx'], '-mmt=on', out, '.\\*'], cwd=stage, stdout=subprocess.DEVNULL)
    print(f'{p["name"]}: {n} files -> {out} ({os.path.getsize(out) / 1e6:.0f} MB)')

for k in (sys.argv[1:] or PACKS): build(k)
