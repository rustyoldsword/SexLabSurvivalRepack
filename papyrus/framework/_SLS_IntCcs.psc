Scriptname _SLS_IntCcs Hidden
{Creation Club Survival Mode (ccqdrsse001-survivalmode.esl) wrappers - the only place referencing its script types.
The quests come in as parameters (looked up by the caller), so nothing here resolves before Survival Mode is known
to be loaded. Needs run from 0 (best) to 1000 (worst): hunger and cold to NeedMaxValue 1000, exhaustion to 960.
SLSFW: Survival Mode Improved (SKSE) strips the scripts off the need quests and keeps each need in its global
(Survival_HungerNeedValue...), so with SMI every call goes through SMI's globals and its Papyrus API instead.}

; Survival Mode Improved ============================================================================
; need index from the quest the caller passes: 0 hunger, 1 exhaustion, 2 cold (-1 not a need quest)
Int Function SmiNeed(Quest NeedQuest) Global
	If !NeedQuest || Game.GetModByName("SurvivalModeImproved.esp") == 255
		Return -1
	EndIf
	Int Id = Math.LogicalAnd(NeedQuest.GetFormID(), 0xFFF)
	If Id == 0x894 ; Survival_NeedHungerQuest
		Return 0
	ElseIf Id == 0x899 ; Survival_NeedExhaustionQuest
		Return 1
	ElseIf Id == 0x896 ; Survival_NeedColdQuest
		Return 2
	EndIf
	Return -1
EndFunction

GlobalVariable Function CcsGlobal(Int FormId) Global
	Return Game.GetFormFromFile(FormId, "ccqdrsse001-survivalmode.esl") as GlobalVariable
EndFunction

GlobalVariable Function SmiGlobal(Int FormId) Global
	Return Game.GetFormFromFile(FormId, "SurvivalModeImproved.esp") as GlobalVariable
EndFunction

; the current value, max and stage globals SMI reads for each need (its FormLoader)
GlobalVariable Function SmiValue(Int Need) Global
	If Need == 0
		Return CcsGlobal(0x81A)
	ElseIf Need == 1
		Return CcsGlobal(0x816)
	EndIf
	Return CcsGlobal(0x81B)
EndFunction

Float Function SmiMax(Int Need) Global
	GlobalVariable Max
	If Need == 0
		Max = CcsGlobal(0x80C)
	ElseIf Need == 1
		Max = CcsGlobal(0x84A)
	Else
		Max = CcsGlobal(0x84B)
	EndIf
	If Max
		Return Max.GetValue()
	EndIf
	Return 1000.0
EndFunction

GlobalVariable Function SmiStage(Int Need, Int Stage) Global ; Stage 1..5
	If Need == 0
		Int[] Ids = new Int[5]
		Ids[0] = 0x806
		Ids[1] = 0x802
		Ids[2] = 0x803
		Ids[3] = 0x804
		Ids[4] = 0x805
		Return CcsGlobal(Ids[Stage - 1])
	ElseIf Need == 1
		Return SmiGlobal(0xA16 + Stage) ; 0xA17..0xA1B
	EndIf
	Return SmiGlobal(0xD1F + Stage) ; 0xD20..0xD24
EndFunction

; SMI has no "increase" call: raise the need global (it is SMI's own value), capped like SMI's own tick; SMI moves the
; stage on its next update
Function SmiIncrease(Int Need, Float Amount, Float Cap) Global
	GlobalVariable Value = SmiValue(Need)
	If Value && Amount > 0.0
		Float NewValue = Value.GetValue() + Amount
		If NewValue > Cap
			NewValue = Cap
		EndIf
		If NewValue > Value.GetValue()
			Value.SetValue(NewValue)
		EndIf
	EndIf
EndFunction

; Hunger ============================================================================================
Function DecreaseHunger(Quest HungerQuest, Float Amount) Global ; the same buffered path Survival Mode's food uses
	If SmiNeed(HungerQuest) == 0
		SurvivalModeImprovedApi.RestoreHungerLevel(Amount)
		Return
	EndIf
	(HungerQuest as Survival_NeedHunger).DecreaseHungerBuffered(Amount)
EndFunction

Function IncreaseHunger(Quest HungerQuest, Float Amount) Global
	If SmiNeed(HungerQuest) == 0
		SmiIncrease(0, Amount, SmiMax(0))
		Return
	EndIf
	(HungerQuest as Survival_NeedHunger).IncreaseHunger(Amount)
EndFunction

; Exhaustion ========================================================================================
Function IncreaseExhaustion(Quest ExhaustionQuest, Float Amount) Global
	If SmiNeed(ExhaustionQuest) == 1
		SmiIncrease(1, Amount, SmiMax(1))
		Return
	EndIf
	(ExhaustionQuest as Survival_NeedExhaustion).IncreaseExhaustion(Amount)
EndFunction

Function DecreaseExhaustion(Quest ExhaustionQuest, Float Amount) Global
	If SmiNeed(ExhaustionQuest) == 1
		SurvivalModeImprovedApi.RestoreExhaustionLevel(Amount)
		Return
	EndIf
	; qualitySleep = true: a plain decrease; false is Survival Mode's "slept outdoors" rule that refuses to go below stage 2
	(ExhaustionQuest as Survival_NeedExhaustion).DecreaseExhaustion(Amount, true)
EndFunction

; Cold ==============================================================================================
Function IncreaseCold(Quest ColdQuest, Float Amount) Global
	If SmiNeed(ColdQuest) == 2
		; never colder than the area allows (SMI_CurrentAmbientTemp), like Survival Mode's customMaxValue -1
		Float Cap = SmiMax(2)
		GlobalVariable Ambient = SmiGlobal(0xD1D)
		If Ambient && Ambient.GetValue() < Cap
			Cap = Ambient.GetValue()
		EndIf
		SmiIncrease(2, Amount, Cap)
		Return
	EndIf
	; customMaxValue -1: never colder than the current area and weather allow, like Survival Mode's own tick
	(ColdQuest as Survival_NeedCold).IncreaseCold(Amount, -1.0)
EndFunction

Function DecreaseCold(Quest ColdQuest, Float Amount) Global
	If SmiNeed(ColdQuest) == 2
		SurvivalModeImprovedApi.RestoreColdLevel(Amount)
		Return
	EndIf
	(ColdQuest as Survival_NeedCold).DecreaseCold(Amount, -1.0, true)
EndFunction

; Area/weather cold level Survival Mode computed on its last cold tick (0 = warm area)
Int Function GetColdLevel(Quest ColdQuest) Global
	If SmiNeed(ColdQuest) == 2
		GlobalVariable Ambient = SmiGlobal(0xD1D) ; SMI_CurrentAmbientTemp
		If Ambient
			Return Ambient.GetValueInt()
		EndIf
		Return 0
	EndIf
	Return (ColdQuest as Survival_NeedCold).currentColdLevel
EndFunction

; lowest area cold level that can push the player into "Chilly" (cold stage 2)
Int Function GetChillyColdLevel(Quest ColdQuest) Global
	If SmiNeed(ColdQuest) == 2
		GlobalVariable Stage2 = SmiStage(2, 2) ; SMI caps cold at the ambient level, so stage 2 needs an area this cold
		If Stage2
			Return Stage2.GetValueInt()
		EndIf
		Return 9999
	EndIf
	Return (ColdQuest as Survival_NeedCold).coldStage2ColdLevelMin
EndFunction

Bool Function IsPlayerNearHeat(Quest HeatCheckQuest) Global
	If Game.GetModByName("SurvivalModeImproved.esp") != 255
		; SMI's UI temperature level (Update.esm Survival_TemperatureLevel): 1 = near heat
		GlobalVariable Level = Game.GetFormFromFile(0x2EDD, "Update.esm") as GlobalVariable
		Return Level && Level.GetValueInt() == 1
	EndIf
	Return (HeatCheckQuest as Survival_HeatCheck).IsPlayerNearHeatAndStanding()
EndFunction

; Shared ============================================================================================
; Lower bound of each stage, index 0..5 (stage 0 = "well fed" / "well rested" bonus below stage 1)
Float[] Function GetStageValues(Quest NeedQuest) Global
	Float[] Values = new Float[6]
	Values[0] = 0.0
	Int Need = SmiNeed(NeedQuest)
	If Need >= 0
		Int i = 1
		While i <= 5
			GlobalVariable Stage = SmiStage(Need, i)
			If Stage
				Values[i] = Stage.GetValue()
			EndIf
			i += 1
		EndWhile
		Return Values
	EndIf
	Survival_NeedBase NeedScript = NeedQuest as Survival_NeedBase
	Values[1] = NeedScript.needStage1Value
	Values[2] = NeedScript.needStage2Value
	Values[3] = NeedScript.needStage3Value
	Values[4] = NeedScript.needStage4Value
	Values[5] = NeedScript.needStage5Value
	Return Values
EndFunction

Float Function GetLastUpdateHours(Quest NeedQuest) Global ; in game hours (GameDaysPassed * 24)
	Int Need = SmiNeed(NeedQuest)
	If Need >= 0
		; SMI keeps the last update in game minutes (GetCurrentGameTime * 1440)
		GlobalVariable Last
		If Need == 0
			Last = SmiGlobal(0xA15)
		ElseIf Need == 1
			Last = SmiGlobal(0xA16)
		Else
			Last = SmiGlobal(0xD1F)
		EndIf
		If Last
			Return Last.GetValue() / 60.0
		EndIf
		Return 0.0
	EndIf
	Return (NeedQuest as Survival_NeedBase).lastTimeInGameHours
EndFunction
