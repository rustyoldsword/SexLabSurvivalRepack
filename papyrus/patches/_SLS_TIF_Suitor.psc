;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname _SLS_TIF_Suitor Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
Answer(akSpeaker)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

; Easy-bed suitor (SL Survival - Revision Tweaks.esp, _SLSRT_SuitorAnswer0..2): Choice 0 = she lets him in,
; 1 = for a hundred septims, 2 = she sends him away. The scene is SLS's own consensual vaginal scene.
Function Answer(Actor akSpeaker)
	If Choice == 1
		Game.GetPlayer().AddItem(Game.GetFormFromFile(0x00000F, "Skyrim.esm"), 100)
	EndIf
	If Choice <= 1 && akSpeaker
		Main.StartSexVaginal(akSpeaker, SexCat = 0, DecWillIncFame = (Choice == 1))
		Utility.Wait(5.0) ; the alias keeps him for SexLab's actor checks while the scene starts
	EndIf
	SuitorQuest.Stop()
EndFunction

Int Property Choice Auto
SLS_Main Property Main Auto
Quest Property SuitorQuest Auto
