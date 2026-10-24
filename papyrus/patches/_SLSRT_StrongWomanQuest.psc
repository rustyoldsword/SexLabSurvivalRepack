Scriptname _SLSRT_StrongWomanQuest extends Quest

; 2026-10-24 (SLS revision): Mjoll's "A Woman of Strength" (SL Survival - Revision Tweaks.esp). Three trials, checked
; once per game hour:
;   10 - kill fifteen people since the quest began ("People Killed" stat; bandits, necromancers, Forsworn...)
;   20 - seven days in a row without a valid armor licence (the count restarts while she holds one)
;   30 - One-Handed, Two-Handed, Archery or Destruction at 50
; All three done -> stage 40 (return to Mjoll). Stage 100 is set by her dialogue (_SLS_TIF_StrongWoman).
; Forms are looked up by file so the script carries no properties to bind.

Int Property KillsNeeded = 15 AutoReadOnly
Float Property DaysNeeded = 7.0 AutoReadOnly
Float Property SkillNeeded = 50.0 AutoReadOnly

Int KillBase
Float NoLicenceSince
Bool KillsDone
Bool DaysDone
Bool SkillDone

Function Begin()
	KillBase = Game.QueryStat("People Killed")
	NoLicenceSince = Utility.GetCurrentGameTime()
	KillsDone = false
	DaysDone = false
	SkillDone = false
	SetStage(10)
	SetObjectiveDisplayed(10)
	SetObjectiveDisplayed(20)
	SetObjectiveDisplayed(30)
	RegisterForSingleUpdateGameTime(1.0)
	Check()
EndFunction

Event OnUpdateGameTime()
	If GetStage() < 40 && IsRunning()
		Check()
		If GetStage() < 40
			RegisterForSingleUpdateGameTime(1.0)
		EndIf
	EndIf
EndEvent

Function Check()
	Actor Player = Game.GetPlayer()
	If !KillsDone && Game.QueryStat("People Killed") - KillBase >= KillsNeeded
		KillsDone = true
		SetObjectiveCompleted(10)
	EndIf
	If !DaysDone
		_SLS_LicenceUtil LicUtil = Game.GetFormFromFile(0x0420BB, "SL Survival.esp") as _SLS_LicenceUtil
		If LicUtil && LicUtil.HasValidArmorLicence
			NoLicenceSince = Utility.GetCurrentGameTime()
		ElseIf Utility.GetCurrentGameTime() - NoLicenceSince >= DaysNeeded
			DaysDone = true
			SetObjectiveCompleted(20)
		EndIf
	EndIf
	If !SkillDone
		If Player.GetBaseActorValue("OneHanded") >= SkillNeeded || Player.GetBaseActorValue("TwoHanded") >= SkillNeeded || Player.GetBaseActorValue("Marksman") >= SkillNeeded || Player.GetBaseActorValue("Destruction") >= SkillNeeded
			SkillDone = true
			SetObjectiveCompleted(30)
		EndIf
	EndIf
	If KillsDone && DaysDone && SkillDone && GetStage() < 40
		SetStage(40)
		SetObjectiveDisplayed(40)
	EndIf
EndFunction

Function Finish()
	SetObjectiveCompleted(40)
	SetStage(100)
	UnregisterForUpdateGameTime()
	CompleteQuest()
	Stop()
EndFunction
