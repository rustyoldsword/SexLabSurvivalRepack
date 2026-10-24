Scriptname _SLS_SteepFall extends ReferenceAlias

Function Shutdown()
	If SLSFW.IsReady()
		SLSFW.SteepFallStop()
	EndIf
	SteepFallHorse.Stop()
	Self.GetOwningQuest().Stop()
	PlayerRef.RemovePerk(_SLS_FallDamagePerk)
	PlayerRef.RemovePerk(_SLS_DeathResistPerk)
	SendModEvent("dhlp-Resume")
EndFunction

Function Begin()
	Self.GetOwningQuest().Start()
	FallBeginHeight = PlayerRef.GetPositionZ()
	LastWalkHeight = PlayerRef.GetPositionZ()
	LastUpdate = Utility.GetCurrentRealTime()
	StartWalkMonitor()
	RegisterForAnimationEvent(PlayerRef, "AnimObjectUnequip")
	SteepFallHorse.Start()
	GoToState("")
EndFunction

; SLSFW measures the walk natively and calls Trip(true); without the DLL the old 1 s poll while Forward is held runs
Function StartWalkMonitor()
	If SLSFW.IsReady()
		UnRegisterForControl("Forward")
		UnRegisterForUpdate()
		SLSFW.SteepFallStart(Self, JsonUtil.GetFloatValue("SL Survival/SteepFall.json", "fallheight", Missing = 150.0), JsonUtil.GetFloatValue("SL Survival/SteepFall.json", "crawlallowance", Missing = 60.0))
	Else
		RegisterForControl("Forward")
	EndIf
EndFunction

Event OnControlDown(string control)
	;Debug.Messagebox("Key down")
	If Game.IsMovementControlsEnabled() && Game.GetCameraState() != 3 ; Not free cam
		RegisterForSingleUpdate(1.0)
	EndIf
EndEvent

Event OnControlUp(string control, float HoldTime)
	;Debug.Messagebox("Key up")
	UnRegisterForUpdate()
EndEvent

Event OnUpdate()
	If SLSFW.IsReady() ; the native monitor owns the walk; Fallen.OnEndState's one-shot update lands here
		Return
	EndIf
	If Math.Abs(LastWalkHeight - PlayerRef.GetPositionZ()) > JsonUtil.GetFloatValue("SL Survival/SteepFall.json", "fallheight", Missing = 150.0) + Whirlwind + Ethereal + ((Init.IsCrawling as Float) * JsonUtil.GetFloatValue("SL Survival/SteepFall.json", "crawlallowance", Missing = 60.0)); Up or down
		Trip()
	Else
		RecordHeight()
	EndIf
	RegisterForSingleUpdate(1.0)
EndEvent

Event OnPlayerLoadGame()
	If Self.GetOwningQuest().IsRunning()
		StartWalkMonitor()
	EndIf
	RecordHeight()
	_SLS_FallDamageReduction.SetValue(JsonUtil.GetFloatValue("SL Survival/SteepFall.json", "falldamagereduction", Missing = 90.0))
EndEvent

Event OnLocationChange(Location akOldLoc, Location akNewLoc) ; Unfortunately need both this and OnCellLoad to cover everything. Or more at least...
	;Debug.Messagebox("Loc change")
	RecordHeight()
EndEvent

Event OnCellLoad()
	RecordHeight()
	;Debug.Messagebox("Cell load")
EndEvent

Event OnBeginState()
	RegisterForAnimationEvent(PlayerRef, "AnimObjectUnequip")
	;RegisterForAnimationEvent(PlayerRef, "FootRight")
	RecordHeight()
EndEvent

Event OnAnimationEvent(ObjectReference akSource, string asEventName)
	If PlayerRef.GetAnimationVariableBool("bInJumpState")
		;Debug.Messagebox(asEventName)
		GoToState(asEventName)
	EndIf
EndEvent

Function RecordHeight()
	LastWalkHeight = PlayerRef.GetPositionZ()
	LastUpdate =  Utility.GetCurrentRealTime()
	;Debug.Trace("_SLS_ TEST: Time between updates: " + (Utility.GetCurrentRealTime() - LastUpdate))
	;LastUpdate = Utility.GetCurrentRealTime()
EndFunction

Function Trip(Bool IsDrop = false)
	If CanTrip(PlayerRef)
		If IsDrop || Utility.GetCurrentRealTime() -  LastUpdate < 1.2 ; If last update was too long ago then just record height and continue. If it's a drop then time not a factor
			;Debug.Messagebox("IsDrop: + " + IsDrop + "\nTime lapse: " + (Utility.GetCurrentRealTime() -  LastUpdate) + "\nLastWalkHeight: " + LastWalkHeight + "\nCur Height: " + PlayerRef.GetPositionZ() + "\nCalc: " + Math.Abs(LastWalkHeight - PlayerRef.GetPositionZ()))
			GoToState("Fallen")
			PlayerRef.AddPerk(_SLS_FallDamagePerk)
			PlayerRef.AddPerk(_SLS_DeathResistPerk)
			SendModEvent("dhlp-Suspend")
			PlayerRef.PushActorAway(PlayerRef, JsonUtil.GetFloatValue("SL Survival/SteepFall.json", "fallforcemultiplier", Missing = 2.0))
			;_SLS_PushPlayerSpell.Cast(PlayerRef, PlayerRef)
			
			If PlayerRef.IsSneaking()
				If JsonUtil.GetIntValue("SL Survival/SteepFall.json", "falldetectionevent", Missing = 1) && Utility.RandomFloat(0.0, 100.0) > PlayerRef.GetAv("Sneak")
					;Debug.Messagebox("Noisy")
					DoTripSound()
				;Else
					;Debug.Messagebox("Quiet")
				EndIf
			Else
				DoTripSound()
			EndIf
			StripItemByCount(Count = Utility.RandomInt(JsonUtil.GetIntValue("SL Survival/SteepFall.json", "itemstripcountmin", Missing = 1), JsonUtil.GetIntValue("SL Survival/SteepFall.json", "itemstripcountmax", Missing = 3)))
		Else
			;Debug.Notification("Failed time window")
			RecordHeight()
		EndIf
	EndIf
EndFunction

Function DoTripSound()
	; Pain grunt via the bundled SLS1 "Pain" voice slot (same PlayPain routing as
	; Util.DoFemalePainSound, lipsynced); either way the trip still makes detection noise
	; below. 0 = AudioUtil absent - legacy Sound form.
	; SLS1 slot and _SLS_PainSM are female voices: a male player gets SLS's own male pain grunt instead
	; (_SLS_BarefootPainMaleSM, the sound _SLS_BarefootSpeed already uses for men)
	If PlayerRef.GetActorBase().GetSex() == 1
		If _SLS_IntAudioUtil.PlayPain(PlayerRef, 0.5) == 0
			Int Pain = _SLS_PainSM.Play(PlayerRef)
			Sound.SetInstanceVolume(Pain , 0.5)
		EndIf
	Else
		Sound MalePain = Game.GetFormFromFile(0x0F9DF4, "SL Survival.esp") as Sound ; _SLS_BarefootPainMaleSM
		If MalePain
			Int Grunt = MalePain.Play(PlayerRef)
			Sound.SetInstanceVolume(Grunt, 0.5)
		EndIf
	EndIf
	PlayerRef.CreateDetectionEvent(PlayerRef, aiSoundLevel = 25 + (100 - (PlayerRef.GetAv("Sneak") as Int)))
EndFunction

Function HorseTrip(Actor Horsey)
	;/ Can't rag doll the horse, only stagger :( 
	Horsey.PushActorAway(Horsey, 100.0)
	_SLS_PushPlayerSpell.Cast(Horsey, Horsey)
	/;
EndFunction

Bool Function CanTrip(Actor akActor)
	If akActor.IsSwimming() || akActor.IsInFaction(SexlabAnimatingFaction)
		Return false
	EndIf
	Return true
EndFunction

State AnimObjectUnequip ; Begin falling
	Event OnBeginState()
		;Debug.Messagebox("AnimObjectUnequip")
		UnRegisterForAnimationEvent(PlayerRef, "AnimObjectUnequip")
		RegisterForAnimationEvent(PlayerRef, "JumpDown") ; Land
		;UnRegisterForUpdate()
		;RegisterForAnimationEvent(PlayerRef, "IdleStop")
		RegisterForAnimationEvent(PlayerRef, "FootRight")
		RegisterForAnimationEvent(PlayerRef, "FootLeft")
		FallBeginHeight = PlayerRef.GetPositionZ()
		;Debug.Messagebox("Fall Begin")
	EndEvent
	
	Event OnEndState()
		UnRegisterForAnimationEvent(PlayerRef, "FootRight")
		UnRegisterForAnimationEvent(PlayerRef, "FootLeft")
		UnRegisterForAnimationEvent(PlayerRef, "JumpDown") ; Land
		RecordHeight()
	EndEvent
	
	Event OnAnimationEvent(ObjectReference akSource, string asEventName)
		;Debug.Messagebox("Landed???: " + asEventName + "\nJumpstate: " + PlayerRef.GetAnimationVariableBool("bInJumpState"))
		If (asEventName == "FootLeft" || asEventName == "FootRight") && !PlayerRef.GetAnimationVariableBool("bInJumpState") ; Don't trip if JumpDown didn't fire and the player is running and is not in jump state - Looks wrong to land safe then start running and fall
			;Debug.Messagebox("Just continue")
			GoToState("")
		ElseIf asEventName == "JumpDown"; || !PlayerRef.GetAnimationVariableBool("bInJumpState") ; Player can scooby-do in the air while falling - firing FootLeft or FootRight falsely triggering land event.
			;Debug.Messagebox("Actual land")
			;If Math.Abs(FallBeginHeight - PlayerRef.GetPositionZ()) > 140.0 ; Up or down
			If FallBeginHeight - PlayerRef.GetPositionZ() > JsonUtil.GetFloatValue("SL Survival/SteepFall.json", "fallheight", Missing = 150.0) + Whirlwind + Ethereal ; Down only
				;Debug.Messagebox("Fall Trip")
				Trip(true)
			Else
				GoToState("")
			EndIf
		EndIf
	EndEvent
	
	Event OnUpdate()
		RegisterForSingleUpdate(1.0)
	EndEvent
EndState

State Fallen
	Event OnBeginState()
		;Debug.Messagebox("Fallen")
		RegisterForAnimationEvent(PlayerRef, "getupend")
		UnRegisterForUpdate()
		;RegisterForAnimationEvent(PlayerRef, "FootLeft")
		;RegisterForAnimationEvent(PlayerRef, "FootRight")
	EndEvent
	
	Event OnEndState()
		UnRegisterForAnimationEvent(PlayerRef, "getupend")
		;UnRegisterForAnimationEvent(PlayerRef, "FootLeft")
		;UnRegisterForAnimationEvent(PlayerRef, "FootRight")
		RecordHeight()
		PlayerRef.RemovePerk(_SLS_FallDamagePerk)
		PlayerRef.RemovePerk(_SLS_DeathResistPerk)
		SendModEvent("dhlp-Resume")
		If LostCount > 0
			;Debug.Messagebox("HEELO")
			Utility.Wait(0.2)
			Debug.Notification("<font color='#CC0000'>Lost " + LostCount + " items!</font>")
			LostCount = 0
		EndIf
		RegisterForSingleUpdate(1.0)
	EndEvent
	
	Event OnAnimationEvent(ObjectReference akSource, string asEventName)
		;Debug.Messagebox("GetUp: " + asEventName)
		GoToState("")
	EndEvent
	
	Event OnUpdate()
		RegisterForSingleUpdate(1.0)
	EndEvent
	
	Function Trip(Bool IsDrop = false)
	EndFunction
EndState

Function StripItemByCount(Int Count)
	GetStripableItems()
	ObjectReference Trig = PlayerRef.PlaceAtMe(_SLS_DroppedItemTrig)
	Trig.MoveTo(Trig, afZOffset = 20.0)
	While Count >= 1
		Count -= 1
		If JsonUtil.GetFloatValue("SL Survival/SteepFall.json", "stripchance", Missing = 50.0) > Utility.RandomFloat(0.0, 100.0)
			If StorageUtil.FormListCount(PlayerRef, "_SLS_SteepFallStripForms") > 0
				StripItem(StorageUtil.FormListGet(PlayerRef, "_SLS_SteepFallStripForms", Utility.RandomInt(0, StorageUtil.FormListCount(PlayerRef, "_SLS_SteepFallStripForms") - 1)), Trig)
			EndIf
		EndIf
	EndWhile
	If StorageUtil.FormListCount(Trig, "_SLS_DroppedItems") > 0
		; Voice-pack "Oh" / bundled SLS1 gasp (lipsynced) first; 0 = legacy Sound form.
		If PlayerRef.GetActorBase().GetSex() == 1 && _SLS_IntAudioUtil.PlayGasp(PlayerRef) == 0 ; female voices only
			_SLS_FemaleGasp.Play(PlayerRef)
		EndIf
		LostCount = StorageUtil.FormListCount(Trig, "_SLS_DroppedItems")
		(Trig as _SLS_DroppedItemTrigger).InitTrigger()
	Else
		(Trig as _SLS_DroppedItemTrigger).Shutdown()
	EndIf
EndFunction

Function StripItem(Form akForm, ObjectReference Trig)
	;PlayerRef.UnequipItem(akForm)
	PlayerRef.UnequipItemEx(akForm, equipSlot = 0, preventEquip = false)
	If Menu.DropItems
		Debug.Trace("_SLS_ SteepFall: Dropping: " + akForm.GetName() + " - " + akForm)
		
		;ObjectReference ObjRef = PlayerRef.DropObject(akForm)
		ObjectReference ObjRef = LostFound.DropItem(PlayerRef, akForm)
		If ObjRef
			;ObjRef.SetMotionType(4, true)
			Int i = 10
			While !ObjRef.Is3DLoaded() && i > 0
				Utility.Wait(0.1)
				i -= 1
			EndWhile
			; SLSFW: drop the item at the player's feet with a light nudge. SLS placed it above the head (GetHeight + 20) and
			; pushed it with force 40-100 upwards/sideways, so cloth went flying and tumbling down the slope.
			ObjRef.MoveTo(PlayerRef, 40.0 * Math.Sin(PlayerRef.GetAngleZ()), 40.0 * Math.Cos(PlayerRef.GetAngleZ()), 25.0)
			ObjRef.ApplyHavokImpulse(Utility.RandomFloat(-1.0, 1.0), Utility.RandomFloat(-1.0, 1.0), -0.5, Utility.RandomFloat(JsonUtil.GetFloatValue("SL Survival/SteepFall.json", "stripforcemin", Missing = 3.0), JsonUtil.GetFloatValue("SL Survival/SteepFall.json", "stripforcemax", Missing = 8.0)))
			StorageUtil.FormListRemove(PlayerRef, "_SLS_SteepFallStripForms", akForm)
			StorageUtil.FormListAdd(Trig, "_SLS_DroppedItems", ObjRef, AllowDuplicate = false)
			StorageUtil.SetFormValue(ObjRef, "_SLS_DroppedItemTriggerRef", Trig)
		Else
			Debug.Trace("_SLS_ SteepFall: Error dropping: " + akForm.GetName() + " - " + akForm + " - No ObjRef")
		EndIf
	EndIf
EndFunction

Function GetStripableItems()
	Int i = 0
	Form akForm
	StorageUtil.FormListClear(PlayerRef, "_SLS_SteepFallStripForms")
	While i < Menu.SlotMasks.Length
		akForm = PlayerRef.GetWornForm(Menu.SlotMasks[i])
		If IsStripable(akForm)
			StorageUtil.FormListAdd(PlayerRef, "_SLS_SteepFallStripForms", akForm)
		EndIf
		i += 1
	EndWhile
	akForm = PlayerRef.GetEquippedWeapon(abLeftHand = false)
	If IsStripable(akForm)
		StorageUtil.FormListAdd(PlayerRef, "_SLS_SteepFallStripForms", akForm)
	EndIf
	akForm = PlayerRef.GetEquippedWeapon(abLeftHand = true)
	If IsStripable(akForm)
		StorageUtil.FormListAdd(PlayerRef, "_SLS_SteepFallStripForms", akForm, AllowDuplicate = false)
	EndIf
EndFunction

Bool Function IsStripable(Form akForm)
	; non-playable worn forms are engine/physics helpers (e.g. HDT SMP Object's HDTSMPObjectBase, slot 60): no 3D to drop
	If !akForm || !akForm.IsPlayable() || !akForm.GetName() || akForm.HasKeyword(SexlabNoStrip)
		Return false
	EndIf
	; by EditorID: also catches same-named copies (HDT SMP Object ships its own SexLabNoStrip) and needs no DD/ZaZ master
	If akForm.HasKeywordString("SexLabNoStrip")
		Return false
	EndIf
	; locked restraints never fall off: 242 DD/ZaZ/ToH worn devices in this load order carry no SexLabNoStrip
	If akForm.HasKeywordString("zad_Lockable") || akForm.HasKeywordString("zad_InventoryDevice") || akForm.HasKeywordString("zad_QuestItem") || akForm.HasKeywordString("zad_BlockGeneric")
		Return false
	EndIf
	If akForm.HasKeywordString("zbfWornDevice") || akForm.HasKeywordString("zbfWornGag") || akForm.HasKeywordString("zbfWornCollar") || akForm.HasKeywordString("zbfWornWrist") || akForm.HasKeywordString("zbfWornAnkles") || akForm.HasKeywordString("zbfWornBlindfold") || akForm.HasKeywordString("zbfWornHood")
		Return false
	EndIf
	Return true
EndFunction

Int LostCount

Float LastUpdate
Float LastWalkHeight
Float FallBeginHeight
Float Property Whirlwind Auto Hidden
Float Property Ethereal Auto Hidden

Actor Property PlayerRef Auto

Perk Property _SLS_FallDamagePerk Auto
Perk Property _SLS_DeathResistPerk Auto

Faction Property SexlabAnimatingFaction Auto

Spell Property _SLS_PushPlayerSpell Auto

Sound Property _SLS_PainSM Auto
Sound Property _SLS_FemaleGasp Auto

GlobalVariable Property _SLS_FallDamageReduction Auto

Keyword Property SexlabNoStrip Auto

Activator Property _SLS_DroppedItemTrig Auto

_SLS_LostFound Property LostFound Auto
_SLS_SteepFallHorse Property SteepFallHorse Auto
SLS_Init Property Init Auto
SLS_Mcm Property Menu Auto
