Scriptname SLSFW_Test Hidden
{SexLab Survival Framework test helpers, called from the console tools. Not used by gameplay.}

; Unlock a worn Devious Devices item through zadlibs, keeping it (not destroyed) in the inventory.
Bool Function DDUnlock(Armor akInventoryDevice) Global
	zadlibs libs = Quest.GetQuest("zadQuest") as zadlibs
	If !libs || !akInventoryDevice
		Return False
	EndIf
	Return libs.UnlockDevice(Game.GetPlayer(), akInventoryDevice, None, None, False, False)
EndFunction

; Same, for whatever device of the given type (keyword) the player wears.
Bool Function DDUnlockByKeyword(Keyword akDeviceKeyword) Global
	zadlibs libs = Quest.GetQuest("zadQuest") as zadlibs
	If !libs || !akDeviceKeyword
		Return False
	EndIf
	Return libs.UnlockDeviceByKeyword(Game.GetPlayer(), akDeviceKeyword, False)
EndFunction
