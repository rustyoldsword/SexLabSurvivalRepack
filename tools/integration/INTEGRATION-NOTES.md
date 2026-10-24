# SL Survival - Integration Patch

Scripts-only patch for SexLab Survival 0.716 (crajjjj's patch over Monoman1's original). No plugin.
Install below `SexLab Survival 0.716` (higher priority). Built from crajjjj/SLSurvival tag 0.716.

## What it connects

| SLS feature | Before (this load order) | With the patch |
|---|---|---|
| Wetness: cum and milk leaks make you wet, the kennel bucket, ruined licences when drenched | Frostfall only - dormant | WetFunction NG wetness (scaled to Frostfall's 0-750) |
| Cold: sex warms you, skooma/milk warm you, sleeping in the cold, "near a fire" | Frostfall only - dormant | Creation Club Survival Mode cold and heat check |
| Needs: swallowed cum feeds you, fatigue from drugs/bondage furniture, sleep-quality penalties, belly scale, begging when hungry | iNeed / RND / ESD only - dormant | Creation Club Survival Mode (hunger, exhaustion), or SunHelm |
| Sexual fame: whore / slut / slave / bestiality / skooma | old SLSF .esm only - dormant | SLSF Reloaded (Whore / Slut / Submissive / Bestiality / Airhead) |
| Compulsive Sex | switched itself off without SLSO.esp | works on SexLab P+ (raises enjoyment through P+'s thread API) |
| "Sex Reduces Exposure" (Warm Bodies) | unchanged from SLS (the MCM already stores the slider negated: -3 = warmer) | 2026-10-03..12 this patch flipped the sign by mistake and sex made you colder; fixed 2026-10-12 |

Priority when several are installed: Frostfall > WetFunction NG / Survival Mode; RND > iNeed > ESD > SunHelm >
Survival Mode; old SLSF > SLSF Reloaded. Survival Mode counts only while it is switched on.

SunHelm instead of Survival Mode: install crajjjj's optional SunHelm patch plugin (`SL Survival Sunhelm Patch.esp`)
and keep this patch above its scripts - `_SLS_Needs` here already contains the SunHelm state.

## Files

`_sls_needs`, `_sls_sleepdeprivation`, `_sls_interfacefrostfall`, `_sls_interfaceslsf`, `_sls_compulsivesex`,
`sls_warmbodies` (edited), `_SLS_IntCcs`, `_SLS_IntWfng` (new wrappers), `_SLS_InterfaceShs`, `_SLS_IntShs`
(crajjjj's SunHelm adapter, unchanged, needed as the type of `_SLS_Needs.Shs`).

## Build

`python tools\patch_needs.py; python tools\patch_frostfall.py; python tools\patch_small.py` regenerate `src\` from
`orig\` (pristine 0.716 copies). `build.ps1` compiles with the SLS repo import list (`sls_repo\`) plus `stubs\`
(compile-time only: Survival Mode has no source, and a few repo dependencies do not parse with the Bethesda
compiler - `tools\autostub.py` regenerates those). `package.ps1` deploys. `tools\pexcmp.py` compares bytecode
order-insensitively; the unmodified `orig\` sources compile to the same content as the installed 0.716 scripts.

## 2026-10-04

`sls_mcm`: Snowberry stays OPT-IN as in SLS (a default-on was tried on 2026-10-04 and reverted the same day: tick it in the MCM while still in the start cell). `_sls_lictowncheckplayeralias`
(new here) picks the forced escort from the target hold, skips missing/dead/disabled entries (the original retry loop
could spin forever on None). The SLS - Patches folder also ships `StorageUtilData\SL Survival\EscortList.json` with
the 7 vanilla mercenaries, replacing crajjjj's personal list.

## Full audit 2026-10-04

Tools: `tools\pexapi.py` (every callmethod/callstatic of the 807 SLS scripts checked against the target class as the
VFS serves it: missing function / argument count; 24.8k calls, 0 left), houseCARL `check` (unbound properties,
dialogue graph of all 210 quests: 0 findings), GetFormFromFile sweep (715 refs resolved against the order).
Script fixes added here: `tif__050201a0` (PlayerRef unfilled - slap sound/mark went to None), `tif__040974c4` (spank
greeting cooldown quest unfilled), `_sls_forceddrugging` (sensitivity potion list unfilled), `_sls_interfacecreatureframework`
(CF config quest is 0xCF02, not 0xD63), `sls_mcm` (DLC strong-female followers looked up in Skyrim.esm),
`_sls_cumaddict` (stale 0.716 pex called DoVoices with 3 of 4 args - unchanged source, just rebuilt),
`_sls_stashaddexception` / `_sls_cumdesperateeffects` (cross-quest alias properties fail to bind on a new game - now
resolved at runtime). Plugin-level fix: cleaned copy of SL Survival.esp (`tools\clean_esp.py`, `clean\drop_ids.txt`) + SkyPatcher INIs, see `SL Survival - Patches\docs\SL Survival - Cleaned Plugin__README.txt`.

`tools\clean_esp.py` 2026-10-04 (TOH run): ids that sit inside a dropped cell's child group now count as found; the SLS rebuild is byte-identical to `clean\SL Survival.esp`.

## 2026-10-12 — порт crajjjj 0.717–0.719 (выборочно)

Upstream 0.716→0.719: 0.717 SunHelm belly ladder MCM, 0.718 P+ 2.19 oral API + belly-only-when-overeating, 0.719 UBE wound
textures. Taken (`tools\patch_belly_0719.py`, idempotent, run after the other src generators):
- `_sls_needs`: the adapters' -1.0 "stage swap" sentinel is passed through (Rnd/iNeed/Esd upstream; our Shs state too);
  our CC Survival state: +0.3 only at stage 0 (Well Fed), 0 otherwise (was 1.5 - stage*0.3).
- `_SLS_InterfaceShs`: 0.718 defaults. `_sls_interfacernd` / `_sls_interfaceineed`: 0.719 sources as-is (only defaults changed).
- `sls_mcm`: RND/iNeed slider defaults and Settings.json fallbacks = new defaults; Belly Scaling switch enabled for
  ESD, SunHelm and Survival Mode as well.
Not taken: 0.717 generic ladder MCM (SunHelm only, SunHelm off here), 0.718 `_SLS_IntSlpp` (our P+ 2.19 patch already
does it), 0.719 UBE wounds (we ship our own UBE wound set via SlaveTats paths), version bump in `sls_main`.
Backup of the previous sources/pex: `work\backups\sls_belly_0719_2026-10-12`.

## 2026-10-12 — audit fixes (`audit\SLS Framework\AUDIT-2026-10-12-RU.md`)

- `sls_warmbodies`: the 2026-10-03 "sign fix" was wrong - `sls_mcm` stores the Warm Bodies slider already negated
  (`WarmBodies = -value`, default -3.0), so the original `ModExposure(Menu.WarmBodies)` already meant "warmer". The
  flip made every sex scene add cold under Survival Mode. Back to the original call.
- `sls_mcm` gender gate: SkyUI calls `OnConfigInit` from `OnInit`, i.e. at quest start on a new game, before RaceMenu,
  when the player base is still the default male - the gate ran its male pass on every new game. It is no longer
  applied from `OnConfigInit`; it runs on RaceSex Menu close, on MCM close and on game load. `TradeRestrictions`
  (cleared by `ToggleLicences(false)`, never restored by `ToggleLicences(true)`) is now saved and restored like the
  other toggles. `GenderGateBusy` is reset on every load and a call that arrives mid-pass re-runs the pass at the end
  instead of being dropped. Owner decision 2026-10-12: the gate now also switches off cum addiction, compulsive sex,
  orgasm fatigue and animal breeding for a male player (restored for a female one).
  2026-10-15, after a save was wedged: the pass no longer runs on a sex nobody chose, and it no longer races the
  framework. `PlayerLoadsGame` still runs at quest start on a new game, before RaceMenu, so the male pass now waits
  for a sex the player has actually settled (`_SLS_GG_SexSeen`, set when the RaceSex menu or the MCM closes, or as
  soon as the player reads female) - on a new game there is no male pass and no mirror restore pass at the next load.
  While a pass runs, and while the SLS MCM page is open, the framework's gate recheck is held
  (`_SLS_IntSlsfw.GatesHold`, a global so it takes no script's lock); the doors themselves are left to the framework
  (`_SLS_IntSlsfw.GatesChanged`, one recheck when the hold goes) instead of calling `_SLS_TollUtil` and the gate
  aliases from inside the pass. Without the framework both are no-ops and the old `ToggleTollGateLocks()` path runs.
  Why: the pass holds `SLS_Mcm` (and `SLS_Init`, since `SLS_Init.PlayerLoadsGame` calls it) and then wanted
  `_SLS_TollUtil`, while `FrameworkRecheckGates` holds `_SLS_TollUtil` and then reads `SLS_Init` / `SLS_Mcm`. On
  2026-10-15 the two met at a load: the pass stopped after two of five towns, every later call queued behind it, the
  MCM page never built and SkyUI left the mod's entry dead for that save.
- `_sls_apilichandler`: a licence request that arrived during the 2 s bikini-curse wait (state Busy) sat in the queue
  until the next API call; the queue is drained again after the wait.
- `sls_utility.UpdateAlpha`: trauma fades through SlaveTats were a remove + add per fade step (two full overlay
  rebuilds per wound per game hour, with a blink). The alpha is now set straight on the NiOverride slot that holds the
  SlaveTats texture (found by file name, so the UBE copy under `slavetats\UBE\` matches too).
- `_SLS_IntCcs`: the Survival Mode Improved aware version (from SexLab Survival Framework) is now part of this patch,
  so hunger / exhaustion / cold changes reach SMI with or without the framework. SMI strips the scripts off the
  Creation Club need quests, so the plain CC calls went to None. `build.ps1` imports SMI's `SurvivalModeImprovedApi`.
- Not changed: the two "cannot be bound because alias ... is not the right type" lines in the Papyrus log (SLS-008)
  are a VM bind-order quirk for alias-typed properties across quests; the property types are right and the runtime
  getters in `_sls_stashaddexception` / `_sls_cumdesperateeffects` are the fix. Harmless.

## 2026-10-19 — Snowberry start licences in one pass (from crajjjj 0.800)
`_sls_licencesnowberry.GiveLicences` queues its licences with `LicHandle.AddLicToQueue` and calls the new
`_sls_apilichandler.ProcessQueue` once. The API call is synchronous, so issuing through `Api.On_SLS_IssueLicence` waited
the handler's 2 s after every licence and never reached the batch. Backup: `work\backups\sls_snowberry_queue_2026-10-19`.

## 2026-10-19 — Survival Mode state picked by plugin (from crajjjj 0.800)
`_sls_needs.PickNeedsState` enters State Ccs when Survival Mode's form `ccqdrsse001-survivalmode.esl|0x826` exists, not only
while the mode is on: on a new game the pick ran before SMI switched the mode on, leaving the needs dead until the first
load. Ccs functions check the switch themselves; `GetConditionsStatement` got the same guard. The framework's
`_SLS_AllInOneKey` hides the needs line while the needs mod reports inactive. Backup `work\backups\sls_ccs_pick_2026-10-19`.

## 2026-10-24 - pack 1 of the SLS revision

- `_SLS_GameStart` (new, global `HasStarted()`): "the game has started" by the same rule as Snowberry (Alternate
  Perspective = the player left APStartCell and is not in the Helgen run, MQ101 10..239). `_sls_mq101kicker` used to
  wait for MQ101 240, so on an AP start outside Helgen the licence purchase blocks, curfew, evictions, dirt, trauma
  updates and bikini experience never started. Also `_sls_cumaddictautosuckcooldown`, `_sls_cumaddictbathingtimer`,
  `_sls_pushplayercooloff`, `_sls_bikiniexptraining` and the weight gain check in `sls_mcm`. The kicker switches
  creature content on for a new game.
- SLIF NG ships as a light plugin and `GetModByName` returns 255 for it: `_sls_interfaceslif`,
  `sls_gluttonyinflationscript`, `_sls_forceddrugging` and `sls_mcm` use `Game.IsPluginInstalled`. `_sls_inflatepotion`
  grows the `slif_breast` node on UBE races (SLIF NG's UBE profile maps it to BreastsBigger) instead of CBBE morphs.
  `_sls_intslif` + `_sls_bodyinflationtracking` (Jiggles): node values are scales (1.0 = unchanged), only growth counts.
- `_sls_needs`: the sleep conditions box is `SleepReportMode` (MCM Needs, "Sleep conditions report"): box /
  notification (default; the framework routes it to the Vitals HUD message panel) / off.
- `sls_mcm` new-game defaults (`tools\set_mcm_defaults_2026_10_24.py`): horse 3000, gold weight 0.001, Simply Knock
  slavery 0, stash thieves take 8 items, easy-bed traps off, fast travel ban off (SMI does it), bikini drops
  6/4/4/2/3, creature content on (Default button and JSON import).
- Data: `tools\fix_bikbreak_tawoba.py` - 53 armor breakdown JSONs point at TAWOBA REMASTERED (the old plugin name made
  every breakdown eat the armor); `tools\fix_bikini_lists.py` - BikiniArmors.json without the 148 entries of the
  missing TEWOBA plugin.
- These scripts were deployed by copying: `package.ps1` wipes Scripts, which also holds the escorts' `_SLSHE_TIF_*`.

## 2026-10-24 - packs 2-4 of the SLS revision

New plugin `SL Survival - Revision Tweaks.esp` (regular ESP, masters Skyrim/Update/SexLab/SL Survival, no .seq -
nothing in it is start-game-enabled) with its voices in `Sound\Voice\SL Survival - Revision Tweaks.esp\` (207 .fuz,
Fish Audio zero-shot clones of the vanilla voice types, `work\SLS_revision_voice`).

Softer rules (pack 2):
- Magic curse: takes half of the current magicka once, then only halves regeneration (`_sls_licenceutil`);
  a DD collar no longer blocks casting outright by default.
- Bikini curse: heels no longer required by default, the short-breath gasp only in combat or while running, and the
  notification names what set the curse off (framework `_SLS_LicBikiniCurse`).
- Freedom licence is not sold by default (`LicFreedomEnable` = Never; nothing needs it without Slaverun).
- Self-degradation dialogue (01F13B) gets a random chance condition (Revision Tweaks override).
- Corruption only builds while the corruption mode is on; TNG sizes give men the size bonus
  (`_sls_sexexperience`, `_SLS_IntTng`); the race size question no longer pops up mid-scene (`sls_utility`).

Native (pack 3, framework 0.7.8):
- Inequality without the red bars: the stat penalty is a permanent modifier set by the DLL each second
  (`Inequality.cpp`, amounts in Revision Tweaks globals 000800/000801), other scripts can pause it with `SLSFW.InequalitySuspend` (nothing calls it yet).
- Swimming events: without Frostfall the DLL sends `Frostfall_OnPlayerStartSwimming/StopSwimming`, so SLS's swim
  hooks work; a licence is ruined by swimming with a 10% chance per swim (`_sls_interfacefrostfall`).
  Sinking in bondage is NOT done (no verified engine hook).
- Trauma tracks current followers automatically (`SLSFW.GetFollowers`, `_sls_trauma`).
- Tongue position: `_SLS_AllInOneKey.FixTonguePosition` shifts the SLS tongue on UBE races through NiOverride, values
  in `StorageUtilData\SL Survival\TongueOffset.json`.

New content (pack 4):
- Easy-bed suitors (`sls_easybeds`, `_SLSRT_Suitor` quest, `_SLS_TIF_Suitor`): while sleeping in an easy bed a man
  from the same room may wake the heroine once a day; she lets him in, asks 100 gold, or sends him away. Switch:
  global `_SLSRT_SuitorEnable`. Cursed Loot traps only with DCL and the old option.
- Kennel: a morning job (`_SLS_TIF_KennelWork`: 3 hours, 15-30 gold and bread, stamina cost, once a day) and the
  warning comes before the night (`sls_kennelkeeperplayeralias`).
- Curfew: a heads-up half an hour before curfew (`_sls_curfew`).
- Trauma hit sounds replaced with clean high-quality recordings.
- Mjoll's quest "A Woman of Strength" (`_SLSRT_StrongWoman`, `_SLSRT_StrongWomanQuest`, `_SLS_TIF_StrongWoman`):
  talk to Mjoll while inequality applies; kill fifteen, live seven days without an armor licence, reach 50 in a weapon
  skill or Destruction; she then frees the heroine from inequality for good (`sls_mcm.GrantStrongWoman`).
- Not done: new self-degradation variants (need text from the owner), own Fashion Rape, native curfew guards.

## 2026-10-24 - curfew guards that arrive late

- `_sls_curfew.IsViolatingCurfew`: with the framework the guard search quest (`_SLS_CurfewGuardAliases`) is restarted
  only when a loaded actor passes its alias conditions (`_SLS_IntSlsfw.GuardSearchHasMatch`; without the framework it
  restarts as before). A heroine who bought a curfew or whore licence since gets `_SLS_CurfewViolation` reset to 0.
- Framework 0.7.9 watches the flagged violation and calls the check again when a guard comes into range after the
  location change (before, nobody came until the next location change).

## 2026-10-24 - owner's texts, unvoiced

- Suitors, kennel job and Mjoll's quest use the owner's rewritten texts (`work\SLS_revision_voice\lines\revision_lines_owner.csv`,
  `tools\gen_revision_text.py`); the old voice files spoke the old words and were moved to
  `work\backups\sls_owner_text_2026-10-24\voice_old` - the lines are unvoiced for now.
- Self-degradation (`tools\gen_self_degradation.py`, texts in `self_degradation\self_degradation.csv` +
  `sd_dictation.csv`): per step 2-3 new options with choice values 5-7 (`_SLSRT_SD_C<step>_O<n>` topics, listener
  reactions `_SLSRT_TIF_SDPlayer`), the begging NPC's matching dictation lines in SLS's `_SLS_DegradationC1..C4`
  (`_SLSRT_TIF_SDNpc`), 3 more openers (each 9% instead of the single 35% line, same total), closings and payments as
  Random siblings. SLS's own option topics link to the new ones. The animal option of step 2 is left out.

## 2026-10-24 - whore licence duties

`SL Survival - Revision Tweaks.esp` + `SEQ\SL Survival - Revision Tweaks.seq`: quest `_SLSRT_WL_Duty` (start game
enabled, `_SLSRT_WL_Duty.psc`) checks every game hour - with a valid whore licence, in an SLS town and free, a client
may come (`_SLSRT_WL_Client`: closest adult man in 3000 units, not a guard / follower, force-greet package
`_SLSRT_WL_ApproachPack` copied from SLS's curfew approach). Accept = paid `_SLSRT_WL_Pay` + SLS scene; refuse = a
report: after one game hour and for two days the town's guard (`_SLSRT_WL_Guard`) comes to her, revokes the licence
(expiry reset + `RevokeLicence("Whore")`), fines `_SLSRT_WL_Fine` and punishes (DD devices or SLS drugs) when she cannot
pay or argues; then `_SLSRT_WL_Banned` hides the whore licence at the licence office and the kennel keeper for
`_SLSRT_WL_BanDays`. Placeholder texts, unvoiced (`tools\gen_whore_duties.py`, `tools\export_whore_duties.py`).
Also fixed: the easy-bed suitor fragments bound `Main` to the _SLS_Main quest instead of its alias 0 (SLS_Main is a
ReferenceAlias script), so the suitor scene never started.
