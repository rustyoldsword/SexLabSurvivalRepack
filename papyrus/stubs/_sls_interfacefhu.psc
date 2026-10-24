Scriptname _SLS_InterfaceFhu extends Quest
Quest FhuConfigQuest
Quest FhuInflateQuest
ReferenceAlias DeflateAlias
Event OnInit()
EndEvent
Event On_SLS_Int_PlayerLoadsGame(string eventName, string strArg, float numArg, Form sender)
EndEvent
Function PlayerLoadsGame()
EndFunction
Event OnEndState()
EndEvent
Bool Function GetIsInterfaceActive()
	Return False
EndFunction
Float Function GetCumCapacityMax()
	Return 0.0
EndFunction
Float Function GetOralCumCapacityMax()
	Return 0.0
EndFunction
Event On_SLS_FhuInflate(Form akTarget, Int Hole, Float Time, Float TargetLevel = -1.0)
EndEvent
Function InflateTo(Actor akActor, int Hole, float time, float targetLevel = -1.0, String callback = "")
EndFunction
Float Function GetCumAmountForActor(Actor a, Actor[] all)
	Return 0.0
EndFunction
Float Function GetCurrentCumAnal(Actor akTarget)
	Return 0.0
EndFunction
Float Function GetCurrentCumVaginal(Actor akTarget)
	Return 0.0
EndFunction
Float Function GetCurrentCumOral(Actor akTarget)
	Return 0.0
EndFunction
Function DrainCum()
EndFunction
