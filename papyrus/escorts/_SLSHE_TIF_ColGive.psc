;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname _SLSHE_TIF_ColGive Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
; The toll collector hands over a free hopeless escort: same spawn as the guards' hand-over, without the teleport.
; The follower count is refreshed so the toll box and the "Pay toll" line accept her at once.
Actor Escort = _SLSHE_Escort.Spawn(Game.GetPlayer())
If Escort
	(DialogueFollower as DialogueFollowerScript).SetFollower(Escort)
	TollUtil.TollHasEnoughFollowers()
	Utility.Wait(1.0) ; let the dialogue close, or his intro line is cut off
	_SLSHE_Escort.Introduce(Escort)
EndIf
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Quest Property DialogueFollower Auto
_SLS_TollUtil Property TollUtil Auto
