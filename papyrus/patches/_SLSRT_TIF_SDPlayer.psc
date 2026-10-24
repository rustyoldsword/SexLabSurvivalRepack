;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname _SLSRT_TIF_SDPlayer Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
Said()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

; Self-degradation (SL Survival - Revision Tweaks.esp, 2026-10-24): the heroine said option Choice (5-7) on step
; Step (0-3) to a stranger; the listener's reaction runs this. Same as SLS's TIF__0501E095 and siblings.
Function Said()
	Init.DegradationDialogPlayerChoice[Step] = Choice
	(Game.GetFormFromFile(0x000D64, "SL Survival.esp") as SLS_Utility).BegSelfDegradationResistLoss()
	(Game.GetFormFromFile(0x0840A1, "SL Survival.esp") as _SLS_InterfaceSlsf).IncreaseSexFame("Slut", 5)
EndFunction

Int Property Step Auto
Int Property Choice Auto
SLS_Init Property Init Auto
