Scriptname _SLS_IntSph Hidden
{SPH - Skyrim Pubic Hair wrappers (crajjjj 0.803, port 2026-10-27) - the only place referencing SPH's scripts. Callers
gate on Game.IsPluginInstalled("SPH - Skyrim Pubic Hair.esp") (the plugin is ESL-flagged, so GetModByName can't see
it): a call into a script that is not installed aborts the caller.}

; SPH's own shaving flow: it needs a razor and shaving cream, shows its pubis / armpits menu and explains every refusal
; itself (no cream, nothing to shave, still dressed).
Function StartShaving() Global
	SPH_Main Sph = Quest.GetQuest("SPH_MainQuest") as SPH_Main
	If Sph
		Sph.StartShaving()
	EndIf
EndFunction
