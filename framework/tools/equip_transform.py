"""Stage 2 (equip hub): turn the player-alias OnObjectEquipped / OnObjectUnequipped events of the SLS subscribers into
plain functions SLSFW_Equipped / SLSFW_Unequipped that SLSurvivalFramework.dll calls only when the item matters.

An event the script still defines is dispatched by the engine on every equip, even with an empty body, so the
events are renamed, not guarded. Every state keeps its own body; the empty state gets an empty stub where it had
none (Papyrus requires a state function to exist in the empty state). Scripts listed in DROP had only empty
handlers: those are deleted.

Source: the crajjjj 0.716 repo (the installed winner), unless papyrus/source already holds an edited copy.
Untouched copies go to papyrus/orig for diffs. Line endings are preserved.

Run: python tools/equip_transform.py
"""
import pathlib
import re
import shutil

ROOT = pathlib.Path(__file__).resolve().parent.parent
REPO = pathlib.Path(r'C:\Modding\MO2\work\SLS_integration\sls_repo\scripts\source')
SRC = ROOT / 'papyrus' / 'source'
ORIG = ROOT / 'papyrus' / 'orig'

RENAME = ['SLS_Main', 'SLS_MinAv', '_SLS_LicBikiniCurse', '_SLS_GuardWarnArmorEquipped', '_SLS_GuardWarnWeapEquipped',
          '_SLS_GuardWarnDrugsAlias', '_SLS_OrgasmFatigueAlcohol', 'SLS_GluttonyPlayerAlias', 'SLS_DclBondageAdventure',
          '_SLS_MapAndCompassAlias', '_SLS_CoverMyself', '_SLS_CombatEquip', '_SLS_DeviousEffects', '_SLS_TollDodgeDisguise',
          '_SLS_AmputationHelplessAlias', '_SLS_HalfNakedCover']
DROP = ['SLS_BeggingPlayerAlias']

EVENT = re.compile(r'^(\s*)Event\s+OnObject(Un)?Equipped\s*\(([^)]*)\)(.*)$', re.I)
STATE = re.compile(r'^\s*(?:auto\s+)?state\s+(\w+)', re.I)
ENDSTATE = re.compile(r'^\s*endstate\b', re.I)
ENDEVENT = re.compile(r'^(\s*)EndEvent\b(.*)$', re.I)


def source_for(name):
    own = SRC / f'{name}.psc'
    if own.exists():
        return own
    match = next(p for p in REPO.glob('*.psc') if p.stem.lower() == name.lower())
    shutil.copy(match, ORIG / f'{name}.psc')
    shutil.copy(match, own)
    return own


def transform(name, drop):
    path = source_for(name)
    text = path.read_bytes().decode('latin1')
    nl = '\r\n' if '\r\n' in text else '\n'
    lines = text.split(nl)
    out, state, inside, removed, renamed = [], '', None, 0, 0
    empty_has = {'SLSFW_Equipped': False, 'SLSFW_Unequipped': False}
    for line in lines:
        if inside is None:
            m = STATE.match(line)
            if m:
                state = m.group(1)
            elif ENDSTATE.match(line):
                state = ''
            m = EVENT.match(line)
            if m:
                fn = 'SLSFW_Unequipped' if m.group(2) else 'SLSFW_Equipped'
                inside = fn
                if drop:
                    removed += 1
                    continue
                renamed += 1
                if not state:
                    empty_has[fn] = True
                out.append(f'{m.group(1)}Function {fn}({m.group(3)}){m.group(4)}')
                continue
            out.append(line)
        else:
            m = ENDEVENT.match(line)
            if m:
                inside = None
                if not drop:
                    out.append(f'{m.group(1)}EndFunction{m.group(2)}')
                continue
            if not drop:
                out.append(line)
    assert inside is None, f'{name}: unterminated event'
    if not drop:
        stubs = [fn for fn, has in empty_has.items() if not has]
        if stubs:
            out.append('')
            out.append('; called by SLSurvivalFramework.dll (equip hub) in states that act on equips; nothing to do here')
            for fn in stubs:
                out.append(f'Function {fn}(Form akBaseObject, ObjectReference akReference)')
                out.append('EndFunction')
    path.write_bytes(nl.join(out).encode('latin1'))
    return renamed, removed


for name in RENAME:
    print(f'{name:32} renamed={transform(name, False)[0]}')
for name in DROP:
    print(f'{name:32} removed={transform(name, True)[1]}')
