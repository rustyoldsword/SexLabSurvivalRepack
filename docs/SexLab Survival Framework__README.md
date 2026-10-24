# SexLab Survival Framework 0.7.4

Native core for SexLab Survival (SLS 0.716). It moves the checks SLS runs in Papyrus on every walk, equip,
item, menu and hit into an SKSE plugin, and calls the SLS script only when something actually happens.
SLS's scripts keep their names, properties and functions. The mod is switched off as a whole: disable it and
every script is plain SLS again. Its scripts expect the DLL; if it fails to load, SLS says so on game load.

## Requirements

- SexLab Survival 0.716 and SL Survival - Patches
- SKSE, Address Library for SKSE Plugins (SE 1.5.97 or AE 1.6.x)

Place this mod **above** (after) SL Survival - Patches so its scripts win.

## Install, check, remove

- **Install:** with the mod manager (FOMOD). Core is always installed; "Gentler Steep Fall" and the TNG patch are
  optional. Place the mod after SL Survival - Patches.
- **Check the install:** `docs\SexLab Survival Framework__manifest.json` lists every file with its SHA-256;
  `tools\verify.ps1` (in the source tree) reports missing or changed files and files another mod overrides in MO2.
- **Smoke test after installing or updating** (a new game is fine):
  1. `SKSE\SLSurvivalFramework.log` has "SLSurvivalFramework loaded" and no "failed" lines.
  2. `SLSFW.Report()` (DevBench or any Papyrus console) lists gates, equip, guard watch and messages; with Vitals HUD
     showing SLS messages it says "claimed".
  3. Walk to Whiterun's gate without paying: the gate is locked at once; pay the toll: both doors open.
  4. Draw a weapon in town without a weapon licence: the guard warning still comes.
- **Remove:** disable the whole mod. Every SLS script is plain SLS again; the framework keeps nothing in the save.

## Version 0.7.4 — load-transition crash and audit fixes

- **Crash fixed** (twice seen, 2026-10-10 and 2026-10-11: `Equip::Tick -> Bridge::Find(alias)` right after a load or
  a new game). The equip hub and the nudity relay kept pointers to SL Survival's quest aliases from game start; the
  engine frees and re-creates those objects when quests revert on a load, and the first tick after the load used a
  dead pointer. Aliases are now looked up on their quest at every use, and every tick and the equip sink wait until the
  game has settled (the player has 3D and a cell, no loading screen). The "quest running" test also used CommonLib's
  `IsRunning()`, which is true for a quest that never started; it is `IsEnabled()` now, so stopped quests' scripts are
  no longer called.
- Gates v2: right after a load the framework compared the gate inputs against an empty baseline and ran a recheck
  before SL Survival's own load code had set the toll state, so a town's gates could sit locked for a few seconds. The
  first reading after a load is now the baseline.
- Diary of Mine slap guard: checks the lines once a second and stops once all are guarded (was every 100 ms for the
  whole session).
- Escort follower count: reads the life state and the faction list directly (the virtual `IsDead` / `IsInFaction`
  calls lied for Diary of Mine slaves).
- HUD status: the contraband scan of the inventory is cached for half a second (a HUD may ask every frame).
- A load that fails no longer triggers the post-load work; "Nearby Lost Items" is also reset on a new game.
- Not changed, on purpose: `Debug.Notification` is still replaced outright (no chaining to another plugin that
  replaces it) - reading the VM's function table through CommonLib's `ObjectTypeInfo` crashed on this setup before.
  If another plugin re-registers `Debug.Notification` after this one, SL Survival's messages fall back to the game's
  notification list; the Papyrus log then shows a second "Replacing native function Notification" line.

## Version 0.7.3 — Diary of Mine messages in the same panel

Once a HUD claims the messages (Vitals HUD 1.1.2+), `Debug.Notification` calls from Diary of Mine's scripts (`DOM*`,
and the `pahcore` it ships) go to the same panel as SL Survival's. Native mods can add a line with the export
`SLSFW_PushMessage(const char*)` (Diary Of Mine Framework does); it returns false when no HUD claimed the messages,
and the caller then shows the notification itself.

## Version 0.7.1 — residents starting inside a town

SL Survival decides whether the player is a resident (house + Property licence) only when they enter the town walls.
A game that starts inside the town (an own-house start) gets the Property licence a few seconds after arriving, so the
toll stayed due: the gates opened for the resident, but the HUD showed the toll as unpaid and the guards could still
mark it as dodged. The resident branch of `_SLS_TollUtil.OnTollDoorAttach` now also marks the toll as paid and stops
the toll-due detection. A start inside a town without a home (an inn) still owes the toll, as in SL Survival.

## Version 0.7.0 — licence violations for HUDs

`SLSFW_GetHudStatus` now also tells which missing licence the player is breaking right now: in a toll town, the
player carries what that licence covers, by SL Survival's own gate search rules (`_SLS_LicenceUtil.HasAnyContraband`):
weapons and ammo (weapon licence), light/heavy armor (armor licence; with bikini licences in use, only worn armor that
is not a bikini once a bikini licence is held), enchanted clothing, staves, spell tomes and scrolls (magic licence),
clothing (clothes licence, when SLS requires one). Items in SLS's licence exception lists and SexLabNoStrip items do
not count. Vitals HUD 1.1.0+ shows such a licence in red ("Wpn !") even in the compact panel.

## Version 0.6.0 — SL Survival status for HUDs

- `SLSFW_GetHudStatus` (DLL export, header `include\SLSFW_HudStatus.h`): licences in use with time left, the toll
  of the current town (paid, cost, inside the walls, confined to town), the curfew (hours, in effect, violation),
  the bikini and magic curses, orgasm fatigue (level, count, threshold). Read from SL Survival's own globals and
  scripts on the main thread. Vitals HUD 1.1.0 shows it under its meters.
- Gates v2: SLS decided each gate's lock when the door's cell attached, after a fixed one-second wait "for
  LocTrackCentral to update IsTollPaid" - a race between two script events, so a gate could end up locked or open
  against the toll state the guards' dialogue uses. The framework now watches the inputs of that decision (toll paid,
  inside the walls, town, lockdown and toll options, confinement) and runs SLS's own gate rules once they have been
  quiet for half a second after any change or door attach; the rules themselves are unchanged.
- SL Survival's messages for a HUD: Debug.Notification is re-registered. Once a HUD claims the messages
  (SLSFW_ClaimMessages - Vitals HUD 1.1.0 does), notifications from SL Survival's scripts go to it
  (SLSFW_GetMessages) instead of the game's notification list; every other mod's notifications are shown by the game
  as before. Without a HUD nothing changes.

## Version 0.5.0 — guard searches

SLS found a nearby guard by restarting a search quest and reading who filled its aliases: every 1.5 s while a toll
is due or guards are hunting a toll dodger, and every 3 s while you carry a weapon or wear armour a town forbids.

- Toll and hunt: the DLL now does the search itself. It takes the actors the search quest would have filled (the
  quest's own alias conditions from the ESP, closest to you first, one per alias) and runs the scripts' own test:
  a guard who detects you and can see you makes the toll due; guards who detect you join the hunt. The quest is no
  longer restarted. Sneaking past the guards works as before, it is the game's own detection.
- Weapon, armour and drawn-weapon warnings: the DLL runs the warning quest's alias conditions (a guard who sees you) over the
  loaded actors first and the quest is restarted only when one passes; otherwise SLS carries on as if nobody saw.
- Escort rule fix: with a follower framework such as Simple Follower Framework, SLS counted no followers (it read only
  the vanilla follower aliases, which those frameworks leave empty), so the guards arrested you again and handed you
  one more escort each time. The count now also includes every follower travelling with you (player teammates, minus
  creatures and animal companions, as SLS excluded them, and summoned creatures or thralls).
- Stuck guard warnings: when a guard who spotted a violation never came to talk (busy, e.g. in a scene) and the player
  drew or equipped again, SLS cancelled the approach but left the warning type set, and no guard ever warned again.
  After 60 s in that state the framework starts SLS's own warning cooldown, which clears it.
- Begging: the skooma pool behind the begging lines was refreshed only by clicking "Please, I need help", so that line
  was judged by a stale pool (1000 on a fresh session) and could open an empty submenu once. It is refreshed when SLS starts and on every load too.
- New rule: with a valid weapon licence the guards no longer stop you for carrying a weapon in town. Drawn or
  dropped weapons still count. Armour and every other guard rule are unchanged.
- Diary of Mine stands in for Paradise Halls: SLS's slave checks (stash tracking ignores slaves, a submissive slave
  gives in to Animal Friend, the charcoal mark from the all-in-one key) now also see Diary of Mine slaves, the
  player's and other slavers'; Diary of Mine submission training (0-100) takes PAH's submission (90 and above).
- The New Gentleman stands in for Schlongs of Skyrim: SLS's half-naked cover is revealing for TNG (SkyPatcher adds
  TNG_Revealing), as SoS made it revealing before.
- Survival Mode Improved: SMI strips the scripts off Creation Club Survival Mode's need quests, so SLS's hunger,
  exhaustion and cold changes (eating cum, sex fatigue, sleep, exposure) went nowhere. With SMI installed they now go
  through SMI: restores through its Papyrus API, increases straight into the need values SMI keeps, stage limits and
  the area cold and near-heat state from SMI's globals.
- SexLab P+: the forced-drug "sensitivity" option is also set up when P+ (which contains SLSO) is installed.
## Version 0.4.1 — modesty cover animations

- Cover Myself: with Modesty Toggle installed, the cover key now plays the Dynamic Feminine Female Modesty
  movesets (Modesty Toggle force cover) instead of the Cursed Loot offset animation, so the cover works while
  walking, running and sneaking. The cover rules are unchanged: what breaks the cover, the willpower check and the
  resist-loss multiplier are still decided by SLS. Above AND's modesty arousal threshold the moveset cannot play,
  so the key falls back to the Cursed Loot animation there.
- Barefoot slow-walk: taking boots off or putting them on changes the speed at once (the instant path was written
  in 0.4.0 but never called, so SLS's own 2 s check did it).

## Version 0.4.0 — measured hot spots

The 0.3 event profiler showed where SLS still woke Papyrus in real play; this version takes the busiest of those.

- Advanced Nudity Detection: AND announces an update on every footstep and equip (about once a second), and the
  bikini-curse script woke for each one to ask AND ten questions. The DLL now listens to AND, reads its verdict from
  AND's factions and calls the script only when the player's exposure actually changed.
- Lost items: a drop spot used to re-check every item against the navmesh every 3 s for as long as its cell stayed
  loaded. It now stops after three quiet checks and looks again the next time the cell loads.

## Version 0.3.1

- Nearby Lost Items: the widget counted every lost item in the world, so "Nearby Lost Items: 1" stayed on long
  after you walked away. It now counts only drop spots within `lostitemsradius` (SteepFall.json, default 2000
  units, about 28 m) and refreshes as you move.
- Orgasm Fatigue: the debuff is capped at half the base stamina (or magicka) instead of all of it, so on its own it
  no longer takes sprinting and power attacks away. The new cap applies the next time the debuff is recalculated
  (next orgasm or sleep).
- Escort check crash: when a guard takes you "back to headquarters" (or "Not so fast...") for walking without an
  escort, the teleport fired about 4 s into the guard's line, while the voice was still playing. Leaving the cell
  mid-line could crash the game's audio thread (XAudio2_7.dll). The teleport now waits until the guard has finished.
- Barefoot: putting shoes on or taking them off updates the barefoot slow-walk at once (the engine re-checks the
  effect within a second); before, SLS waited for the menu to close and then for 2 s without equips.
- Begging: without SexLab Skooma Whore the "Please... some skooma" lines no longer show for every NPC.
- Combat Equip: changing armour in combat now says so ("Getting dressed in combat - hold still...") and tells you
  when it was interrupted; before, the armour silently came off again.

## Version 0.3.0

- Diagnostics: an event profiler counts every Papyrus event the game delivers, per script and event, since the
  last load. Read it with `SLSFW.ProfileReport(limit, filter)`; `SLSFW.ProfileReset()` starts over.
- Testing helper `SLSFW_Test.DDUnlock(armor)` unlocks a worn Devious Devices item and keeps it in the inventory.

## Version 0.2.1

- Map: with a blindfold on, opening the map now says "I can't read a map with my eyes covered" instead of
  "I don't have a map".
- Diagnostics: the equip part of the report shows each subscriber's Papyrus state.

## Version 0.2.0 — one native equip hub

Every time the player equipped or unequipped anything, the engine woke up to 17 SLS scripts, each of which then
checked whether the item concerned it. Now SLSurvivalFramework.dll receives the equip event once and calls a
script only when the item is one it acts on, in the state it acts in: potions for the drug, alcohol and gluttony
effects, armour for the bikini curse, guard warnings and toll disguise, a blindfold for map and compass, heavy
bondage for Devious Effects, body/bra/panty pieces for the half-naked cover, and so on. Minimum speed and carry
weight are re-balanced only when an equip actually changed them. The gag flag that dialogue checks
(PlayerIsHardGagged) is kept by the DLL.

These scripts no longer receive equip events themselves, so they need the DLL: if it does not load, SLS shows a
message box on load. Disabling this whole mod returns every script to plain SLS.

Also: the begging dialogue no longer logs "Cannot add None to a container" on a new game.

## Version 0.1.1

- Diagnostics: the framework report is written to its log after every load (no console command needed).
- Steep Fall: a jump in position larger than anyone runs in a second (a scripted move within the same cell) is
  treated as a teleport and no longer counts as a fall.
- Steep Fall: falling no longer tries to drop non-playable worn helpers (HDT SMP Object's "HDTSMPObjectBase"),
  which have no 3D and logged "Object has no 3D".
- Steep Fall: locked restraints never fall off. Devious Devices (zad_Lockable, zad_InventoryDevice, zad_QuestItem,
  zad_BlockGeneric) and ZaZ (zbfWorn*) worn items are kept; 242 such items in a typical DD/ZaZ setup carried no
  SexLabNoStrip. SexLabNoStrip is matched by name, so copies of that keyword in other mods count too.
- Steep Fall: fall height raised from 150 to 250 (SKSE\Plugins\StorageUtilData\SL Survival\SteepFall.json, loose
  override of SLS's file; edit it to taste). Takes effect on the next game load.
- Without Deviously Cursed Loot, equipping heavy bondage no longer loops for up to 100 s logging
  "GetCurrentStageID() on a None object".

## Version 0.1.0

- **Steep Fall**: the 1 s height poll while Forward is held is native. The trip itself (perks, ragdoll,
  dropped items, sounds) is unchanged.
- **Toll gates**: locking or unlocking a town's gates now changes every door of that town. Before, only the
  door that triggered it changed, so Riften's other two gates, and Solitude's and Windhelm's second doors,
  kept their old state.
- Mandatory-restraint decay quest stops when nothing is pending instead of waiting ~29 million hours.
- Dancing no longer pops debug message boxes (on every dance end and for each spectator), and spectators
  are no longer listed twice.

## Diagnostics

`SKSE\SLSurvivalFramework.log` (next to skse64.log). Five seconds after every game load or new game the framework
writes its report there: the gate state of every town (all doors, locked or open, and the conditions SLS sees) and
the Steep Fall monitor. Scripts and tools can ask for the same report with the global function `SLSFW.Report()`
(it is also printed to the console). There is no console command: this setup's console has no `cgf`.

## 0.7.8 (2026-10-24)

- Inequality without red bars: the stat penalty is applied as a permanent actor value modifier, recalculated every
  second (amounts from `SL Survival - Revision Tweaks.esp` globals); `SLSFW.InequalitySuspend(bool)` pauses it.
- Swimming: without Frostfall the DLL sends `Frostfall_OnPlayerStartSwimming` / `Frostfall_OnPlayerStopSwimming`,
  so SLS's water hooks (licence damage, dirt) work.
- `SLSFW.GetFollowers` (current followers as an array) - trauma picks followers up automatically.
- `_SLS_AllInOneKey`: the SLS tongue is shifted on UBE races (`StorageUtilData\SL Survival\TongueOffset.json`).
- `_SLS_LicBikiniCurse`: heels not required by default, the notification names what set the curse off.

## 0.7.9 (2026-10-24)

- Curfew guards: while SLS has flagged a curfew violation and no curfew guard is assigned, the DLL checks every 2 s
  whether a loaded guard passes the search conditions and then lets `_SLS_Curfew.IsViolatingCurfew` re-run its licence
  check and send the guards. `_SLS_IntSlsfw.GuardSearchHasMatch` skips restarts that would find nobody.

## 0.8.0 (2026-10-24)

- Sinking in bondage: with her arms out of use (DD heavy bondage or pet suit, ZaZ wrist ties, both hands lost with
  Amputator) the heroine cannot swim. A hook on PlayerCharacter::ModifyMovementData - the same method Underwater NG
  (GPL-3.0, Ckw25) uses for armor buoyancy - slows her strokes, cancels upward swimming and adds a downward drift, so
  she sinks and SLS's drowning in bondage takes over. With Underwater NG installed both hooks chain and its armor
  buoyancy adds to this; with Sink Or Swim installed it stays off. `SLSurvivalFramework.ini` `[Swim]`:
  `bSinkWhenBound=1`, `fBoundSinkSpeed=0.9` (m/s), `fBoundStrokeMult=0.35`, `fBoundAscentMult=0`.
