# Owner's new-game defaults for SLS (pack 1, 2026-10-24). Each option is changed in all three places that carry a
# default: the property/variable initializer (new game), SetSliderOptions Default= / the MCM reset (Default button),
# and missing= in LoadSettings (JSON import without the key).
#   horse 6000 -> 3000; gold weight 0.01 -> 0.001; Simply Knock slavery 3 (json 25) -> 0 (no SimpleSlavery/SD here);
#   stash thieves take 25 -> 8 items; easy-bed traps on -> off (needs DCL, otherwise only a message box);
#   fast travel ban in toll cities on -> off (SMI already bans fast travel, SLS never turns it back on);
#   creature content: Default button and import -> on (new games switch it on from _SLS_MQ101Kicker);
#   bikini drops city/town/khajiit/chest/ornate 30/16/12/6/10 -> 6/4/4/2/3 (about 21 bikinis per city restock).
# Run: python -I set_mcm_defaults_2026_10_24.py
P = r'C:\Modding\MO2\work\SLS_integration\src\sls_mcm.psc'

EDITS = [
    ('Int SurvivalHorseCost = 6000', 'Int SurvivalHorseCost = 3000'),
    ('Value = SurvivalHorseCost, Default = 6000.0', 'Value = SurvivalHorseCost, Default = 3000.0'),
    ('"SurvivalHorseCost", missing = 6000)', '"SurvivalHorseCost", missing = 3000)'),
    ('Float Property GoldWeight = 0.01 Auto Hidden', 'Float Property GoldWeight = 0.001 Auto Hidden'),
    ('Value = GoldWeight, Default = 0.01,', 'Value = GoldWeight, Default = 0.001,'),
    ('"GoldWeight", missing = 0.01)', '"GoldWeight", missing = 0.001)'),
    ('Float Property KnockSlaveryChance = 3.0 Auto Hidden', 'Float Property KnockSlaveryChance = 0.0 Auto Hidden'),
    ('Value = KnockSlaveryChance, Default = 3.0,', 'Value = KnockSlaveryChance, Default = 0.0,'),
    ('"KnockSlaveryChance", missing = 25.0)', '"KnockSlaveryChance", missing = 0.0)'),
    ('Float Property StealXItems = 25.0 Auto Hidden', 'Float Property StealXItems = 8.0 Auto Hidden'),
    ('Value = StealXItems, Default = 25.0,', 'Value = StealXItems, Default = 8.0,'),
    ('"StealXItems", missing = 25.0)', '"StealXItems", missing = 8.0)'),
    ('Bool Property EasyBedTraps = true Auto Hidden', 'Bool Property EasyBedTraps = false Auto Hidden'),
    ('\t\tEasyBedTraps = true\n', '\t\tEasyBedTraps = false\n'),
    ('"EasyBedTraps", missing = 1)', '"EasyBedTraps", missing = 0)'),
    ('Bool Property FastTravelDisable = true Auto Hidden', 'Bool Property FastTravelDisable = false Auto Hidden'),
    ('\t\tFastTravelDisable = true\n', '\t\tFastTravelDisable = false\n'),
    ('"FastTravelDisable", missing = 1)', '"FastTravelDisable", missing = 0)'),
    ('\t\tInit.SlsCreatureEvents = false\n', '\t\tInit.SlsCreatureEvents = true\n'),
    ('Int BikiniDropsVendorCity = 30', 'Int BikiniDropsVendorCity = 6'),
    ('Int BikiniDropsVendorTown = 16', 'Int BikiniDropsVendorTown = 4'),
    ('Int BikiniDropsVendorKhajiit = 12', 'Int BikiniDropsVendorKhajiit = 4'),
    ('Int BikiniDropsChest = 6', 'Int BikiniDropsChest = 2'),
    ('Int BikiniDropsChestOrnate = 10', 'Int BikiniDropsChestOrnate = 3'),
    ('Value = BikiniDropsVendorCity, Default = 30.0,', 'Value = BikiniDropsVendorCity, Default = 6.0,'),
    ('Value = BikiniDropsVendorTown, Default = 16.0,', 'Value = BikiniDropsVendorTown, Default = 4.0,'),
    ('Value = BikiniDropsVendorKhajiit, Default = 12.0,', 'Value = BikiniDropsVendorKhajiit, Default = 4.0,'),
    ('Value = BikiniDropsChest, Default = 6.0,', 'Value = BikiniDropsChest, Default = 2.0,'),
    ('Value = BikiniDropsChestOrnate, Default = 10.0,', 'Value = BikiniDropsChestOrnate, Default = 3.0,'),
    ('"BikiniDropsVendorCity", missing = 30)', '"BikiniDropsVendorCity", missing = 6)'),
    ('"BikiniDropsVendorTown", missing = 16)', '"BikiniDropsVendorTown", missing = 4)'),
    ('"BikiniDropsVendorKhajiit", missing = 12)', '"BikiniDropsVendorKhajiit", missing = 4)'),
    ('"BikiniDropsChest", missing = 6)', '"BikiniDropsChest", missing = 2)'),
    ('"BikiniDropsChestOrnate", missing = 10)', '"BikiniDropsChestOrnate", missing = 3)'),
]

s = open(P, encoding='utf-8', errors='surrogateescape', newline='').read()
crlf = '\r\n' in s
if crlf:
    s = s.replace('\r\n', '\n')
for old, new in EDITS:
    n = s.count(old)
    if n != 1:
        raise SystemExit(f'expected 1 x {old!r}, found {n}')
    s = s.replace(old, new)
# creature content on JSON import: two identical lines
old = '"Init.SlsCreatureEvents", missing = 0)'
if s.count(old) != 2:
    raise SystemExit(f'expected 2 x {old!r}, found {s.count(old)}')
s = s.replace(old, '"Init.SlsCreatureEvents", missing = 1)')
if crlf:
    s = s.replace('\n', '\r\n')
open(P, 'w', encoding='utf-8', errors='surrogateescape', newline='').write(s)
print(f'{len(EDITS) + 2} edits applied')
