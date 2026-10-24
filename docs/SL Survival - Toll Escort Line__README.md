# SL Survival - Toll Escort Line 1.0.0 (2026-10-23)

Light plugin (ESL flag). Masters: Skyrim.esm, Update.esm, SL Survival.esp.

When a woman with no escort tells a toll collector she can't afford the toll, SL Survival refuses her with
"You need to hire someone strong to look after you before I'll allow you to leave..." (INFO 00BD2F).
This plugin adds a second refusal line, and the game picks one of the two at random:

> Not so fast, bitch. First you need to find yourself a master to look after you out there.

- New INFO `_SLSTE_NoEscortMaster` (000800) in `_SLS_TolledGatesPayTollTopic`, with the same conditions as 00BD2F
  (TollIntroState > 0, toll collector faction, HasEnoughFollowers == -1) and Goodbye.
- 00BD2F gets the Random flag; the new line follows it (PreviousDialog = 00BD2F) with Random + RandomEnd.
- The "not enough protection" line (00BD2E, one follower too few) is unchanged.

## Voice

Six voice types: every SLS toll collector uses one of them (MaleNord, MaleDarkElf, MaleKhajiit, MaleOrc,
MaleCondescending, MaleArgonian). Voiced with Fish Audio by cloning each vanilla voice from its own vanilla lines.

`Sound\Voice\SL Survival - Toll Escort Line.esp\<VoiceType>\_sls_tolle__sls_tolledgate_00000800_1.fuz`

Rebuild: `work\SLS_toll_escort_line\build.py` (steps in its header).
