Scriptname _SLS_IntTng Hidden
; The New Gentleman (TNG) - the only place that names TNG_PapyrusUtil, so SLS loads without TNG.

Int Function GetActorSize(Actor akActor) Global
	; 0..4 (TNG size categories), -1 = no TNG / not a TNG actor
	If !Game.IsPluginInstalled("TheNewGentleman.esp")
		Return -1
	EndIf
	Return TNG_PapyrusUtil.GetActorSize(akActor)
EndFunction
