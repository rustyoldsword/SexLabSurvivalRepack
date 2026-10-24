Scriptname _SLS_GameStart Hidden
; "Has the game started?" for SLS systems that used to wait for MQ101 stage 240 (escaped Helgen).
; Alternate Perspective leaves MQ101 at 0..9 on its non-Helgen starts, so those systems (licence purchase blocks,
; curfew, evictions, dirt, trauma updates, bikini experience...) never started. Same rule as sls_mcm.CanEnableSnowberry:
; Skyrim Unbound - its start quest reached 100; Alternate Perspective - the player left AP's start cell and is not in
; the vanilla Helgen run (MQ101 10..239); otherwise MQ101 >= 240.

Bool Function HasStarted() Global
	Quest MQ101 = Game.GetFormFromFile(0x03372B, "Skyrim.esm") as Quest
	If Game.GetModByName("Skyrim Unbound.esp") != 255
		Return (Game.GetFormFromFile(0x000D62, "Skyrim Unbound.esp") as Quest).GetCurrentStageID() >= 100
	ElseIf Game.GetModByName("AlternatePerspective.esp") != 255
		Cell Here = Game.GetPlayer().GetParentCell()
		If !Here || Here == Game.GetFormFromFile(0x2C1D00, "AlternatePerspective.esp") as Cell
			Return false
		EndIf
		Int Stage = MQ101.GetCurrentStageID()
		Return Stage < 10 || Stage >= 240
	EndIf
	Return MQ101.GetCurrentStageID() >= 240
EndFunction
