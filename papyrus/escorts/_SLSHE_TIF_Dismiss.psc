;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname _SLSHE_TIF_Dismiss Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
; The escort leaves when she sends him away; SpawnEscort deletes him on the next hand-over
(DialogueFollower as DialogueFollowerScript).SFF_DismissActor(akSpeaker, 0, 0)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Quest Property DialogueFollower Auto
