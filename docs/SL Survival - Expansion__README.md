# SL Survival - Expansion

Add-on files for SexLab Survival with our changes, in one mod:
- SL Survival - Expansion.bsa (+ empty ESL loader SL Survival - Expansion.esp): voices for Self-Degradation, the extra SLS lines, the escorts' generic lines, and the escorts' FaceGen.
- SL Survival - Hopeless Escorts Generic Voice.esp, SL Survival - Hopeless Escorts Faces.esp (+ SkyPatcher ini, hair textures) - loose.

The sections below are the READMEs of the former separate mods.

---

## Self-Degradation Cloned Voices

# SL Survival - Self-Degradation Cloned Voices

Voice asset override for the Self-Degradation dialogue added by `SL Survival - Revision Tweaks.esp`.

- 42 in-game dialogue lines.
- 49 adult vanilla voice types.
- 2,058 `.fuz` files, each containing a non-empty LIP and XWM stream.
- Generated as zero-shot voice clones with Fish Audio `s2.1-pro-free`.
- `FemaleChild` and `MaleChild` are intentionally excluded.

This mod contains no plugin and does not modify the source mods. Keep it enabled after any mod that supplies the same voice paths so these files win the MO2 asset conflict.

Build records, QA results, and checksums are stored in:

`C:\Modding\MO2\work\SLS_self_degradation_voice_2026-10-24`

---

## Extra Voice Lines

# SL Survival - Extra Voice Lines 1.0.0

Voice files only (no plugin). Personal build, not for redistribution: the voices are AI clones of the vanilla
Skyrim voice types.

- The toll collector's "I need an escort" branch of `SL Survival - Hopeless Escorts Dialogue.esp` (16 lines, quest
  `_SLSHE_Col`) is voiced in the six collector voice types: MaleNord, MaleDarkElf, MaleKhajiit, MaleOrc,
  MaleCondescending (Redguards), MaleArgonian - 96 files.
- SL Survival's spank line "Nice ass baby." (`03E57A`, `_SLS_AssSlapQuestTopic`) gets a new take in all 29 adult male
  voice types of the SL Survival voice pack. Loose files win over the voice pack's BSA, so mod order does not matter;
  female voice types keep the pack's version.

## How it was made
Fish Audio (s2.1-pro) zero-shot cloning: every request carried 3-4 calm vanilla lines (26-33 s) of the same voice
type from `Skyrim - Voices_en0.bsa` with their transcripts; no voice model is stored. Lip files from the Creation Kit
LipGenerator, xWMA 48 kbps, FUZE. File names: `<quest 10>_<topic 15>_<00 + local FormID>_1.fuz`.

Sources: `work\SLS_voice_extra` (`pick_refs.py`, `fish_clone.py`, `qa.py`, `build_fuz.py`).

## 2026-10-24
The 16 toll collector lines (96 files) moved to `SL Survival - Patches`, which now carries all 22 collector answers
for `SL Survival - Hopeless Escorts Dialogue.esp` in the same six voice types. This mod keeps only "Nice ass baby."
(29 voice types). The old collector files are in `work\backups\extra_voice_collector_dupes_2026-10-24`.

---

## Hopeless Escorts Generic Voice

# SL Survival - Hopeless Escorts Generic Voice 0.3.0

The six hopeless escorts of `SL Survival - Hopeless Escorts.esp` get their own wording and their own voice for the
stock Skyrim lines (follower commands, greetings, goodbyes, combat barks, friendly fire, crime and trespass reactions,
idle remarks, alarms, being bribed or intimidated, the player swinging a weapon or knocking things over near him).
1,941 lines in 71 vanilla topics.

- 0.2.0: 1,593 lines copied from the vanilla lines of each escort's voice type.
- 0.3.0: 348 lines for the SHARED responses (DialogueGenericSharedInfo): each generic line that borrows a shared
  response (DialogueGeneric, DialogueFavorGeneric) gets an escort copy that carries the shared response with the new
  text. Shared responses used only by quest-specific dialogue are not covered - escorts never take part in it.

Not covered: two scripted scenes (dog, Scene04). In a topic where an escort has his own block, his vanilla wordless
variants of that topic (grunts) no longer play.

Masters: Skyrim.esm, Update.esm, HearthFires.esm, Dragonborn.esm, SL Survival - Hopeless Escorts.esp.

## How it works
- Each rewritten line is a NEW dialogue line (INFO) in the same vanilla topic, a copy of the vanilla line it replaces:
  same conditions, flags and result script (so "Follow me", "Wait here", "Trade" and "Part ways" still do their job),
  with the voice-type checks replaced by "the speaker is this escort" (GetIsID) and the new text.
- The new lines are placed at the head of their topics (PreviousDialog = 0); a random block ends with RandomEnd so a
  vanilla variant is not mixed in. Vanilla lines are not edited; the escorts keep their vanilla voice types, and
  everybody else in Skyrim is unaffected.
- Each escort's lines form one block at the head of the topic, in vanilla order; the block's last line carries RandomEnd.
- The plugin carries copies of the 63 topics (DIAL) with the fields of their current winners (USSEP, Brawl Lines
  Expansion, FameCommentsReloaded, Unofficial Skyrim Modders Patch, SexLab_Solutions); only the list of lines differs.
  Rebuild after updating those mods. Four innkeeper-only lines take the vanilla body to keep SexLab_Solutions off the masters.
- Voice files: `Sound\Voice\SL Survival - Hopeless Escorts Generic Voice.esp\<escort's vanilla voice type>\<vanilla quest/topic prefix>_<00 + INFO id>_1.fuz`.

## Requirements
SL Survival, `SL Survival - Hopeless Escorts.esp` (master). Regular plugin (voiced dialogue, not ESL).

## Sources
`work\SLS_escorts\voices\` of the source folder: `gen_generic_stage.py` (create/copy/conds/order manifests),
`stage1_*` and `stage2_*` (lines, houseCARL reads and ops), `build_generic_fuz.py`, plan `GENERIC_INTEGRATION_PLAN-RU.md`.

---

## Hopeless Escorts Faces

# SL Survival - Hopeless Escorts Faces 1.0.0

Gives the six free "hopeless escorts" of `SL Survival - Hopeless Escorts.esp` the faces of six men from
Northbourne NPCs of the Rift.

| Escort | Face from | Race after the swap |
|---|---|---|
| Drunk Militiaman | Arnskar | Nord |
| Town Beggar | Mercer Frey | Breton |
| Scribe's Apprentice | Narfi | Nord |
| Farmhand | Saerlund | Nord |
| Frightened Recruit | Vipir the Fleet | Nord |
| Retired Watchman | Elgrim | Old People Race |

## How it works

- `SL Survival - Hopeless Escorts Faces.esp` (ESL-flagged, master Skyrim.esm only) holds appearance-only copies of the six
  donors (no factions, scripts, inventory or packages) and the 22 head parts they use, with their baked FaceGen.
- SkyPatcher (`SKSE\Plugins\SkyPatcher\npc\SLSHopelessEscortsFaces\appearance.ini`) applies `copyVisualStyle` from each
  donor to its escort: race, height, weight, tint, hair colour, face texture, head parts and the FaceGen lookup.
- The escorts keep their own voice types, so their voiced dialogue is unchanged.
- Three of the source FaceGen meshes pointed their face-tint slot at the author's RaceMenu export
  (`Data\SKSE\Plugins\CharGen\<name>.dds`), which would render a dark face; here the slot points at the shipped FaceTint.

## Requirements

SKSE, SkyPatcher, High Poly Head, KS Hairdos (textures), `SL Survival - Hopeless Escorts.esp`.
Northbourne NPCs of the Rift is NOT needed and should stay disabled.

## Notes

SkyPatcher patches the escort records when the game loads data, so escorts spawned after that get the new faces.
Built by `work\SLS_escorts\faces\build.py`.
