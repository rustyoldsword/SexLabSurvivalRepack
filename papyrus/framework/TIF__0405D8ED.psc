;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname TIF__0405D8ED Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
; SLSFW: this runs at the START of "Not so fast bitch!" and the teleport used to fire ~4 s later,
; while the guard was still speaking. Moving the player out of the cell mid-line tears down the playing voice and
; crashed the audio thread (XAudio2_7.dll, BSXAudio2GameSound). Let the guard finish first (the line is ~6 s).
; An earlier line may have armed "teleport when the dialogue menu closes"; drop it now, before waiting, or both
; would fire (two teleports, two escorts).
TownCheckPlayerAlias.UnregisterForMenu("Dialogue Menu")
Utility.Wait(3.0)
Float Waited = 3.0
While akSpeaker && akSpeaker.IsInDialogueWithPlayer() && Waited < 15.0
	Utility.Wait(0.25)
	Waited += 0.25
EndWhile
TownCheckPlayerAlias.TeleportToEscortMarker()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

_SLS_LicTownCheckPlayerAlias Property TownCheckPlayerAlias Auto
