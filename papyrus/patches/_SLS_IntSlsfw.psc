Scriptname _SLS_IntSlsfw Hidden
{Integration patch: the hooks SexLab Survival Framework (SLSurvivalFramework.dll) offers the MCM, as global
functions that do nothing when the framework is not installed. The framework ships its own copy of this script
(it wins in the mod order) and forwards them to SLSFW, so "SL Survival - Patches" keeps working on its own.

Global on purpose: the MCM calls these while it holds SLS_Mcm - and, when it runs from PlayerLoadsGame, SLS_Init
as well - so they must not wait for another script's lock.}

; Holds back the framework's gate recheck (_SLS_TollUtil.FrameworkRecheckGates) while the MCM writes a batch of
; settings, and lets it go afterwards. Calls nest; the DLL runs one recheck when the last hold is released.
Function GatesHold(Bool abHold) global
EndFunction

; Asks the framework to re-run SLS's own gate decision once. False means there is no framework listening and the
; caller has to drive the gates itself.
Bool Function GatesChanged(String asReason) global
	Return false
EndFunction

; Whether a loaded actor passes the conditions of the quest's first alias, so a Stop/Start of a guard search quest
; would fill anything. Without the framework: always true (restart as SLS always did).
Bool Function GuardSearchHasMatch(Quest akQuest) global
	Return true
EndFunction

; The player's followers (framework: alias followers plus loaded teammates, no creatures / animal companions).
; Without the framework: an empty list (trauma's automatic follower tracking then does nothing).
Actor[] Function GetFollowers() global
	Actor[] Empty = new Actor[1]
	Return Empty
EndFunction
