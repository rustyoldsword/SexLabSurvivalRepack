Scriptname _SLS_OrgasmFatigueAlcohol extends ReferenceAlias  

Event OnPlayerLoadGame() ; crajjjj 0.806: restores the debuff's full strength after a load
	OrgFat.Refresh()
EndEvent

Function SLSFW_Equipped(Form akBaseObject, ObjectReference akReference)
	If akBaseObject as Potion && AlcoholicDrinksList.HasForm(akBaseObject)
		OrgFat.DrinkAlcohol(akBaseObject)
	EndIf
EndFunction

Formlist Property AlcoholicDrinksList Auto

_SLS_OrgasmFatigue Property OrgFat Auto


; called by SLSurvivalFramework.dll (equip hub) in states that act on equips; nothing to do here
Function SLSFW_Unequipped(Form akBaseObject, ObjectReference akReference)
EndFunction