SL Survival - cleaned plugin + SLS SkyPatcher Patch (2026-10-04)

SL Survival.esp (SexLab Survival 0.716) is an LE plugin never resaved in the SE Creation Kit (all records form 43).
It baked its additions into stale LE copies of vanilla records, and because it loads late those copies reverted
USSEP, USMP, Dragonborn, ArmorFractionReplacer, Trouble of Heroine and HeelsFix changes.

1. SL Survival.esp in this folder is a CLEANED COPY that overrides the one in "SexLab Survival 0.716" (keep this
   folder above it in MO2). 128 records were dropped by byte surgery; the other 5031 records are byte-identical to
   the original. Dropped:
   - 21 playable + vampire races (only addition: the Inequality ability),
   - 97 merchant / treasure chests (only additions: SLS items),
   - 6 VendorGold leveled lists, the travelling misc merchant NPC (only additions: SLS stock),
   - Iron Dagger (dirty copy), WEQuestNode (nulled Dragonborn's story-manager link),
   - RiftenCitySouth (empty cell-header override).
   Rebuild: work\SLS_integration\tools\clean_esp.py <original> <out> work\SLS_integration\clean\drop_ids.txt
2. SKSE\Plugins\SkyPatcher\{race,container,leveledList,npc}\SLS SkyPatcher Patch\SL Survival.esp.ini put those
   additions back at runtime on top of whatever record wins (self-gated on SL Survival.esp). Vendor gold lists also get
   "Use All", as SLS had it, so vendors always get their gold plus the SLS stock.

Kept as SLS has them (intended SLS behaviour, nothing else edits them, no SkyPatcher equivalent): the guard quests
WICastMagic03 / WIRemoveItem01 and their packages/story-manager nodes, house purchase dialogue, VoiceSprint /
VoiceMakeEthereal scripts, MammothCheese chest guard, civil-war map activators, toll-gate doors/locks, RoomCost.
The six other exterior cell headers stay because SLS places its toll-gate objects in them; their fields match the
other mods' versions (only LE padding differs).
Not converted to form 44: a header bump without a CK resave is not a conversion (see the model-hash layout trap).

Toll collector dialogue fix (2026-10-21)
After paying the toll the collector still offered "What's going on here? Why's the gate locked?" and "I can't afford
the toll but I really need to leave now." Only the "Pay toll" line checked that the toll was not paid yet. The same
condition (GetVMQuestVariable _SLS_Main ::IsTollPaid_var == 0) is now also on INFOs 00A0E7, 01AA4B, 01AA4D, 0A7DA2.
Inserted byte by byte, so masters and FormIDs are unchanged and the AutoSEQ .seq stays valid.
Rebuild: work\SLS_integration\tools\add_tollpaid_condition.py <in.esp> <out.esp>
