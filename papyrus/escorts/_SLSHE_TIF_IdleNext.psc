;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname _SLSHE_TIF_IdleNext Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
; Escort idle chatter cooldown: every idle line needs GameDaysPassed >= _SLSHE_IdleNext, and each line spoken pushes it
; _SLSHE_IdleGap game days ahead (the game itself asks for idle chatter every ~10-15 s)
_SLSHE_IdleNext.SetValue(GameDaysPassed.GetValue() + _SLSHE_IdleGap.GetValue())
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

GlobalVariable Property GameDaysPassed Auto
GlobalVariable Property _SLSHE_IdleNext Auto
GlobalVariable Property _SLSHE_IdleGap Auto
