Scriptname _SLSHE_Escort Hidden
{The free SL Survival escort: a nobody from SL Survival - Hopeless Escorts.esp, spawned fresh. Shared by the guards'
"where's your escort" hand-over (_SLS_LicTownCheckPlayerAlias) and the toll collector's "I need an escort" dialogue.}

; A fresh hopeless escort placed at akAt, or None when Hopeless Escorts.esp is not installed (callers then fall back to
; the escort list). Earlier spawned escorts that died or were dismissed are deleted here so they don't pile up.
Actor Function Spawn(ObjectReference akAt) Global
	Return SpawnPick(akAt, -1)
EndFunction

; As Spawn, but aiPick chooses the escort: an index into _SLSHE_EscortBases (0 militiaman, 1 beggar, 2 scribe's
; apprentice, 3 farmhand, 4 recruit, 5 watchman - the toll collector's pick list), or -1 for a random one
Actor Function SpawnPick(ObjectReference akAt, Int aiPick) Global
	FormList Bases = Game.GetFormFromFile(0x000806, "SL Survival - Hopeless Escorts.esp") as FormList
	FormList Spawned = Game.GetFormFromFile(0x000807, "SL Survival - Hopeless Escorts.esp") as FormList
	If !Bases || !Spawned || Bases.GetSize() == 0 || !akAt
		Return None
	EndIf
	Int i = Spawned.GetSize()
	While i > 0
		i -= 1
		Actor Old = Spawned.GetAt(i) as Actor
		If Old && (Old.IsDead() || !Old.IsPlayerTeammate())
			Spawned.RemoveAddedForm(Old)
			Old.Disable()
			Old.Delete()
		EndIf
	EndWhile
	If aiPick < 0 || aiPick >= Bases.GetSize()
		aiPick = Utility.RandomInt(0, Bases.GetSize() - 1)
	EndIf
	ActorBase Base = Bases.GetAt(aiPick) as ActorBase
	Actor Escort = akAt.PlaceActorAtMe(Base)
	If Escort
		Spawned.AddForm(Escort)
	EndIf
	Return Escort
EndFunction

; True while a spawned hopeless escort is alive and still following the player - one at a time
Bool Function HasLiving() Global
	FormList Spawned = Game.GetFormFromFile(0x000807, "SL Survival - Hopeless Escorts.esp") as FormList
	If !Spawned
		Return false
	EndIf
	Int i = Spawned.GetSize()
	While i > 0
		i -= 1
		Actor Escort = Spawned.GetAt(i) as Actor
		If Escort && !Escort.IsDead() && Escort.IsPlayerTeammate()
			Return true
		EndIf
	EndWhile
	Return false
EndFunction

; The new escort introduces himself with one of his INTRO lines (SL Survival - Hopeless Escorts Dialogue.esp)
Function Introduce(Actor akEscort) Global
	Topic Intro = Game.GetFormFromFile(0x00090C, "SL Survival - Hopeless Escorts Dialogue.esp") as Topic
	If akEscort && Intro
		akEscort.Say(Intro)
	EndIf
EndFunction
