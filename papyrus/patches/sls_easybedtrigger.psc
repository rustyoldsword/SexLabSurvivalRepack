Scriptname SLS_EasyBedTrigger extends ObjectReference  

SLS_Mcm Property Menu Auto
SLS_EasyBeds Property EasyBeds Auto
Actor Property PlayerRef Auto

Event OnActivate(ObjectReference akActionRef)
	; 2026-10-24: also when easy-bed suitors are on (SL Survival - Revision Tweaks.esp _SLSRT_SuitorEnable)
	GlobalVariable Suitors = Game.GetFormFromFile(0x000806, "SL Survival - Revision Tweaks.esp") as GlobalVariable
	If akActionRef == PlayerRef && (Menu.EasyBedTraps || (Suitors && Suitors.GetValue() >= 1.0))
		EasyBeds.TrapSleepEvents()
	EndIf
EndEvent