;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname _SLSRT_TIF_WLGuard Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
Answer(akSpeaker)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

; Whore licence report (SL Survival - Revision Tweaks.esp): the guard revokes the licence and fines her;
; Choice 1 = she argued, punished on top (_SLSRT_WL_Duty.Revoke).
Function Answer(Actor akSpeaker)
	String kPatch = "SL Survival - Revision Tweaks.esp"
	(Game.GetFormFromFile(0x00085F, kPatch) as _SLSRT_WL_Duty).Revoke(akSpeaker, Choice == 1)
	(Game.GetFormFromFile(0x000861, kPatch) as Quest).Stop()
EndFunction

Int Property Choice Auto
