Scriptname SKI_ConfigManager extends SKI_QuestBase
; compile-time stub (2026-11-08): sls_mcm.OnConfigRegister calls UnregisterMod. The real SkyUI source needs the full
; SKI_ConfigBase, while this build imports its public header. Never shipped.

Int Function UnregisterMod(SKI_ConfigBase a_menu)
	Return 0
EndFunction
