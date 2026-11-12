Scriptname _SLS_IntLlng Hidden
{Liquid Layers NG wrappers - the only place referencing LiquidLayersNG. Callers gate on
Game.IsPluginInstalled("Liquid Layers NG.esp") (the plugin is ESL-flagged, so GetModByName can't see it): a call into a
script that is not installed aborts the caller.}

; The actor wipes off every Liquid Layers NG layer (creampie animations and liquid meshes), whatever its wash settings.
; Returns 1 wiped, 0 nothing to wipe, -1 not now (in a SexLab scene or right after it).
; Liquid Layers NG older than 1.1.1 has no Wipe: the call logs a Papyrus error and returns 0.
Int Function Wipe(Actor akActor) Global
	Return LiquidLayersNG.Wipe(akActor)
EndFunction
