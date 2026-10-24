# SL Survival - Hopeless Escorts Dialogue 1.1.0

Dialogue for the six free escorts of `SL Survival - Hopeless Escorts.esp`: 305 lines, crude and degrading, aimed at
the female player character. Voiced with Fish Audio text-to-speech (one voice per character); lines without a voice file show subtitles only.

## 1.1.0 (2026-10-22)
- 192 of the 305 lines rewritten to match each escort's running themes (voice pack pass); the other 113 keep their text.
- All 305 lines re-voiced with new character voices: militiaman, beggar, scribe, recruit, farmhand, watchman each have
  one voice chosen for age and type. Response text in the plugin, .lip and .fuz rebuilt from the same text.
- Plugin text changed in place byte for byte (only the response text of those 192 lines); FormIDs, masters, quests,
  conditions and the .seq are unchanged.

## What plays when
- Introduction: the escort says one of his INTRO lines right after the guards hand him over (said by
  `_sls_lictowncheckplayeralias` through topic `_SLSHE_Intro`).
- Idle chatter while he follows her (`_SLSHE_Idle`), first matching situation wins:
  naked -> restrained/collared (DD, ZaZ) -> bikini/half-naked (SLS, SLA keywords) -> health below 33% -> inn ->
  town/city -> general remarks and threats. Lines within a situation are random.
- Combat start (`NormalToCombat`) and combat end (`CombatToNormal`).
- Four player choices: "Who are you, exactly?", "I don't need you.", "Here, take some coin." (takes 50 gold, needs
  50 gold), "Go away. I'm done with you." (dismisses him through Simple Follower Framework).
- Only these six speak the lines, only while they are her followers, only to a female player.
  Global `_SLSHE_Comments` = 0 turns everything off.

## Files
- `SL Survival - Hopeless Escorts Dialogue.esp` (regular plugin - voiced dialogue, not ESL) + `SEQ\` file.
- `Scripts\_SLSHE_TIF_Dismiss.pex`, `_SLSHE_TIF_Coin.pex` (+ sources); dismiss needs Simple Follower Framework.

## Requirements
SL Survival, SL Survival - Hopeless Escorts.esp, Devious Devices - Assets, ZaZ Animation Pack, SexLab Aroused (or
OSL Aroused), Simple Follower Framework.

## Rebuilding
Text lives in `lines.py` and `custom_lines.csv` of the source folder; `build_script.py` writes the voice script,
`gen_plugin.py` the houseCARL manifest. After a create, link the four player topics and the intro topic to their
branches (topic Branch field), then write the .seq.

## Voice files
`Sound\Voice\SL Survival - Hopeless Escorts Dialogue.esp\<VoiceType>\_slshe_dlg_<topic>_<00 + INFO id>_1.fuz`, built by `build_fuz.py` (Creation Kit LipGenerator for .lip, xWMAEncode, FUZE packing) from the WAVs. The quest and topic EditorIDs are short on purpose: the voice file names are made from them.

## Toll collector: "I need an escort" (2026-10-21)
A woman stuck in a walled town can now ask for the same free escort the guards force on her. At any toll collector, while
the toll is still due: **Please, I need help.** -> **I can't leave without an escort. I need someone to go with me.**
The collector mocks her and hands over a fresh hopeless escort at her side (no teleport); he joins as a follower, says his
introduction, and SL Survival recounts her followers at once, so the toll box and "Pay toll" accept her. One living
hopeless escort at a time: with one already following, the collector only sneers. Free; lines are subtitles only for now.
- Records: quest `_SLSHE_Col` (Start Game Enabled, .seq regenerated), topics `_SLSHE_ColHelp/ColNeed/ColBye`, branch
  `_SLSHE_ColBranch`, global `_SLSHE_EscortAlive` (set by `_SLSHE_TIF_ColCheck` as the collector starts talking).
- `_SLSHE_Escort` (global functions Spawn / HasLiving / Introduce) is now shared by this dialogue and the guards'
  hand-over in `_sls_lictowncheckplayeralias`.
- Sources: `work\SLS_escorts\dialogue\gen_collector.py`, `collector_escort_lines.md`, `scripts\`, `build_scripts.ps1`.

## Idle chatter cooldown (2026-10-21)
The game asks a follower for idle chatter every ~10-15 seconds and the idle lines had no reset time, so an escort
repeated himself nonstop. Every idle line now needs `GameDaysPassed >= _SLSHE_IdleNext`; each spoken line
(`_SLSHE_TIF_IdleNext`) pushes `_SLSHE_IdleNext` by `_SLSHE_IdleGap` game days. Default gap 0.04 days (~1 game hour,
~3 real minutes at timescale 20). Tune in the console: `set _SLSHE_IdleGap to 0.02` (twice as often), `0.08` (half).
Combat, intro and the player's own topics are not affected. Generator: `work\SLS_escorts\dialogue\gen_idle_cooldown.py`.
