;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname _SLSRT_TIF_WLClient Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
Answer(akSpeaker)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

; Whore licence client (SL Survival - Revision Tweaks.esp): Choice 0 = she takes him (paid _SLSRT_WL_Pay, SexLab
; scene through SLS's own Main.StartSexVaginal), 1 / 2 = she turns him away - he reports her (_SLSRT_WL_Duty.Refused).
Function Answer(Actor akSpeaker)
	String kPatch = "SL Survival - Revision Tweaks.esp"
	Quest ClientQuest = Game.GetFormFromFile(0x000860, kPatch) as Quest
	If Choice == 0
		Int Pay = (Game.GetFormFromFile(0x00085B, kPatch) as GlobalVariable).GetValueInt()
		Game.GetPlayer().AddItem(Game.GetFormFromFile(0x00000F, "Skyrim.esm"), Pay)
		If akSpeaker
			; SLS_Main lives on alias 0 of the _SLS_Main quest, not on the quest
			SLS_Main Main = (Game.GetFormFromFile(0x000D64, "SL Survival.esp") as Quest).GetAlias(0) as SLS_Main
			If Main
				Main.StartSexVaginal(akSpeaker, SexCat = 0, DecWillIncFame = true)
			EndIf
			Utility.Wait(5.0) ; the alias keeps him while SexLab checks the actors
		EndIf
	Else
		(Game.GetFormFromFile(0x00085F, kPatch) as _SLSRT_WL_Duty).Refused()
	EndIf
	ClientQuest.Stop()
EndFunction

Int Property Choice Auto
