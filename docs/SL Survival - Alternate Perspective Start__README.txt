SL Survival - Alternate Perspective start fix

SLS decides whether the game has "started" from MQ101 (the Helgen intro) reaching stage 240. Alternate Perspective
leaves MQ101 at stage 0 on every start except its Helgen ones, so SLS thought the player never left the start:
the Snowberry starting licences never arrived, and Belly Inflation never switched on.

Patched SLS_Mcm.CanEnableSnowberry(): with AlternatePerspective.esp loaded the game counts as started once the player
is out of AP's start cell (APStartCell), unless an AP Helgen intro is running (MQ101 between 1 and 239), which still
waits for stage 240 as before. Without AP the original checks are unchanged.
Built from crajjjj/SLSurvival tag 0.716 (source identical to the installed sls_mcm.pex before the edit).

Snowberry start (_SLS_LicenceSnowberry.GiveLicences), changed to suit this load order:
- always the regular Armor licence, never the Bikini licence (a bikini licence alone puts the Bikini Curse on you);
- also a Property licence when Property licences are enabled and the player already owns a house (a house key in the
  inventory, e.g. an Alternate Perspective "own house" start), so the house is not taken away right after the start.

Update 2026-10-04
- Snowberry (start licences) is now ON by default (sls_mcm OnConfigInit). Before, its quest only started when the
  MCM was closed while still in the start cell; with Alternate Perspective the SLS MCM registers about a minute
  after a new game, so the licences never came. Switch it off in the MCM before leaving the start cell if unwanted.
- Forced escort (no follower outside a walled city): the EscortList.json shipped with SLS 0.716 is crajjjj's own
  list (Trouble of Heroine, CC Almsivi "Hands", Viriya, Calcelmo, Angi...). This patch overrides it with the 7
  vanilla mercenaries (Jenassa, Erik the Slayer, Belrand, Ahtar, Stenvar, Marcurio, Vorstag), and
  _sls_lictowncheckplayeralias picks one from the hold the player is taken to. Existing save: MCM > Licences >
  "Import escorts from json" once (it clears the old list first).

Update 2026-10-12 (what the code actually does, superseding the paragraphs above where they differ)
- CanEnableSnowberry with Alternate Perspective: the game counts as started once the player is out of APStartCell.
  The "MQ101 between 1 and 239 = AP Helgen intro" rule was dropped on 2026-10-04 (AP sets MQ101 to 3 / 6 / 7 on
  non-Helgen starts too).
- Snowberry is OPT-IN, as in SexLab Survival: the default-on of 2026-10-04 was reverted the same day. Tick
  "Snowberry" in the SLS MCM while still in the AP start cell to get the start licences.
