;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname _SLSHE_TIF_ColCheck Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
; The toll collector's "I need an escort" answers pick between handing one over and "you already have one" by this
; global, so it is set as he starts talking, before the player's choices appear
_SLSHE_EscortAlive.SetValueInt(_SLSHE_Escort.HasLiving() as Int)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

GlobalVariable Property _SLSHE_EscortAlive Auto
