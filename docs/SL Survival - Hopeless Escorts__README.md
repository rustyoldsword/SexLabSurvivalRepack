# SL Survival - Hopeless Escorts 1.0.0

When the guards catch a woman outside the walls without an escort, SL Survival takes her to the barracks and
"finds someone to protect her". Before, that someone was a hired mercenary (Jenassa, Belrand, Marcurio...) handed
over for free. Now the guards hand over a nobody.

## What it adds
- `SL Survival - Hopeless Escorts.esp` (ESL-flagged, form 44): six male escorts, all level 1, cowardly,
  unaggressive, weak (class Beggar/Farmer/Citizen, health offset -20), in rags or work clothes:
  Drunk Militiaman, Town Beggar, Scribe's Apprentice, Farmhand, Frightened Recruit, Retired Watchman.
  Faces are High Poly Head heads/brows/beards, hair from KS Hairdos (LDD male hairstyle tweaks), vanilla eyes.
  Voices are vanilla follower voices (MaleDrunk, MaleNord, MaleEvenToned, MaleYoungEager), so the usual follower
  topics (wait, trade, part ways) work. They are in PotentialFollowerFaction.
- `_sls_lictowncheckplayeralias.pex`: the escort is spawned fresh from `_SLSHE_EscortBases` every time; earlier
  spawned escorts that died or were dismissed are deleted (tracked in `_SLSHE_SpawnedEscorts`). Without the plugin
  the old escort list (`EscortList.json`) is used as before.
- Same script, escort count fix (SLS-ESC-1): the short "Where's your escort cupcake?" greeting reads the stored
  follower count without recounting. The count is now refreshed when an escort is handed over (with a full
  re-check of all violations) and when contraband arms the town enforcer.

## Requirements
High Poly Head, KS Hairdos SSE + LDD KS Hairdos Male Hairstyle Tweaks (masters of the plugin).

## Notes
FaceGen is shipped (exported in the Creation Kit with Ctrl+F4, 2026-10-21): head meshes in
`meshes\actors\character\facegendata\facegeom\SL Survival - Hopeless Escorts.esp\00000800-805.nif` and tints in
`textures\actors\character\facegendata\facetint\SL Survival - Hopeless Escorts.esp\`. Without them the heads were
black. Re-export after any change to an escort's head parts, skin tone or face morphs.
