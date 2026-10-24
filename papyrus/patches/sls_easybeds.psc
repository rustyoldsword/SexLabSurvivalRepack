Scriptname SLS_EasyBeds extends ReferenceAlias

; 2026-10-24 (SLS revision): two things can wake the heroine in an "easy bed" now.
; - Suitors (SL Survival - Revision Tweaks.esp, on while _SLSRT_SuitorEnable is 1, women only, once a day): each hour
;   of sleep has a chance (20%, +5% per quiet hour) that a man from the same room comes to her bed. He is found by the
;   _SLSRT_Suitor quest's alias (closest awake adult man in the cell, not a follower) and starts the conversation; his
;   proposition is the quest's Hello, her answers lead to a SexLab scene or send him away (_SLS_TIF_Suitor).
; - Cursed Loot's bondage adventure / left in the wilderness, as before (only with DCL and the SLS "trap" option).
; The old "sneaking suspicion" message box on every bed activation is gone.

String Property kPatch = "SL Survival - Revision Tweaks.esp" AutoReadOnly

Function TrapSleepEvents()
	RegisterForSleep()
	RegisterForMenu("Sleep/Wait Menu")
EndFunction

Bool Function SuitorsReady()
	GlobalVariable Enable = Game.GetFormFromFile(0x000806, kPatch) as GlobalVariable
	GlobalVariable NextDay = Game.GetFormFromFile(0x000807, kPatch) as GlobalVariable
	If !Enable || Enable.GetValue() < 1.0 || PlayerRef.GetLeveledActorBase().GetSex() != 1
		Return false
	EndIf
	Return (Game.GetFormFromFile(0x000039, "Skyrim.esm") as GlobalVariable).GetValue() >= NextDay.GetValue()
EndFunction

Bool Function TrySuitor()
	Quest SuitorQuest = Game.GetFormFromFile(0x000808, kPatch) as Quest
	If !SuitorQuest || SuitorQuest.IsRunning()
		Return false
	EndIf
	If !SuitorQuest.Start()
		Return false
	EndIf
	Actor Suitor = (SuitorQuest.GetAlias(0) as ReferenceAlias).GetActorRef()
	If !Suitor
		SuitorQuest.Stop()
		Return false
	EndIf
	; wake her up and put him at her bedside
	IsPlayerSleeping = false
	PlayerRef.MoveTo(_SLS_PlayerSleepMarker)
	SleepyTimeFadeIn.Apply()
	PlayerRef.PlayIdle(Idle_1stPersonWoozyGetUpFromBed)
	Float Angle = PlayerRef.GetAngleZ()
	Suitor.MoveTo(PlayerRef, 70.0 * Math.Sin(Angle), 70.0 * Math.Cos(Angle), 0.0)
	Suitor.SetAngle(0.0, 0.0, Angle + 180.0)
	(Game.GetFormFromFile(0x000807, kPatch) as GlobalVariable).SetValue(Math.Floor((Game.GetFormFromFile(0x000039, "Skyrim.esm") as GlobalVariable).GetValue()) + 1.0)
	Utility.Wait(2.5)
	Suitor.Activate(PlayerRef) ; she "talks" to him: his Hello is the proposition
	Return true
EndFunction

Event OnSleepStart(float afSleepStartTime, float afDesiredSleepEndTime)
	IsPlayerSleeping = true
	Int StartTime = Math.Floor(GameHour.GetValue())
	_SLS_PlayerSleepMarker.MoveTo(PlayerRef)
	Bool Suitors = SuitorsReady()
	Bool Dcl = Init.DclInstalled && (Game.GetFormFromFile(0x000D64, "SL Survival.esp") as SLS_Mcm).EasyBedTraps
	Float SuitorChance = 20.0
	Bool DclFired = false

	While Math.Floor(GameHour.GetValue()) == StartTime && IsPlayerSleeping
		Utility.WaitMenuMode(0.2)
		If Math.Floor(GameHour.GetValue()) != StartTime
			If Suitors && Utility.RandomFloat(0.0, 100.0) < SuitorChance && TrySuitor()
				; IsPlayerSleeping is false now, the loop ends
			ElseIf Dcl && Utility.RandomFloat(1.0, 100.0) > 75.0
				IsPlayerSleeping = false
				DclFired = true
				PlayerRef.MoveTo(_SLS_PlayerSleepMarker)
				SleepyTimeFadeIn.Apply()
				If Utility.RandomFloat(1.0, 100.0) > 50.0
					SendModEvent("dcur-triggerbondageadventure")
				Else
					SendModEvent("dcur-triggerleaveinwilderness")
				EndIf
			Else
				SuitorChance += 5.0
			EndIf
		EndIf
		StartTime = Math.Floor(GameHour.GetValue())
	EndWhile

	If DclFired
		Int Count = 0
		While PlayerRef.GetCurrentLocation().IsSameLocation(_SLS_PlayerSleepMarker.GetCurrentLocation()) && Count < 45 ; Give DCL 90 seconds to move player
			Utility.Wait(2.0)
			Count += 1
		EndWhile

		If Count < 20
			FadeToBlackHoldImod.Remove()
			SleepyTimeFadeIn.Apply()
			PlayerRef.PlayIdle(Idle_1stPersonWoozyGetUpFromBed)
		Else
			Debug.Trace("SLS_: EasyBed event aborted - timeout")
		EndIf
	EndIf
EndEvent

Event OnSleepStop(bool abInterrupted)
	IsPlayerSleeping = false
	UnRegisterForSleep()
	UnRegisterForMenu("Sleep/Wait Menu")
EndEvent

Event OnMenuClose(String MenuName)
	UnRegisterForSleep()
	UnRegisterForMenu("Sleep/Wait Menu")
EndEvent

ImageSpaceModifier Property FadeToBlackHoldImod Auto
ImageSpaceModifier Property SleepyTimeFadeIn Auto
Idle Property Idle_1stPersonWoozyGetUpFromBed Auto
Bool Property IsPlayerSleeping = false Auto
ObjectReference Property _SLS_PlayerSleepMarker Auto
Actor Property PlayerRef Auto
GlobalVariable Property GameHour Auto
SLS_Init Property Init Auto
