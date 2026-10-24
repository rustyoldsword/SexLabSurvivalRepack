Scriptname _SLS_IntSlsfw Hidden
{The framework's copy of the MCM's integration hooks (the "SL Survival - Patches" copy does nothing). It wins in
the mod order, so the MCM reaches the DLL through it without depending on SLSFW being installed.

Global on purpose: the MCM calls these while it holds SLS_Mcm - and, when it runs from PlayerLoadsGame, SLS_Init
as well - so they must not wait for another script's lock.}

; Holds back the gate recheck (_SLS_TollUtil.FrameworkRecheckGates) while the MCM writes a batch of settings, and
; lets it go afterwards. Calls nest; the DLL runs one recheck when the last hold is released, and lets go by itself
; if a pass dies without releasing it.
Function GatesHold(Bool abHold) global
	If SLSFW.IsReady()
		SLSFW.GatesHold(abHold)
	EndIf
EndFunction

; Asks the DLL to re-run SLS's own gate decision once (it also does the door locking natively). False means the DLL
; is not there and the caller has to drive the gates itself.
Bool Function GatesChanged(String asReason) global
	If SLSFW.IsReady()
		SLSFW.GatesChanged(asReason)
		Return true
	EndIf
	Return false
EndFunction

Bool Function GuardSearchHasMatch(Quest akQuest) global
	If SLSFW.IsReady()
		Return SLSFW.AliasHasMatch(akQuest, 0)
	EndIf
	Return true
EndFunction

Actor[] Function GetFollowers() global
	If SLSFW.IsReady()
		Actor[] Fols = SLSFW.GetFollowers(Game.GetFormFromFile(0x0750BA, "Skyrim.esm") as Quest, Game.GetFormFromFile(0x000013, "Skyrim.esm") as Faction, Game.GetFormFromFile(0x09A7B2, "Skyrim.esm") as Faction)
		If Fols.Length > 0 ; an empty native list must not reach the caller as None
			Return Fols
		EndIf
	EndIf
	Actor[] Empty = new Actor[1]
	Return Empty
EndFunction
