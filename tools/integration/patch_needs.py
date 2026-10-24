"""Apply the integration edits to src\\_sls_needs.psc (a copy of crajjjj/SLSurvival 0.716 scripts\\source\\_sls_needs.psc).
Re-run on a fresh copy: python tools\\patch_needs.py"""
import os
import shutil

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, 'orig', '_sls_needs.psc')
DST = os.path.join(ROOT, 'src', '_sls_needs.psc')

s = open(SRC, encoding='utf-8-sig').read().replace('\r\n', '\n')
s = '\n'.join(line.rstrip() for line in s.split('\n'))  # blank lines in the source may carry stray tabs


def rep(old, new):
    global s
    old = '\n'.join(line.rstrip() for line in old.split('\n'))
    assert old in s, 'anchor not found: ' + old[:80]
    s = s.replace(old, new, 1)


rep('''_SLS_InterfaceSpankThatAss Property Sta Auto
''', '''_SLS_InterfaceSpankThatAss Property Sta Auto
; Integration patch: filled by crajjjj's optional "SL Survival Sunhelm Patch.esp" when it is installed, None otherwise
_SLS_InterfaceShs Property Shs Auto

; Integration patch: Creation Club Survival Mode, looked up in IsCcsEnabled (no plugin edits needed)
Quest CcsHungerQuest
Quest CcsExhaustionQuest
GlobalVariable CcsModeEnabled
GlobalVariable CcsHungerValue
GlobalVariable CcsExhaustionValue
Float Property CcsFatigueScale = 2.0 Auto Hidden ; Survival Mode exhaustion runs to 960: SLS fatigue amounts x2, like SunHelm's 480 scale
''')

rep('''	ElseIf Game.GetModByName("EatingSleepingDrinking.esp") != 255
		GoToState("Esd")
	Else
		GoToState("")
	EndIf
EndFunction''', '''	ElseIf Game.GetModByName("EatingSleepingDrinking.esp") != 255
		GoToState("Esd")
	ElseIf Game.GetModByName("SunHelmSurvival.esp") != 255 && Shs ; needs the optional SunHelm patch plugin
		GoToState("Shs")
	ElseIf IsCcsEnabled()
		GoToState("Ccs")
	Else
		GoToState("")
	EndIf
EndFunction

; Creation Club Survival Mode is in the plugin list on AE whether or not it is switched on, so the switch decides,
; not the plugin. Fetches the forms on first use; True only while Survival Mode is running.
Bool Function IsCcsEnabled()
	If Game.GetModByName("ccqdrsse001-survivalmode.esl") == 255
		Return false
	EndIf
	If !CcsModeEnabled
		CcsModeEnabled = Game.GetFormFromFile(0x000826, "ccqdrsse001-survivalmode.esl") as GlobalVariable ; Survival_ModeEnabled
		CcsHungerValue = Game.GetFormFromFile(0x00081A, "ccqdrsse001-survivalmode.esl") as GlobalVariable ; Survival_HungerNeedValue
		CcsExhaustionValue = Game.GetFormFromFile(0x000816, "ccqdrsse001-survivalmode.esl") as GlobalVariable ; Survival_ExhaustionNeedValue
		CcsHungerQuest = Game.GetFormFromFile(0x000894, "ccqdrsse001-survivalmode.esl") as Quest ; Survival_NeedHungerQuest
		CcsExhaustionQuest = Game.GetFormFromFile(0x000899, "ccqdrsse001-survivalmode.esl") as Quest ; Survival_NeedExhaustionQuest
	EndIf
	Return CcsModeEnabled && CcsModeEnabled.GetValueInt() == 1 && CcsHungerQuest && CcsExhaustionQuest
EndFunction

; Stage 0..5 of a Survival Mode need from its current value
Int Function GetCcsStage(Quest NeedQuest, GlobalVariable NeedValue)
	Float[] Stages = _SLS_IntCcs.GetStageValues(NeedQuest)
	Float Value = NeedValue.GetValue()
	Int i = 5
	While i > 0
		If Value >= Stages[i]
			Return i
		EndIf
		i -= 1
	EndWhile
	Return 0
EndFunction''')

# SyncBedrollSleepFlag default, as in the SunHelm variant of this script
rep('''; Empty state functions ============================================================
''', '''Function SyncBedrollSleepFlag() ; No-op unless the needs mod has a bedroll latch to correct (SunHelm)
EndFunction

; Empty state functions ============================================================
''')

s = s.rstrip('\n') + '\n' + open(os.path.join(ROOT, 'tools', 'needs_states.psc.txt'), encoding='utf-8').read()
open(DST, 'w', encoding='utf-8', newline='\r\n').write(s)
print('wrote', DST)
