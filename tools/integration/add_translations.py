# Append the keys of work\SLS_integration\translations_extra.tsv to every SL Survival translation file (UTF-16 LE)
# that does not have them yet. English text everywhere: SkyUI shows the raw $key when a language file lacks it.
# Rerunnable: present keys are left alone.  Run: python -I add_translations.py
import os

TSV = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'translations_extra.tsv')
DIR = r'C:\Modding\MO2\mods\SexLab Survival Repack\interface\translations'

extra = [l.rstrip('\r\n').split('\t', 1) for l in open(TSV, encoding='utf-8') if '\t' in l]
for name in sorted(os.listdir(DIR)):
    if not name.lower().startswith('sl survival_') or not name.lower().endswith('.txt'):
        continue
    path = os.path.join(DIR, name)
    text = open(path, 'rb').read().decode('utf-16')
    have = {l.split('\t', 1)[0].strip().lower() for l in text.splitlines() if '\t' in l}
    add = [f'{k}\t{v}' for k, v in extra if k.lower() not in have]
    if not add:
        print(f'{name}: up to date')
        continue
    sep = '' if text.endswith(('\n', '\r')) else '\r\n'
    text += sep + '\r\n'.join(add) + '\r\n'
    open(path, 'wb').write(text.encode('utf-16'))  # writes the BOM, like the originals
    print(f'{name}: +{len(add)}')
