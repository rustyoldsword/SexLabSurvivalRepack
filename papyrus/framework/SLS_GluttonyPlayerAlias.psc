Scriptname SLS_GluttonyPlayerAlias extends ReferenceAlias  

SLS_GluttonyInflationScript Property Gluttony Auto

Keyword Property VendorItemFood Auto

Bool EatCooldown = false

Function SLSFW_Equipped(Form akBaseObject, ObjectReference akReference)
	If akBaseObject as Potion
		If akBaseObject.HasKeyword(VendorItemFood)
			EatCooldown = true
			UpdateScale()
		EndIf
	EndIf
EndFunction

Function UpdateScale()
	GoToState("InProgress")
	While EatCooldown
		EatCooldown = false
		Utility.Wait(3.0)
	EndWhile
	Gluttony.BellyScaleUpdate()
	GoToState("")
EndFunction

State InProgress
	Function SLSFW_Equipped(Form akBaseObject, ObjectReference akReference)
		EatCooldown = true
	EndFunction
EndState


; called by SLSurvivalFramework.dll (equip hub) in states that act on equips; nothing to do here
Function SLSFW_Unequipped(Form akBaseObject, ObjectReference akReference)
EndFunction