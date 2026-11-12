;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 2
Scriptname TIF__08026E11 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_1
Function Fragment_1(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
TossOutDoor.GetReference().Lock(false)
TossOutDoor.GetReference().Activate(PlayerRef)
Int Tries = 0 ; 3.0.2: 20 s at most, then clean up anyway (a door another mod keeps shut held this forever)
While _SLS_PlayerSleepMarker.GetCurrentLocation().IsSameLocation(PlayerRef.GetCurrentLocation()) && Tries < 200
	Utility.Wait(0.1)
	Tries += 1
EndWhile
EvictionSleepTrack.CleanUp()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Actor Property PlayerRef Auto
ReferenceAlias Property TossOutDoor Auto
ObjectReference Property _SLS_PlayerSleepMarker Auto
SLS_EvictionSleepTrack Property EvictionSleepTrack Auto
