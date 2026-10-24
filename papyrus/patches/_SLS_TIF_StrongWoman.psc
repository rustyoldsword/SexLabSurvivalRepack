;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname _SLS_TIF_StrongWoman Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
Answer()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

; Mjoll's "A Woman of Strength" (SL Survival - Revision Tweaks.esp): Choice 0 = she sets the trials (starts the quest),
; 1 = the trials are done - the heroine is declared a strong woman (sls_mcm.GrantStrongWoman).
Function Answer()
	_SLSRT_StrongWomanQuest Q = StrongQuest as _SLSRT_StrongWomanQuest
	If Choice == 0
		If StrongQuest.Start()
			Q.Begin()
		EndIf
	ElseIf Choice == 1
		(Menu as SLS_Mcm).GrantStrongWoman()
		Q.Finish()
		Debug.Notification("No one's property any more. Not a hole. Not a bitch. Free.")
	EndIf
EndFunction

Int Property Choice Auto
Quest Property StrongQuest Auto
Quest Property Menu Auto
