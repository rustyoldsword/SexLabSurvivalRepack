"""Smaller integration edits (crajjjj/SLSurvival 0.716 sources in orig\\ -> src\\):

_sls_interfaceslsf   SLSF Reloaded (SLSF Reloaded.esp) through its mod-event API; the old SLSF .esm keeps its path
_sls_compulsivesex   works under SexLab P+: enjoyment is raised through P+'s thread API instead of tapping SLSO's key
sls_warmbodies       "Sex Reduces Exposure" passed a positive amount, which raises Frostfall exposure (colder)

Run: python tools\\patch_small.py"""
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def load(name):
    s = open(os.path.join(ROOT, 'orig', name), encoding='utf-8-sig').read().replace('\r\n', '\n')
    return '\n'.join(line.rstrip() for line in s.split('\n'))


def rep(s, old, new):
    old = '\n'.join(line.rstrip() for line in old.split('\n'))
    assert old in s, 'anchor not found: ' + old[:80]
    return s.replace(old, new, 1)


def save(name, s):
    open(os.path.join(ROOT, 'src', name), 'w', encoding='utf-8', newline='\r\n').write(s)
    print('wrote src\\' + name)


# --- SLSF Reloaded --------------------------------------------------------------------------------------------
s = load('_sls_interfaceslsf.psc')
s = rep(s, '''Function PlayerLoadsGame()
	If Game.GetModByName("SexLab - Sexual Fame [SLSF].esm") != 255
		If GetState() != "Installed"
			GoToState("Installed")
		EndIf
''', '''Function PlayerLoadsGame()
	If Game.GetModByName("SexLab - Sexual Fame [SLSF].esm") != 255
		If GetState() != "Installed"
			GoToState("Installed")
		EndIf

	ElseIf Game.GetModByName("SLSF Reloaded.esp") != 255 ; integration patch
		If GetState() != "Reloaded"
			GoToState("Reloaded")
		EndIf
		; SLSF Reloaded only takes flags from registered plugins; registering is idempotent
		Int Handle = ModEvent.Create("SLSF_Reloaded_RegisterMod")
		If Handle
			ModEvent.PushString(Handle, "SL Survival.esp")
			ModEvent.Send(Handle)
		EndIf
''')
# Leaving the empty state fires this event for any state change, now also for "Reloaded"; the old SLSF .esm is
# absent then, and its form lookup only logged a "File does not exist" error.
s = rep(s, '''Event OnEndState()
	Utility.Wait(5.0) ; Wait before entering active state to help avoid making function calls to scripts that may not have initialized yet.
	FameQuest = Game.GetFormFromFile(0x01E157,"SexLab - Sexual Fame [SLSF].esm") as Quest
EndEvent''', '''Event OnEndState()
	Utility.Wait(5.0) ; Wait before entering active state to help avoid making function calls to scripts that may not have initialized yet.
	If Game.GetModByName("SexLab - Sexual Fame [SLSF].esm") != 255 ; integration patch: Reloaded does not use FameQuest
		FameQuest = Game.GetFormFromFile(0x01E157,"SexLab - Sexual Fame [SLSF].esm") as Quest
	EndIf
EndEvent''')
s = rep(s, '''Bool Function GetIsInterfaceActive()
	If GetState() == "Installed"
		Return true
	EndIf
	Return false
EndFunction''', '''Bool Function GetIsInterfaceActive()
	If GetState() == "Installed" || GetState() == "Reloaded"
		Return true
	EndIf
	Return false
EndFunction''')
s = rep(s, '''Quest FameQuest''', '''; SLSF Reloaded (integration patch): one-time increase at the player's current location through its mod event.
; Categories: Whore, Slut, Submissive (SLSF's Slave), Bestiality, Airhead (no skooma category; closest fit).
State Reloaded
	Function IncreaseSexFame(String FameType, Int Points)
		String Category
		If FameType == "Whore"
			Debug.Notification("Your fame as a whore in the area has increased")
			Category = "Whore"
		ElseIf FameType == "Slut"
			Debug.Notification("Your fame as a slut in the area has increased")
			Category = "Slut"
		ElseIf FameType == "Slave"
			Debug.Notification("Your fame as a slave in the area has increased")
			Category = "Submissive"
		ElseIf FameType == "Beast"
			Debug.Notification("Your fame as a beast fucker in the area has increased")
			Category = "Bestiality"
		ElseIf FameType == "Skooma"
			Debug.Notification("Your fame as a skooma slut in the area has increased")
			Category = "Airhead"
		Else
			Return
		EndIf
		Int Handle = ModEvent.Create("SLSF_Reloaded_SendManualFameGain")
		If Handle
			ModEvent.PushString(Handle, Category)
			ModEvent.PushString(Handle, "Current")
			ModEvent.PushInt(Handle, Points)
			ModEvent.PushInt(Handle, Points)
			ModEvent.Send(Handle)
		EndIf
	EndFunction
EndState

Quest FameQuest''')
save('_sls_interfaceslsf.psc', s)

# --- Compulsive Sex under SexLab P+ ---------------------------------------------------------------------------
s = load('_sls_compulsivesex.psc')
s = rep(s, '''		If Game.GetModByName("SLSO.esp") != 255
			RegisterForEvents()''', '''		If Game.GetModByName("SLSO.esp") != 255 || _SLS_IntSlpp.GetIsInstalled() ; integration patch: P+ has SLSO built in
			RegisterForEvents()''')
s = rep(s, '''		SlsoEnjoyKey = JsonUtil.GetIntValue("/SLSO/Config.json", "hotkey_bonusenjoyment")
		;SlsoUtilityKey = JsonUtil.GetIntValue("/SLSO/Config.json", "hotkey_utility")
		If SlsoEnjoyKey > 0; && SlsoUtilityKey > 0''', '''		; Integration patch: under P+ the enjoyment is raised through its thread API - there is no SLSO key to tap
		UsePPlus = Game.GetModByName("SLSO.esp") == 255 && _SLS_IntSlpp.GetIsInstalled()
		SlsoEnjoyKey = JsonUtil.GetIntValue("/SLSO/Config.json", "hotkey_bonusenjoyment")
		;SlsoUtilityKey = JsonUtil.GetIntValue("/SLSO/Config.json", "hotkey_utility")
		If SlsoEnjoyKey > 0 || UsePPlus; && SlsoUtilityKey > 0''')
s = rep(s, '''			Input.TapKey(SlsoEnjoyKey)
''', '''			If UsePPlus
				_SLS_IntSlpp.ModEnjoyment(Sexlab, CurrentTid, PlayerRef, PPlusEnjoymentPerTick)
			Else
				Input.TapKey(SlsoEnjoyKey)
			EndIf
''')
s = rep(s, '''Int SlsoEnjoyKey
''', '''Int SlsoEnjoyKey
Bool UsePPlus = false
Int Property PPlusEnjoymentPerTick = 2 Auto Hidden ; one SLSO bonus-enjoyment key tap, on P+'s 0-100 scale
''')
save('_sls_compulsivesex.psc', s)

# --- Warm Bodies ----------------------------------------------------------------------------------------------
s = load('sls_warmbodies.psc')
# 2026-10-12: the earlier sign flip here was WRONG - sls_mcm stores WarmBodies already negated (-value, default -3.0),
# so the original call passes a negative (= warmer) amount. Kept as the original, with a comment.
s = rep(s, '''	Frostfall.ModExposure(Menu.WarmBodies)''', '''	Frostfall.ModExposure(Menu.WarmBodies) ; integration patch 2026-10-12: back to the original - the MCM already stores this slider negated (WarmBodies = -value, default -3.0), so the value is the Frostfall-style 'negative = warmer' amount as it stands''')
save('sls_warmbodies.psc', s)
