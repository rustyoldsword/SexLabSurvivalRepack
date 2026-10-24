# SLS Begging Conditions 1.2.0 ops, applied on top of the 1.0 ESP (work\backups\SLS_begging\SLS Begging Conditions.1.0.esp).
#
# Beggar speakers (FavorJobsBeggarsFaction): a beggar has nothing to give, so of the nine requests only the skooma ones
# stay. The beggar-only lines of food, drink, clothes, lactacid, gold and boots get "speaker is not a beggar" - a
# contradiction, so they never pass - and the naked-speaker clothes line (no beggar check of its own) gets it too.
# Slave speakers: their lactacid and boots lines had no player condition (always shown); they now need what the
# ordinary lines need - MME installed / nothing worn on the feet.
#
# Root "Please, I need help." (INFO 01C008): shown only when some child topic can show, written as CNF because a
# condition list is an AND of OR-groups:
#   beggar  -> skooma pool >= 30                          : (not beggar | pool >= 30)
#   other   -> hungry | thirsty | pool >= 30 | gold < 500 | MME | naked | barefoot
#              naked = no cuirass AND no body clothing AND no DD suit (hobble dress, catsuit: neither keyword),
#              barefoot = no boots AND no feet clothing, so six OR-groups:
#              (beggar | hungry | thirsty | pool | gold | MME | naked-term | barefoot-term)
import json

PLAYER = "000014:Skyrim.esm"
MAIN = "000D64:SL Survival.esp"
NEEDS = "03AF93:SL Survival.esp"
BEGGARS = "060028:Skyrim.esm"
SLS = "SL Survival.esp"


def cond(value, op, data, flag_or=False):
    c = {"type": "ConditionFloat", "fields": {"ComparisonValue": value, "CompareOperator": op},
         "sets": [{"path": "Data", "compose": data}]}
    if flag_or:
        c["fields"]["Flags"] = "OR"
    return c


def vmvar(quest, var):
    return {"type": "GetVMQuestVariableConditionData", "fields": {"Quest": quest, "VariableName": var}}


def worn(kw):
    return {"type": "WornHasKeywordConditionData", "fields": {"Keyword": kw, "RunOnType": "Reference", "Reference": PLAYER}}


beggar = {"type": "GetInFactionConditionData", "fields": {"Faction": BEGGARS}}
pool30 = ("30", "GreaterThanOrEqualTo", vmvar(MAIN, "::SwPhysicalPool_var"))
other = [
    ("1", "EqualTo", beggar),
    ("1", "EqualTo", vmvar(NEEDS, "::BegIsHungry_var")),
    ("1", "EqualTo", vmvar(NEEDS, "::BegIsThirsty_var")),
    pool30,
    ("500", "LessThan", {"type": "GetGoldConditionData", "fields": {"RunOnType": "Reference", "Reference": PLAYER}}),
    ("1", "EqualTo", vmvar(MAIN, "::MmeInstalled_var")),
]
naked = ["06C0EC:Skyrim.esm", "0A8657:Skyrim.esm", "02AFA3:Devious Devices - Assets.esm"]  # ArmorCuirass, ClothingBody, zad_DeviousSuit
barefoot = ["06C0ED:Skyrim.esm", "10CD12:Skyrim.esm"]  # ArmorBoots, ClothingFeet

root = [cond("1", "NotEqualTo", beggar, True), cond(*pool30)]
for n in naked:
    for f in barefoot:
        root += [cond(v, op, d, True) for v, op, d in other]
        root.append(cond("0", "EqualTo", worn(n), True))
        root.append(cond("0", "EqualTo", worn(f)))  # closes the OR-group

ops = [{"formid": f"01C008:{SLS}", "field_path": "Conditions", "op": "Add", "composes": root}]

not_beggar = cond("1", "NotEqualTo", beggar)
# beggar-only lines: food 023D19, drink 023D1A, clothes 023D1B, lactacid 023D1D, gold 023D1E, boots 059CC0;
# the naked-speaker clothes line 01C571
for info in ["023D19", "023D1A", "023D1B", "023D1D", "023D1E", "059CC0", "01C571"]:
    ops.append({"formid": f"{info}:{SLS}", "field_path": "Conditions", "op": "Add", "compose": not_beggar})
# slave lines: lactacid 01F6C5, boots 059CBF
ops.append({"formid": f"01F6C5:{SLS}", "field_path": "Conditions", "op": "Add",
            "compose": cond("1", "EqualTo", vmvar(MAIN, "::MmeInstalled_var"))})
ops.append({"formid": f"059CBF:{SLS}", "field_path": "Conditions", "op": "Add",
            "composes": [cond("0", "EqualTo", worn(k)) for k in barefoot]})

# clothes lines: a DD suit (hobble dress...) covers the body too
for info in ["01C00E", "05E914", "01C571", "01F6C3", "0201A0", "0201A1", "023D1B"]:
    ops.append({"formid": f"{info}:{SLS}", "field_path": "Conditions", "op": "Add", "compose": cond("0", "EqualTo", worn(naked[2]))})

json.dump(ops, open(r"C:\Modding\MO2\work\SLS_begging\root_ops.json", "w"), indent=1)
print(len(root), "root conditions,", len(ops), "ops")
