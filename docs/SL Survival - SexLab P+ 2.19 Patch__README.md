# SL Survival - SexLab P+ 2.19 Patch

Replaces `_SLS_IntSlpp.pex` of SL Survival 0.716 (crajjjj) with a version that works on **SexLab P+ 2.18 and 2.19**.

SexLab P+ 2.19 removed the interaction API that SL Survival uses to tell whether a load was swallowed
(`HasInteractionType`, `CTYPE_Oral`/`CTYPE_Deepthroat`/`CTYPE_LickingShaft`, `GetPartnerByType`). On 2.19 the old calls
return False, so every confirmed oral finish was treated as a facial (`_sls_cumswallow`).

The script now checks the running SexLab P+ version (`SKSE.GetPluginVersion("SexLabUtil") >= 34799616` = 2.19.0)
on every call:
- 2.19: `GetPartnersByInteractionType(sucker, aOral / aDeepthroat / aLickingShaft)` contains the partner;
- 2.18: the original code, unchanged.

Everything else in the script is the 0.716 code. Install above `SexLab Survival 0.716`.
Source: `Source\Scripts\_SLS_IntSlpp.psc`.
