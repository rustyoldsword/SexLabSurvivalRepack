;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname _SLS_TIF_KennelWork Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
DoWork()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

; 2026-10-24 (SLS revision, kennel): a morning job for a heroine sleeping at the kennel - three hours of mucking out
; the pens for a little gold and a heel of bread, once a day. Offered by the keeper in the morning while she stays
; there (SL Survival - Revision Tweaks.esp, _SLSRT_KennelWorkTopic).
Function DoWork()
	Actor PlayerRef = Game.GetPlayer()
	GlobalVariable GameHour = Game.GetFormFromFile(0x000038, "Skyrim.esm") as GlobalVariable
	GlobalVariable GameDaysPassed = Game.GetFormFromFile(0x000039, "Skyrim.esm") as GlobalVariable
	Game.FadeOutGame(true, true, 0.5, 1.0)
	Utility.Wait(1.5)
	GameHour.Mod(3.0)
	Int Pay = Utility.RandomInt(15, 30)
	PlayerRef.AddItem(Game.GetFormFromFile(0x00000F, "Skyrim.esm"), Pay, abSilent = true)
	PlayerRef.AddItem(Game.GetFormFromFile(0x065C97, "Skyrim.esm"), 1, abSilent = true)
	PlayerRef.DamageActorValue("Stamina", PlayerRef.GetActorValue("Stamina") * 0.5)
	KennelWorkNext.SetValue(Math.Floor(GameDaysPassed.GetValue()) + 1.0)
	Game.FadeOutGame(false, true, 0.5, 1.0)
	Debug.Notification("Three hours on your knees in the pens: " + Pay + " gold and a heel of bread. Good bitch.")
EndFunction

GlobalVariable Property KennelWorkNext Auto
