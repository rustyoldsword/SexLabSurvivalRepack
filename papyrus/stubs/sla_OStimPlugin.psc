Scriptname sla_OStimPlugin Extends sla_PluginBase
Actor Property playerRef Auto
sla_DefaultPlugin Property defaultPlugin Auto
Form OStim
actor[] ActiveSceneActors
float[] previousModifiersThread0
float[] previousModifiersThread1
float[] previousModifiersThread2
float[] previousModifiersThread3
float[] previousModifiersThread4
float[] previousModifiersThread5
float[] previousModifiersThread6
float[] previousModifiersThread7
float[] previousModifiersThread8
float[] previousModifiersThread9
Actor currentObserver = none
bool isSeeingSex = false
int sexEff = -1
int fatigueEff = -1
int traumaEff = -1
bool alwaysCheckOrgasm = false
float sexEffMax = 50.0
float sexHalfTime = 0.04166666
float sexPerStage = 5.0
float traumaHalfTime = 0.5
float traumaBase = 11.0
float traumaLewdRate = 1.0
float fatigueHalfTime = 0.5
float fatigueBase = 5.0
bool function CheckDependencies()
	Return False
Endfunction
Float Function GetLewd(Actor who)
	Return 0.0
EndFunction
event OnEndState()
Endevent
Function StartPCMasturbation()
EndFunction
float function GetOptionValue(int optionId)
	Return 0.0
Endfunction
function OnUpdateOption(int optionId, float value)
Endfunction
int function registerOstimEventHandlers()
	Return 0
Endfunction
Event OStimStartThread(String EventName, String Args, float ThreadID, Form Sender)
EndEvent
Event OStimEndThread(String EventName, String Json, Float ThreadID, Form Sender)
EndEvent
Event OStimStart(String EventName, String Args, Float Nothing, Form Sender)
EndEvent
Event OStimEnd(String EventName, String Args, Float Nothing, Form Sender)
EndEvent
Event OStimOrgasmThread(String EventName, String Args, Float ThreadID, Form Sender)
EndEvent
Event OStimOrgasm(String EventName, String Args, Float Nothing, Form Sender)
EndEvent
Function HandleStartScene(int threadId, Actor[] threadActors)
EndFunction
Function HandleEndScene(int threadId, Actor[] threadActors)
EndFunction
Function HandleActorOrgasm(int threadId, Actor targetActor)
EndFunction
Function CalculateStimMultiplier(int threadId, Actor act, bool isAggressive, int index)
EndFunction
float[] Function GetPreviousModifiers(int ThreadID)
	Return None
EndFunction
Function CreatePreviousModifiers(int ThreadID)
EndFunction
Function ModifyPreviousModifiers(int ThreadID, int index, float modify)
EndFunction
bool function isInScene(Actor act)
	Return False
Endfunction
