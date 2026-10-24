Scriptname _SLS_PushPlayerCooloff extends Quest  

Event OnUpdateGameTime()
	_SLS_PushPlayerCooloffVar.SetValueInt(0)
EndEvent

Function BeginCooloff()
	If _SLS_GameStart.HasStarted()
		_SLS_PushPlayerCooloffVar.SetValueInt(1)
		RegisterForSingleUpdateGameTime(CooloffPeriod)
	EndIf
EndFunction

Float Property CooloffPeriod = 1.0 Auto Hidden

Quest Property MQ101 Auto

GlobalVariable Property _SLS_PushPlayerCooloffVar Auto
