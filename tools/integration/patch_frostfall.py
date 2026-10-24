"""Integration edits to _sls_interfacefrostfall.psc (crajjjj/SLSurvival 0.716).

Without Frostfall the adapter used to sit in the empty state: no wetness, no cold, every caller no-op. The new
"Local" state serves the same calls from what this load order has: wetness from WetFunction NG, cold and fire
warmth from Creation Club Survival Mode. Frostfall, when installed, still wins.
Run: python tools\\patch_frostfall.py"""
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
s = open(os.path.join(ROOT, 'orig', '_sls_interfacefrostfall.psc'), encoding='utf-8-sig').read().replace('\r\n', '\n')
s = '\n'.join(line.rstrip() for line in s.split('\n'))  # blank lines in the source may carry stray tabs


def rep(old, new):
    global s
    old = '\n'.join(line.rstrip() for line in old.split('\n'))
    assert old in s, 'anchor not found: ' + old[:80]
    s = s.replace(old, new, 1)


rep('''Function PlayerLoadsGame()
	If Game.GetModByName("Frostfall.esp") != 255
		If GetState() != "Installed"
			GoToState("Installed")
		EndIf

	Else
		If GetState() != ""
			GoToState("")
		EndIf
	EndIf
EndFunction''', '''Function PlayerLoadsGame()
	WfngOn = Game.GetModByName("WetFunctionNG.esp") != 255
	If Game.GetModByName("Frostfall.esp") != 255
		If GetState() != "Installed"
			GoToState("Installed")
		EndIf

	ElseIf WfngOn || Game.GetModByName("ccqdrsse001-survivalmode.esl") != 255
		If GetState() != "Local"
			GoToState("Local")
		EndIf
		; the drench check polls WetFunction NG; re-arm it every load (Frostfall's mod event registration persisted on its own)
		RegisterForDrenchEvent(LicUtil.DrenchLicDestroyChance > 0.0)

	Else
		If GetState() != ""
			GoToState("")
		EndIf
	EndIf
EndFunction

; Creation Club Survival Mode: True only while it is switched on. Fetches the forms on first use.
Bool Function CcsOn()
	If Game.GetModByName("ccqdrsse001-survivalmode.esl") == 255
		Return false
	EndIf
	If !CcsModeEnabled
		CcsModeEnabled = Game.GetFormFromFile(0x000826, "ccqdrsse001-survivalmode.esl") as GlobalVariable ; Survival_ModeEnabled
		CcsColdQuest = Game.GetFormFromFile(0x000896, "ccqdrsse001-survivalmode.esl") as Quest ; Survival_NeedColdQuest
		CcsHeatQuest = Game.GetFormFromFile(0x000895, "ccqdrsse001-survivalmode.esl") as Quest ; Survival_HeatCheckQuest
	EndIf
	Return CcsModeEnabled && CcsModeEnabled.GetValueInt() == 1 && CcsColdQuest && CcsHeatQuest
EndFunction''')

rep('''; Not Installed ====================================
''', '''; Local: WetFunction NG + Survival Mode (integration patch) ==========
; Frostfall scales kept for the callers: wetness 0..750 (550 = damp, 750 = drenched), exposure + colder / - warmer
; on a ~120 point meter, temperature 10 = neutral and lower = cold.

State Local
	Bool Function IsPlayerWarming()
		If CcsOn()
			Return _SLS_IntCcs.IsPlayerNearHeat(CcsHeatQuest)
		EndIf
		Return true
	EndFunction

	Bool Function IsColdEnvironment()
		If CcsOn()
			Return _SLS_IntCcs.GetColdLevel(CcsColdQuest) >= _SLS_IntCcs.GetChillyColdLevel(CcsColdQuest)
		EndIf
		Return false
	EndFunction

	Int Function GetTemperature()
		If IsColdEnvironment()
			Return 5
		EndIf
		Return 10
	EndFunction

	Float Function GetWetness()
		If WfngOn
			Float Cap = _SLS_IntWfng.GetWetnessCap()
			If Cap > 0.0
				Return _SLS_IntWfng.GetWetness(PlayerRef) / Cap * 750.0
			EndIf
		EndIf
		Return 0.0
	EndFunction

	Function ModWetness(Float Amount)
		If WfngOn
			Float Cap = _SLS_IntWfng.GetWetnessCap()
			_SLS_IntWfng.SetWetness(PlayerRef, _SLS_IntWfng.GetWetness(PlayerRef) + Amount / 750.0 * Cap)
		EndIf
	EndFunction

	Function ModExposure(Float Amount)
		If CcsOn()
			If Amount > 0.0
				_SLS_IntCcs.IncreaseCold(CcsColdQuest, Amount * ExposureToCold)
			ElseIf Amount < 0.0
				_SLS_IntCcs.DecreaseCold(CcsColdQuest, -Amount * ExposureToCold)
			EndIf
		EndIf
	EndFunction

	; WetFunction NG sends no wetness event: poll while the licence destroy chance is set
	Function RegisterForDrenchEvent(Bool Reg)
		LicencesLost = 0
		IsDrenched = false
		DrenchPoll = Reg && WfngOn
		If DrenchPoll
			RegisterForSingleUpdate(5.0)
		Else
			UnRegisterForUpdate()
		EndIf
	EndFunction

	Event OnUpdate()
		If !DrenchPoll
			Return
		EndIf
		Float Wet = GetWetness()
		If IsDrenched
			If Wet >= 550.0
				If LicencesLost < MaxLicsToLose && LicUtil.GotDrenched()
					LicencesLost += 1
				EndIf
				RegisterForSingleUpdate(4.0)
				Return
			EndIf
			IsDrenched = false ; dried off to 'damp'
			LicencesLost = 0
		ElseIf Wet >= 749.0 ; soaked through
			IsDrenched = true
			RegisterForSingleUpdate(0.1)
			Return
		EndIf
		RegisterForSingleUpdate(5.0)
	EndEvent
EndState

; Not Installed ====================================
''')

# Leaving the empty state fires this event for ANY state change, and now also for "Local". Without Frostfall its
# Campfire/Frostfall form lookups only log ~20 "File does not exist" errors, so skip them unless Frostfall is installed.
rep('''Event OnEndState()
	Utility.Wait(5.0) ; Wait before entering active state to help avoid making function calls to scripts that may not have initialized yet.
	_SLS_Tents.Revert()''', '''Event OnEndState()
	Utility.Wait(5.0) ; Wait before entering active state to help avoid making function calls to scripts that may not have initialized yet.
	If Game.GetModByName("Frostfall.esp") == 255 ; integration patch: "Local" needs none of Frostfall's or Campfire's forms
		Return
	EndIf
	_SLS_Tents.Revert()''')

rep('''Bool IsDrenched = false
''', '''Bool IsDrenched = false
Bool WfngOn = false
Bool DrenchPoll = false
GlobalVariable CcsModeEnabled
Quest CcsColdQuest
Quest CcsHeatQuest
Float Property ExposureToCold = 8.0 Auto Hidden ; Frostfall exposure (~120) -> Survival Mode cold (1000)
''')

open(os.path.join(ROOT, 'src', '_sls_interfacefrostfall.psc'), 'w', encoding='utf-8', newline='\r\n').write(s)
print('wrote src\\_sls_interfacefrostfall.psc')
