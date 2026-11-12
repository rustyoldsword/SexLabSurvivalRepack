;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname TIF__05009EB1 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
Main.KnockHost = Knock.CurrentSpeaker
Main.KnockDoor = Knock.CurrentDoor
Main.HostLocation = Main.KnockHost.GetCurrentLocation()
Devious.EquipDevice(PlayerRef, Devious.zad_armBinderHisec_Inventory)
Knock.SetResult_Succeeded()
Main.BeginKnockStay() ; crajjjj 0.802 port 2026-10-27: remembers the house to close it after the stay
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

SLS_Main Property Main Auto
SimplyKnockMainScript Property Knock Auto
Actor Property PlayerRef Auto
_SLS_InterfaceDevious Property Devious Auto
