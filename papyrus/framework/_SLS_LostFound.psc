Scriptname _SLS_LostFound extends Quest  

ObjectReference Function DropItem(Actor akActor, Form akForm)
	akActor.UnEquipItem(akForm)
	ObjectReference ObjRef = akActor.DropObject(akForm)
	If ObjRef
		AddLostObject(ObjRef)
	Else
		Debug.Trace("_SLS_: LostFound: No ObjRef for: " + akForm.GetName() + " - " + akForm)
	EndIf
	Return ObjRef
EndFunction

Function AddLostObject(ObjectReference ObjRef)
	StorageUtil.FormListInsert(Self, "_SLS_LostFoundProcList", 0, ObjRef)
	ProcQueue()
EndFunction

Function ProcQueue()
	GoToState("InProc")
	Int i = StorageUtil.FormListCount(Self, "_SLS_LostFoundProcList")
	While StorageUtil.FormListCount(Self, "_SLS_LostFoundProcList") > 0
		ReferenceAlias akAlias = Self.GetNthAlias(Index) as ReferenceAlias
		ClearAlias(akAlias)
		;akAlias.ForceRefTo(StorageUtil.FormListPop(Self, "_SLS_LostFoundProcList") as ObjectReference)
		(akAlias as _SLS_LostFoundAlias).Setup(StorageUtil.FormListPop(Self, "_SLS_LostFoundProcList") as ObjectReference)
		Index += 1
		If Index >= Self.GetNumAliases()
			Index = 0
		EndIf
	EndWhile
	GoToState("")
EndFunction

Function ClearAlias(ReferenceAlias akAlias)
	ObjectReference ObjRef = akAlias.GetReference()
	If ObjRef
		SendMovedToStorageEvent(ObjRef)
		LostFoundBarrelRef.AddItem(ObjRef)
		UpdateLostCount()
	EndIf
	akAlias.Clear()
EndFunction

Function ClearObjRef(ObjectReference ObjRef)
	Int i = 0
	ReferenceAlias akAlias
	While i < GetNumAliases()
		If (GetNthAlias(i) as ReferenceAlias).GetReference() == ObjRef
			(GetNthAlias(i) as _SLS_LostFoundAlias).ClearAlias()
			Return
		EndIf
		i += 1
	EndWhile
EndFunction

State InProc
	Function ProcQueue()
	EndFunction
EndState

Function SendMovedToStorageEvent(ObjectReference ObjRef)
	Int StoredEvent = ModEvent.Create("_SLS_LostItemMovedToStorage")
	ModEvent.PushForm(StoredEvent, ObjRef)
	ModEvent.Send(StoredEvent)
EndFunction

Function UpdateLostCount()
	; SLSFW: the widget says "Nearby" but counted every lost item in the world. Count only the drop spots within
	; lostitemsradius (SteepFall.json, default 2000 units ~ 28 m); the framework DLL re-runs this as the player moves.
	Int i = StorageUtil.FormListCount(None, "_SLS_ActiveDroppedItemsTriggers")
	Int Triggers = i
	Float Radius = JsonUtil.GetFloatValue("SL Survival/SteepFall.json", "lostitemsradius", Missing = 2000.0)
	ObjectReference TrigRef
	ObjectReference ObjRef
	Int Count
	;Debug.Messagebox("TriggerCount: " + i)
	While i > 0
		i -= 1
		TrigRef = StorageUtil.FormListGet(None, "_SLS_ActiveDroppedItemsTriggers", i) as ObjectReference
		If TrigRef && PlayerRef.GetDistance(TrigRef) > Radius
			; far away: not "nearby", leave its list alone
		ElseIf TrigRef
			Int j = StorageUtil.FormListCount(TrigRef, "_SLS_DroppedItems")
			While j > 0
				j -= 1
				ObjRef = StorageUtil.FormListGet(TrigRef, "_SLS_DroppedItems", j) as ObjectReference
				If ObjRef
					Count += 1
				Else
					Debug.Trace("_SLS_: UpdateLostCount(): Warning: Bad object reference at index " + j + " on _SLS_DroppedItems. TrigRef: " + TrigRef + ". ObjRef: " + ObjRef)
					StorageUtil.FormListRemoveAt(TrigRef, "_SLS_DroppedItems", j)
					If StorageUtil.FormListCount(TrigRef, "_SLS_DroppedItems") == 0
						(TrigRef as _SLS_DroppedItemTrigger).Shutdown()
					EndIf
				EndIf
			EndWhile
		Else
			Debug.Trace("_SLS_: UpdateLostCount(): Warning: Bad trigger reference at index " + i + " on _SLS_ActiveDroppedItemsTriggers. TrigRef: " + TrigRef)
			StorageUtil.FormListRemoveAt(None, "_SLS_ActiveDroppedItemsTriggers", i)
		EndIf
	EndWhile
	LostWidget.UpdateDisplayedCount(Count)
	If SLSFW.IsReady()
		SLSFW.LostItemsTracking(Triggers)
	EndIf
EndFunction

Int Index

ObjectReference Property LostFoundBarrelRef Auto

Actor Property PlayerRef Auto

_SLS_LostFoundWidget Property LostWidget Auto
