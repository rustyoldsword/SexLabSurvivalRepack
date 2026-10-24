# SLS bikini distribution list (BikiniArmors.json, read by sls_mcm.BuildBikiniLists): 148 entries point at
# "(Pumpkin)-TEWOBA...esp", which this build does not have, so every list build ends in a "could not be found" box.
# Writes a copy without them into SL Survival - Patches (wins over both SLS folders). Everything else is kept as is.
# Run: python -I fix_bikini_lists.py
import json
import os

SRC = r'C:\Modding\MO2\mods\SexLab Survival 0.716\SKSE\Plugins\StorageUtilData\SL Survival\BikiniArmors.json'
DST = r'C:\Modding\MO2\mods\SL Survival - Patches\SKSE\Plugins\StorageUtilData\SL Survival\BikiniArmors.json'
MISSING = 'TEWOBA'

data = json.load(open(SRC, encoding='utf-8'))
dropped = 0
for key, forms in data['formList'].items():
    keep = [f for f in forms if MISSING not in f.split('|', 1)[-1]]
    dropped += len(forms) - len(keep)
    data['formList'][key] = keep
os.makedirs(os.path.dirname(DST), exist_ok=True)
with open(DST, 'w', encoding='utf-8', newline='') as f:
    json.dump(data, f, indent='\t')
print(f'dropped {dropped} TEWOBA entries -> {DST}')
