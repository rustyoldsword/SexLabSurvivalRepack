# 3.0.2 stage 3: guard punishment switches in sls_mcm.psc (Misogyny & Inequality page). Idempotent source edit.
# Values live on _SLS_LicenceUtil (GuardPunish*), read by the dialogue conditions; OIDs in StorageUtil like the
# neighbouring options. Turning a guard behaviour off now also stops guard approaches that are already under way.
import sys

P = r'C:\Modding\MO2\work\SLS_integration\src\sls_mcm.psc'
t = open(P, encoding='utf-8', errors='surrogateescape', newline='').read()
nl = '\r\n' if '\r\n' in t else '\n'
if 'GuardPunishDrugsOID' in t:
    sys.exit('already patched')

NAMES = ['Drugs', 'Devices', 'Kennel', 'Clothes', 'Milk', 'Confine', 'Tattoo']


def rep(old, new):
    global t
    if t.count(old) != 1:
        sys.exit('anchor not unique: ' + old[:80])
    t = t.replace(old, new)


# page: after the guard behaviour block
anchor = 'StorageUtil.SetIntValue(Self, "GuardBehavArmorEquipAnyArmorOID", AddToggleOption("$SLS_GuardBehavArmorEquipAnyArmor", StorageUtil.GetIntValue(Self, "GuardBehavArmorEquipAnyArmor", Missing = 0), HardMode))' + nl
page = '\t\tAddEmptyOption()' + nl + '\t\tAddHeaderOption("$SLS_hGuardPunish")' + nl
for n in NAMES:
    page += f'\t\tStorageUtil.SetIntValue(Self, "GuardPunish{n}OID", AddToggleOption("$SLS_GuardPunish{n}", LicUtil.GuardPunish{n}, HardMode))' + nl
rep(anchor, anchor + page)

# select: first in the chain, which is not split by page
anchor = '\tElseIf (option == ExportSettingsOID_T)' + nl + '\t\tSaveSettings()' + nl
sel = ''
for n in NAMES:
    sel += (f'\tElseIf Option == StorageUtil.GetIntValue(Self, "GuardPunish{n}OID")' + nl +
            f'\t\tLicUtil.GuardPunish{n} = !LicUtil.GuardPunish{n}' + nl +
            f'\t\tSetToggleOptionValue(Option, LicUtil.GuardPunish{n})' + nl)
rep(anchor, anchor + sel)

# highlight: before the page split
anchor = 'event OnOptionHighlight(int option)' + nl
hl = '\tIf GuardPunishInfo(option) ; 3.0.2 guard punishments' + nl + '\t\tReturn' + nl + '\tEndIf' + nl
rep(anchor, anchor + hl)
fn = 'Bool Function GuardPunishInfo(Int Option)' + nl
for n in NAMES:
    fn += (f'\tIf Option == StorageUtil.GetIntValue(Self, "GuardPunish{n}OID")' + nl +
           f'\t\tSetInfoText("$SLS_GuardPunish{n}_Info")' + nl + '\t\tReturn true' + nl + '\tEndIf' + nl)
fn += '\tReturn false' + nl + 'EndFunction' + nl + nl
rep('event OnOptionHighlight(int option)' + nl, fn + 'event OnOptionHighlight(int option)' + nl)

# export / import
anchor = '\t\t_SLS_GuardBehavWeapDropEn.SetValueInt(JsonUtil.GetIntValue("SL Survival/Settings.json", "_SLS_GuardBehavWeapDropEn", missing = 1))' + nl
imp = ''.join(f'\t\tLicUtil.GuardPunish{n} = JsonUtil.GetIntValue("SL Survival/Settings.json", "GuardPunish{n}", missing = 1)' + nl for n in NAMES)
rep(anchor, anchor + imp)
anchor = '\t\tJsonUtil.SetIntValue("SL Survival/Settings.json", "_SLS_GuardBehavWeapDropEn", _SLS_GuardBehavWeapDropEn.GetValueInt())' + nl
exp = ''.join(f'\t\tJsonUtil.SetIntValue("SL Survival/Settings.json", "GuardPunish{n}", LicUtil.GuardPunish{n} as Int)' + nl for n in NAMES)
rep(anchor, anchor + exp)

# turning a behaviour off stops approaches already running (they used to finish into a punishment)
stop = '\t\tUtil.StopAllGuardWarnApproachQuests(None, DoCooldown = false) ; 3.0.2: also the approach already under way' + nl
for fn_name, stop_line in [
        ('ToggleGuardBehavLockpick', '\t\t_SLS_GuardWarnLockpickQuest.Stop()' + nl),
        ('ToggleGuardBehavDrugs', '\t\t_SLS_GuardWarnDrugsQuest.Stop()' + nl),
        ('ToggleGuardBehavWeapDrawn', '\t\t_SLS_GuardWarnWeapDrawnQuest.Stop()' + nl),
        ('ToggleGuardBehavWeapEquip', '\t\t_SLS_GuardWarnWeapEquippedQuest.Stop()' + nl),
        ('ToggleGuardBehavArmorEquip', '\t\t_SLS_GuardWarnArmorEquippedQuest.Stop()' + nl)]:
    start = t.index('Function ' + fn_name + '()')
    end = t.index('EndFunction', start)
    body = t[start:end]
    if body.count(stop_line) != 1:
        sys.exit('stop line not found in ' + fn_name)
    t = t[:start] + body.replace(stop_line, stop_line + stop) + t[end:]

open(P, 'w', encoding='utf-8', errors='surrogateescape', newline='').write(t)
print('patched')
