# SLS Begging Conditions 1.2.0

Condition patch for SexLab Survival's begging dialogue (quest _SLS_Begging). Overrides 19 dialogue lines of
SL Survival.esp; adds no records and changes no text.

A player topic shows when any one of its lines passes, and SLS's lines only checked who the speaker is (beggar,
bandit, slave...). Each change below therefore goes onto every line of the topic.

- "Please, I need help." - only unique NPCs (IsUnique), and only when at least one of its nine requests can show
  (1.1.0): hungry, thirsty, skooma addiction 30+, under 500 gold, Milk Mod Economy installed, nothing worn on the body,
  nothing worn on the feet, or a slave / beggar speaker (their lactacid and boots lines have no player condition).
  Before, the line opened an empty submenu. Written as four OR-groups, since a condition list is an AND of OR-groups.
- "Please! I need something to wear." - only while the player wears nothing that covers the body (no ArmorCuirass,
  no ClothingBody worn). One line used to check the inventory instead, so a naked player carrying clothes in the bag
  could not ask; that check is gone.
- "Can you spare some gold?" - only with less than 500 gold.
- Skooma lines - every line of each topic now needs the addiction its main line already needed (SL Survival's
  Skooma Whore pool: 30 / 70 / 180). Without SexLab Skooma Whore the pool is 0 and the lines never show.

1.2.0:
- Beggar NPCs (FavorJobsBeggarsFaction) have nothing to give: of the nine requests only the skooma ones remain. Their
  food, drink, clothes, lactacid, gold and boots lines never show; "Please, I need help." shows for a beggar only with
  a skooma addiction (pool 30+).
- Slave NPCs: the lactacid line needs Milk Mod Economy and the boots line needs bare feet, like everyone else's
  (SLS gave them no player condition at all).
- A worn Devious Devices suit (zad_DeviousSuit: hobble dress, catsuit, straitjacket dress) counts as clothing - such
  outfits carry neither ArmorCuirass nor ClothingBody, so "I need something to wear" showed in a hobble dress.
- The root line's condition is rebuilt from these rules (six OR-groups).

Masters: Skyrim.esm, Update.esm, Devious Devices - Assets.esm, SL Survival.esp. Load after SL Survival.esp.

## 1.3.0 (2026-10-08)
"Please, I need help." (root INFO 01C008) is no longer offered to your own Diary of Mine slaves and slavers:
first condition `GetInFaction(DOMActorFaction 58FC50:DiaryOfMine.esm) == 0` (AND before the existing CNF).
Adds DiaryOfMine.esm as a master. Previous ESP: work\backups\SLS_begging\SLS Begging Conditions_before_DoM_2026-10-08.esp.

## Contents as of 2026-10-12
The plugin overrides 28 INFO records: the 19 begging lines above, plus the begging root with the six OR groups, plus
five greeting lines whose fragments slap the player (0974BC, 0974C1, 0974C4, 0974C7, 09BB16) with
`GetInFaction(DOMActorFaction) == 0` (1.3.0). The DoM rule for those slaps is owned by SexLab Survival Framework
(`DomGuard`: it adds `DOMActorFaction == 0` and `DOMBeingCaptured == 0` in memory to seven lines, including 0201A0
and 03E57A, which this plugin does not touch); the five conditions here are a harmless duplicate of the first half.
