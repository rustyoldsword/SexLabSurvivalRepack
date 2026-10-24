;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname _SLSRT_TIF_SDNpc Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
Init.DegradationDialogNpcChoice[Step] = Choice
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

; Self-degradation (SL Survival - Revision Tweaks.esp, 2026-10-24): the begging NPC dictates which words to say on
; step Step (0-3); SLS's own lines use choices 1-4, the added ones 5-7. Same as SLS's TIF__0501F13E and siblings.

Int Property Step Auto
Int Property Choice Auto
SLS_Init Property Init Auto
