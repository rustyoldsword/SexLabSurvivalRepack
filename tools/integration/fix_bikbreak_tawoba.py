# SLS bikini breakdown at the forge (_SLS_BikiniBreak.BreakdownArmor) takes the source armor first and then looks the
# bikini parts up in BikBreak\BuiltIn\*.json, which name the old plugin "TheAmazingWorldOfBikiniArmor.esp". This build
# has "The Amazing World of Bikini Armors REMASTERED.esp" (same FormIDs - all 487 resolved through houseCARL on
# 2026-10-24), so every breakdown ate the armor and gave nothing. Writes corrected copies into SL Survival - Patches,
# which wins over both SLS folders in MO2. Only the plugin name changes.
# Run: python -I fix_bikbreak_tawoba.py
import glob
import os

OLD = 'TheAmazingWorldOfBikiniArmor.esp'
NEW = 'The Amazing World of Bikini Armors REMASTERED.esp'
SRC = r'C:\Modding\MO2\mods\SexLab Survival 0.716\SKSE\Plugins\StorageUtilData\SL Survival\BikBreak'
DST = r'C:\Modding\MO2\mods\SL Survival - Patches\SKSE\Plugins\StorageUtilData\SL Survival\BikBreak'

written = 0
for path in glob.glob(os.path.join(SRC, '**', '*.json'), recursive=True):
    text = open(path, encoding='utf-8').read()
    if OLD not in text:
        continue
    out = os.path.join(DST, os.path.relpath(path, SRC))
    os.makedirs(os.path.dirname(out), exist_ok=True)
    with open(out, 'w', encoding='utf-8', newline='') as f:
        f.write(text.replace(OLD, NEW))
    written += 1
print(f'{written} json written to {DST}')
