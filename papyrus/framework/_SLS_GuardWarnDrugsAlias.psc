Scriptname _SLS_GuardWarnDrugsAlias extends ReferenceAlias  

Event OnInit()
	RegForDrugEvents()
EndEvent

; 2026-11-10: SLS's own forced-drugs events (sls_utility.SuspendSwAddicted/ResumeSwAddicted), no longer the fake SexLab
; PlayerTrack events. Registered on every load so older saves drop the PlayerTrack registration.
Function RegForDrugEvents()
	UnregisterForModEvent("PlayerTrack_Start")
	UnregisterForModEvent("PlayerTrack_End")
	RegisterForModEvent("_SLS_ForceDrugsBegin", "On_ForceDrugsBegin")
	RegisterForModEvent("_SLS_ForceDrugsEnd", "OnForceDrugsEnd")
EndFunction

Event OnUpdate()
	IsInForceDrugsPeriod = false
EndEvent

Event PlayerLoadsGame()
	RegForDrugEvents()
	If Init.SkoomaWhoreInstalled && Init.MilkAddictInstalled
		GoToState("SkoomaLactacid")
	ElseIf Init.SkoomaWhoreInstalled
		GoToState("Skooma")
	ElseIf Init.MilkAddictInstalled
		GoToState("Lactacid")
	Else
		GoToState("")
	EndIf
EndEvent

Event On_ForceDrugsBegin(String EventName, String StrArg, Float NumArg, Form Sender)
    IsInForceDrugsPeriod = true
EndEvent

Event OnForceDrugsEnd(String EventName, String StrArg, Float NumArg, Form Sender)
	RegisterForSingleUpdate(1.0)
EndEvent

Function SLSFW_Equipped(Form akBaseObject, ObjectReference akReference)
EndFunction

State Skooma
	Function SLSFW_Equipped(Form akBaseObject, ObjectReference akReference)
		If akBaseObject as Potion
			If !IsInForceDrugsPeriod && IsSkoomaDrug(akBaseObject)
				DidDrugs()
			EndIf
		EndIf
	EndFunction
EndState

State Lactacid
	Function SLSFW_Equipped(Form akBaseObject, ObjectReference akReference)
		If akBaseObject as Potion
			If !IsInForceDrugsPeriod && IsLactacid(akBaseObject)
				DidDrugs()
			EndIf
		EndIf
	EndFunction
EndState

State SkoomaLactacid
	Function SLSFW_Equipped(Form akBaseObject, ObjectReference akReference)
		If !IsInForceDrugsPeriod && akBaseObject as Potion
			If IsSkoomaDrug(akBaseObject) || IsLactacid(akBaseObject)
				DidDrugs()
			EndIf
		EndIf
	EndFunction
EndState

Bool Function IsSkoomaDrug(Form akBaseObject)
	If _SLS_DrugsListWoLactacid.HasForm(akBaseObject)
		Return true
	EndIf
	Return false
EndFunction

Bool Function IsLactacid(Form akBaseObject)
	If akBaseObject == Init.MME_Lactacid
		Return true
	EndIf
	Return false
EndFunction

Function DidDrugs()
	If _SLS_GuardWarnTypeAndCooldown.GetValueInt() == 0 ; Check is another warning in progress or in cooldown
		_SLS_PlayerIsAIDriven.SetValueInt((PlayerRef.GetCurrentPackage() != None) as Int)
		_SLS_GuardWarnDoApproach.SetValueInt(0)
		_SLS_GuardWarnDrugDetectionQuest.Stop()
		_SLS_GuardWarnDrugDetectionQuest.Start()
		Actor Guard = GuardAlias.GetReference() as Actor
		If Guard ; Detected
			_SLS_GuardWarnTypeAndCooldown.SetValueInt(2)
			If Guard.IsInFaction(_SLS_GuardBehaviourWarningFact)
				_SLS_GuardWarnDrugDetectionQuest.Stop()
				Util.SendBeginGuardWarnPunishEvent(_SLS_GuardWarnDrugDetectionQuest, Guard)
			EndIf
			_SLS_GuardWarnDoApproach.SetValueInt(1)
			Guard.EvaluatePackage()
		EndIf
	EndIf
EndFunction

Bool IsInForceDrugsPeriod = false

Quest Property _SLS_GuardWarnDrugDetectionQuest Auto

Actor Property PlayerRef Auto

GlobalVariable Property _SLS_GuardWarnDoApproach Auto
GlobalVariable Property _SLS_GuardWarnTypeAndCooldown Auto
GlobalVariable Property _SLS_PlayerIsAIDriven Auto

Faction Property _SLS_GuardBehaviourWarningFact Auto

Formlist Property _SLS_DrugsListWoLactacid Auto

ReferenceAlias Property GuardAlias Auto

SLS_Init Property Init Auto
SLS_Utility Property Util Auto


; called by SLSurvivalFramework.dll (equip hub) in states that act on equips; nothing to do here
Function SLSFW_Unequipped(Form akBaseObject, ObjectReference akReference)
EndFunction