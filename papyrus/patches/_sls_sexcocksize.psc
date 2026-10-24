Scriptname _SLS_SexCockSize extends Quest  

Function BeginBonusEnjoyment(Actor Creature, Int tid, Int CockCount)
	CurrentTid = tid
	Float CockEnj
	Int TngSize = -1
	If Creature.GetRace().IsRaceFlagSet(0x00000001) ; playable race: the TNG size category (0..4) is the bonus
		TngSize = _SLS_IntTng.GetActorSize(Creature)
	EndIf
	If TngSize >= 0
		CockEnj = TngSize
	Else
		CockEnj = Math.Ceiling(Util.GetLoadSize(Creature)) + 1.0 ; ceiling of the real load, not of its truncation
	EndIf
	BonusEnj = (CockEnj + (0.75 * CockEnj * (CockCount - 1))) as Int
	If Init.DebugMode
		Debug.Notification("Bonus enj: " + BonusEnj)
	EndIf
	RegisterForSingleUpdate(0.01)
EndFunction

Event OnUpdate()
	If PlayerRef.IsInFaction(SexlabAnimatingFaction)
		Slso.ModEnjoyment(CurrentTid, PlayerRef, BonusEnj)
		If Menu.CockSizeBonusEnjFreq > 0.0
			RegisterForSingleUpdate(Menu.CockSizeBonusEnjFreq)
		EndIf
	Else
		Stop()
	EndIf
	;RegisterForSingleUpdate(3.0)
EndEvent

Int BonusEnj
Int CurrentTid

Actor Property PlayerRef Auto

Faction Property SexlabAnimatingFaction Auto

SLS_Mcm Property Menu Auto
SLS_Init Property Init Auto
SLS_Utility Property Util Auto
_SLS_InterfaceSlso Property Slso Auto
