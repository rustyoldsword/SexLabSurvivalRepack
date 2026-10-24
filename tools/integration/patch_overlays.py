"""SLS overlays -> SlaveTatsNG, and a mark for "Survival Ass Slapping" (crajjjj/SLSurvival 0.716, orig\\ -> src\\).

SLS_Utility painted its overlays (trauma wounds, curse collar/bikini, cum desperation) straight into RaceMenu slots
with CBBE/vanilla-head textures. When SlaveTatsNG and the "SL Survival - SlaveTats Pack" are installed they now go
through SlaveTats (section "SL Survival", tattoo "<file stem> [<Area>]"), which shares slots with every other
SlaveTats user and picks the UBE texture for UBE races. Anything SlaveTats cannot place falls back to the old path,
and removal also clears overlays a save still carries from the old path.

The ass slap (TIF 0703E57A, 050201A0) only played a gesture and sounds; it now also adds a spank trauma that fades
like the other trauma marks (respects the Trauma toggle).
Run: python tools\\patch_overlays.py"""
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def load(name):
    s = open(os.path.join(ROOT, 'orig', name), encoding='utf-8-sig').read().replace('\r\n', '\n')
    return '\n'.join(line.rstrip() for line in s.split('\n'))


def rep(s, old, new):
    old = '\n'.join(line.rstrip() for line in old.split('\n'))
    assert s.count(old) == 1, f'anchor found {s.count(old)}x: ' + old[:80]
    return s.replace(old, new, 1)


def save(name, s):
    open(os.path.join(ROOT, 'src', name), 'w', encoding='utf-8', newline='\r\n').write(s)
    print('wrote src\\' + name)


# --- _SLS_IntSlavetats: SlaveTats wrappers --------------------------------------------------------------------
s = load('_sls_intslavetats.psc')
s = s.rstrip('\n') + '''

; --- Integration patch: SLS overlays through SlaveTats (pack "SL Survival - SlaveTats Pack") ---------------------
Bool Function AddTattoo(Actor akTarget, String Section, String Name, Float Alpha) Global
	Return SlaveTats.simple_add_tattoo(akTarget, Section, Name, 0, true, true, Alpha)
EndFunction

Bool Function RemoveTattoo(Actor akTarget, String Section, String Name) Global
	Return SlaveTats.simple_remove_tattoo(akTarget, Section, Name, true, true)
EndFunction

Bool Function HasTattoo(Actor akTarget, String Section, String Name) Global
	Int Template = JMap.object()
	JMap.setStr(Template, "section", Section)
	JMap.setStr(Template, "name", Name)
	Int Matches = JArray.object()
	SlaveTats.query_applied_tattoos(akTarget, Template, Matches)
	Return JArray.count(Matches) > 0
EndFunction

Int Function CountFreeSlots(Actor akTarget, String Area) Global
	Int Count = 0
	Int i = SlaveTats.SLOTS(Area)
	While i > 0
		i -= 1
		If SlaveTats.get_applied_tattoo_in_slot(akTarget, Area, i) == 0
			Count += 1
		EndIf
	EndWhile
	Return Count
EndFunction
'''
save('_sls_intslavetats.psc', s)

# --- SLS_Utility: route the overlay helpers -------------------------------------------------------------------
s = load('sls_utility.psc')
s = rep(s, '''Int Function BeginOverlay(Actor akTarget, Float Alpha, String TextureToApply, String Area, Int SlotToUse = -1)
	Bool Gender = akTarget.GetLeveledActorBase().GetSex() as Bool''', '''Int Function BeginOverlay(Actor akTarget, Float Alpha, String TextureToApply, String Area, Int SlotToUse = -1)
	If UseSlaveTats() && _SLS_IntSlavetats.AddTattoo(akTarget, "SL Survival", TatName(TextureToApply, Area), Alpha)
		Debug.Trace("_SLS_: Applied SlaveTats overlay " + TatName(TextureToApply, Area) + " to " + akTarget.GetBaseObject().GetName())
		Return 0
	EndIf
	Bool Gender = akTarget.GetLeveledActorBase().GetSex() as Bool''')
s = rep(s, '''Function UpdateAlpha(Actor akTarget, Float Alpha, String TextureToUpdate, String Area) ; Unused
''', '''Function UpdateAlpha(Actor akTarget, Float Alpha, String TextureToUpdate, String Area) ; Unused
	If UseSlaveTats() && _SLS_IntSlavetats.HasTattoo(akTarget, "SL Survival", TatName(TextureToUpdate, Area))
		; SlaveTats keeps alpha per applied tattoo: re-apply with the new value
		_SLS_IntSlavetats.RemoveTattoo(akTarget, "SL Survival", TatName(TextureToUpdate, Area))
		_SLS_IntSlavetats.AddTattoo(akTarget, "SL Survival", TatName(TextureToUpdate, Area), Alpha)
		Return
	EndIf
''')
s = rep(s, '''Int Function GetEmptySlot(Actor akTarget, Bool Gender, String Area)
''', '''Int Function GetEmptySlot(Actor akTarget, Bool Gender, String Area)
	If UseSlaveTats()
		Return _SLS_IntSlavetats.GetAvailableSlots(akTarget, Area) ; SlaveTats owns the slots: its next free one, or -1
	EndIf
''')
s = rep(s, '''Int Function CountEmptySlots(Actor akTarget, String Area)
''', '''Int Function CountEmptySlots(Actor akTarget, String Area)
	If UseSlaveTats()
		Return _SLS_IntSlavetats.CountFreeSlots(akTarget, Area)
	EndIf
''')
s = rep(s, '''Bool Function HasOverlay(Actor akTarget, String TextureToUpdate, String Area)
''', '''Bool Function HasOverlay(Actor akTarget, String TextureToUpdate, String Area)
	If UseSlaveTats() && _SLS_IntSlavetats.HasTattoo(akTarget, "SL Survival", TatName(TextureToUpdate, Area))
		Return true
	EndIf
''')
s = rep(s, '''Int Function RemoveOverlay(Actor akTarget, String TextureToRemove, String Area)
''', '''Int Function RemoveOverlay(Actor akTarget, String TextureToRemove, String Area)
	Int TatResult = -1
	If UseSlaveTats() && _SLS_IntSlavetats.HasTattoo(akTarget, "SL Survival", TatName(TextureToRemove, Area))
		_SLS_IntSlavetats.RemoveTattoo(akTarget, "SL Survival", TatName(TextureToRemove, Area))
		TatResult = 0
	EndIf
	Int LegacySlot = RemoveOverlayLegacy(akTarget, TextureToRemove, Area) ; overlays a save still carries from before
	If TatResult == 0
		Return 0
	EndIf
	Return LegacySlot
EndFunction

Int Function RemoveOverlayLegacy(Actor akTarget, String TextureToRemove, String Area)
''')
s = rep(s, '''Function ClearOverlaySlot(Actor akTarget, Bool Gender, String Node)''', '''; Integration patch: SlaveTatsNG + the SLS SlaveTats pack present? Checked per call, cheap (plugin version + file)
Bool Function UseSlaveTats()
	Return SKSE.GetPluginVersion("SlaveTatsNG") > 0 && Game.GetModByName("SlaveTats.esp") != 255 && MiscUtil.FileExists("data/textures/actors/character/slavetats/SL Survival.json")
EndFunction

; "\\SL Survival\\BattleWounds\\Female\\Body\\Body - Left Spank (F).dds" + "Body" -> "Body - Left Spank (F) [Body]"
String Function TatName(String Texture, String Area)
	Int Pos = StringUtil.Find(Texture, "\\\\")
	While Pos != -1
		Texture = StringUtil.Substring(Texture, Pos + 1)
		Pos = StringUtil.Find(Texture, "\\\\")
	EndWhile
	Int Dot = StringUtil.Find(Texture, ".dds")
	If Dot != -1
		Texture = StringUtil.Substring(Texture, 0, Dot)
	EndIf
	Return Texture + " [" + Area + "]"
EndFunction

Function ClearOverlaySlot(Actor akTarget, Bool Gender, String Node)''')
save('sls_utility.psc', s)

# --- _SLS_Trauma: spank mark ----------------------------------------------------------------------------------
s = load('_sls_trauma.psc')
s = rep(s, '''Function AddRandomTrauma(Actor akActor)''', '''; Integration patch: "Survival Ass Slapping" leaves a fading spank mark: a UBE hand-print overlay on women (the spanked
; pack, "Body - Spanked N (F)"), the trauma pack's Left/Right Spank on men. Repeating a mark refreshes it instead of stacking.
Function AddSpankTrauma(Actor akActor)
	If !TraumaEnable || !akActor || StorageUtil.FormListFind(Self, "_SLS_ActorWipList", akActor) != -1
		Return
	EndIf
	StorageUtil.FormListAdd(Self, "_SLS_ActorWipList", akActor, AllowDuplicate = false)
	If StorageUtil.CountObjStringListPrefix(akActor, "_SLS_TexListAvailable") <= 0
		SetupActor(akActor)
	EndIf
	String Side = "Left"
	If Utility.RandomInt(0, 1) == 1
		Side = "Right"
	EndIf
	String Texture = "Body - " + Side + " Spank.dds"
	Int TraumaCountMax = PlayerTraumaCountMax
	If akActor.GetLeveledActorBase().GetSex() == 1
		; hand-print marks of the mod "SL Survival - Spanked Overlays UBE", three variants; the same variant again refreshes it
		Texture = "Body - Spanked " + Utility.RandomInt(1, 3) + " (F).dds"
	EndIf
	If akActor != PlayerRef
		If akActor.IsInFaction(PotentialFollowerFaction)
			TraumaCountMax = FollowerTraumaCountMax
		Else
			TraumaCountMax = NpcTraumaCountMax
		EndIf
	EndIf
	Int Active = StorageUtil.StringListFind(akActor, "_SLS_ActiveTraumas", Texture)
	If Active != -1 ; already marked: start its fade over
		StorageUtil.FloatListSet(akActor, "_SLS_ActiveTraumasBeginTimes", Active, Utility.GetCurrentGameTime())
		StorageUtil.SetFloatValue(akActor, "_SLS_LastTrauma", Utility.GetCurrentGameTime())
		UpdateActor(akActor)
	ElseIf BeginAddOverlay(akActor, Texture, TraumaCountMax) > -1
		StorageUtil.StringListRemove(akActor, "_SLS_TexListAvailable", Texture)
		StorageUtil.StringListInsert(akActor, "_SLS_ActiveTraumas", 0, Texture)
		StorageUtil.FloatListInsert(akActor, "_SLS_ActiveTraumasBeginTimes", 0, Utility.GetCurrentGameTime())
		StorageUtil.SetFloatValue(akActor, "_SLS_LastTrauma", Utility.GetCurrentGameTime())
	EndIf
	StorageUtil.FormListRemove(Self, "_SLS_ActorWipList", akActor, AllInstances = false)
EndFunction

Function AddRandomTrauma(Actor akActor)''')
# the spanked marks are for slaps only: once one fades out it must not return to the pool of random traumas
s = rep(s, '''	StorageUtil.FloatListRemoveAt(akActor, "_SLS_ActiveTraumasBeginTimes", Index)
	StorageUtil.StringListAdd(akActor, "_SLS_TexListAvailable", Trauma)''', '''	StorageUtil.FloatListRemoveAt(akActor, "_SLS_ActiveTraumasBeginTimes", Index)
	If StringUtil.Find(Trauma, "Spanked ") == -1
		StorageUtil.StringListAdd(akActor, "_SLS_TexListAvailable", Trauma)
	EndIf''')
save('_sls_trauma.psc', s)

# --- the two slap topic infos ---------------------------------------------------------------------------------
SPANK = '''(Game.GetFormFromFile(0x0F37A1, "SL Survival.esp") as _SLS_Trauma).AddSpankTrauma(PlayerRef) ; integration patch: leave a mark'''
s = load('tif__0703e57a.psc')
s = rep(s, '''_SLS_AssSlapGruntMarker.Play(PlayerRef)
''', '''_SLS_AssSlapGruntMarker.Play(PlayerRef)
''' + SPANK + '\n')
save('tif__0703e57a.psc', s)
s = load('tif__050201a0.psc')
s = rep(s, '''_SLS_AssSlapGruntMarker.Play(PlayerRef)
''', '''_SLS_AssSlapGruntMarker.Play(PlayerRef)
''' + SPANK + '\n')
save('tif__050201a0.psc', s)
