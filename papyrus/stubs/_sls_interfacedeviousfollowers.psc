Scriptname _SLS_InterfaceDeviousFollowers extends Quest
Event OnInit()
EndEvent
Event OnUpdate()
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
Bool Function IsOldDeviousFollowers()
	Return False
EndFunction
Int Function GetDfVersion()
	Return 0
EndFunction
Function ModDfDebt(Float Amount)
EndFunction
Float Function UpdateWillLocal()
	Return 0.0
EndFunction
Float Function GetWillpower()
	Return 0.0
EndFunction
Function DecDflowWill(Float Amount = 0.0, Bool DoNotify = true)
EndFunction
Function DecResistWithSeverity(Float Amount = 1.0, Bool DoNotify = true, String Severity)
EndFunction
Bool Function HasActorCrawlKeyword(Actor akTarget)
	Return False
EndFunction
Bool Function HasArmorCrawlKeyword(Armor akArmor)
	Return False
EndFunction
Bool Function AddDfFollower(ObjectReference followerToAddForm, Int debtToAdd, Bool forceGoldControlMode, Float minimumContractDays)
	Return False
EndFunction
Quest _DFlow
Int DfVersion = -1
GlobalVariable Property _SLS_DflowWill Auto
Keyword Property _DFCrawlRequired Auto Hidden
SLS_Mcm Property Menu Auto
SLS_Init Property Init Auto
