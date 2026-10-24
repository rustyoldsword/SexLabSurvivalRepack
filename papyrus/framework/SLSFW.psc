Scriptname SLSFW Hidden
{SexLab Survival Framework (SLSurvivalFramework.dll). Every caller checks IsReady() first and keeps its
old Papyrus path when the DLL is absent, so the framework mod can be switched off at any time.}

Bool Function IsReady() global native
Int Function GetApiVersion() global native

; prints the state of every module to the console and the SKSE log (cgf "SLSFW.Report")
String Function Report() global native

; ---- gates -----------------------------------------------------------------------------------------------------------

; locks or unlocks every door of akDoor's town (_SLS_TollDoors<Town>); returns the number of doors queued
Int Function SetTownGatesLocked(ObjectReference akDoor, Bool abLock, Int aiLockLevel) global native

; 0 Whiterun, 1 Solitude, 2 Markarth, 3 Windhelm, 4 Riften, -1 not a toll door
Int Function GetTollTown(ObjectReference akDoor) global native

; Gates v2: a toll door attached or SLS wants its gate rules re-run; the DLL calls _SLS_TollUtil.FrameworkRecheckGates once
; SLS's location state has been quiet for half a second
Function GatesChanged(String asReason) global native

; Gates v3: hold the recheck while the MCM writes a batch of settings. FrameworkRecheckGates takes _SLS_TollUtil and then
; reads SLS_Init / SLS_Mcm, while an MCM pass holds SLS_Init / SLS_Mcm and then calls _SLS_TollUtil: on 2026-10-15 the two
; met at a load and every SLS script hung for good. Holds nest, one recheck runs when the last one is released, and the DLL
; lets go by itself after 300s so a pass that dies cannot keep the gates frozen. Callers go through _SLS_IntSlsfw.
Function GatesHold(Bool abHold) global native

; called by the DLL for each door, so locking keeps vanilla ObjectReference.Lock behaviour
Function _LockDoor(ObjectReference akDoor, Bool abLock, Int aiLockLevel) global
	If akDoor
		If abLock
			akDoor.SetLockLevel(aiLockLevel)
		EndIf
		akDoor.Lock(abLock, true)
	EndIf
EndFunction

; ---- steep fall ------------------------------------------------------------------------------------------------------

Function SteepFallStart(ReferenceAlias akAlias, Float afFallHeight, Float afCrawlAllowance) global native
Function SteepFallStop() global native
Function SteepFallRebase() global native

; ---- diagnostics -----------------------------------------------------------------------------------------------------

; Papyrus events delivered since the last load (or ProfileReset), per script and event, busiest first.
; aiLimit lines (0 = 60); asFilter keeps only script names containing it ("" = every script, "sls" = SLS only)
String Function ProfileReport(Int aiLimit, String asFilter) global native
Function ProfileReset() global native

; ---- lost items ------------------------------------------------------------------------------------------------------

; _SLS_LostFound.UpdateLostCount reports how many drop spots are active; while any are, the DLL calls UpdateLostCount
; again whenever the player has moved, so the "Nearby Lost Items" widget follows the player
Function LostItemsTracking(Int aiActiveDropSpots) global native

; ---- guard searches --------------------------------------------------------------------------------------------------

; true when some loaded actor passes the conditions of akQuest's reference alias aiAliasId (the ESP's own conditions),
; i.e. a Stop/Start of the quest could fill it; SLS skips the restart when this is false. True when nothing to check.
Bool Function AliasHasMatch(Quest akQuest, Int aiAliasId) global native

; the toll-dodge guard search done natively: the actors akSearchQuest's aliases would fill (alias conditions, closest to
; the player first, one per alias), then the scripts' own test - IsDetectedBy and HasLOS for the toll, IsDetectedBy for
; the hunt. None / an empty array when nobody qualifies.
Actor Function FindSpottingGuard(Quest akSearchQuest) global native
Actor[] Function FindDetectingGuards(Quest akSearchQuest) global native

; ---- followers -------------------------------------------------------------------------------------------------------

; how many followers the player has: akFollowerQuest's alias references plus every loaded player teammate, without
; members of akExclude1/akExclude2 (SLS passes CreatureFaction and PlayerPotentialAnimalFaction)
Int Function CountFollowers(Quest akFollowerQuest, Faction akExclude1, Faction akExclude2) global native

; the same followers as a list (trauma tracking picks them up automatically, 2026-10-24)
Actor[] Function GetFollowers(Quest akFollowerQuest, Faction akExclude1, Faction akExclude2) global native

; gender inequality on the player as permanent stat modifiers instead of red magic effects; True takes them off and keeps them off
Function InequalitySuspend(Bool abSuspend) global native

; ---- Diary of Mine (SLS's Paradise Halls checks) -----------------------------------------------------------------------

; a Diary of Mine slave: the player's (DOMPlayerSlaveFaction) or another slaver's (DOMNotPlayerSlaveFaction)
Bool Function IsDomSlave(Actor akActor) global
	If !akActor || Game.GetModByName("DiaryOfMine.esm") == 255
		Return false
	EndIf
	Faction PlayerSlaves = Game.GetFormFromFile(0x56C505, "DiaryOfMine.esm") as Faction
	Faction OtherSlaves = Game.GetFormFromFile(0xD6A419, "DiaryOfMine.esm") as Faction
	Return (PlayerSlaves && akActor.IsInFaction(PlayerSlaves)) || (OtherSlaves && akActor.IsInFaction(OtherSlaves))
EndFunction

; Diary of Mine submission training (DOMTrainSubmission rank, 0-100 like PAH's PAHSubmission); -1 when unknown
Int Function GetDomSubmission(Actor akActor) global
	If !akActor || Game.GetModByName("DiaryOfMine.esm") == 255
		Return -1
	EndIf
	Faction Submission = Game.GetFormFromFile(0xBACA37, "DiaryOfMine.esm") as Faction
	If Submission && akActor.IsInFaction(Submission)
		Return akActor.GetFactionRank(Submission)
	EndIf
	Return -1
EndFunction

