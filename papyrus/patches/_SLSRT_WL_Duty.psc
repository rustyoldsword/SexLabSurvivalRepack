Scriptname _SLSRT_WL_Duty extends Quest

; Whore licence duties (SL Survival - Revision Tweaks.esp, 2026-10-24, plan audit\SLS Framework\WHORE-LICENCE-DUTIES-RU.md).
; Every game hour: with a valid whore licence, in an SLS town and free, a client may come (_SLSRT_WL_Client quest:
; the closest man in range walks up and force-greets). Turning him away files a report: after one game hour and for
; up to two days the town's guard (_SLSRT_WL_Guard) comes to her once she is in that town again; he revokes the
; licence, takes a fine and punishes, and the licence office will not sell a new one for _SLSRT_WL_BanDays.
; Settings are globals of the plugin (console: set _SLSRT_WL_Chance to 50).

String Property kPatch = "SL Survival - Revision Tweaks.esp" AutoReadOnly

Float Property LastClient = -1.0 Auto Hidden
String Property ReportTown = "" Auto Hidden
Float Property ReportTime = -1.0 Auto Hidden
Float Property BanUntil = -1.0 Auto Hidden
Float Property SentAt = -1.0 Auto Hidden ; real time a client or guard quest was started (timeout)

Float Property kReportDelay = 0.0416667 AutoReadOnly ; one game hour: the client walks to the guards
Float Property kReportLife = 2.0 AutoReadOnly ; days
Float Property kApproachTimeout = 90.0 AutoReadOnly ; real seconds for a client / guard to reach her

GlobalVariable Function G(Int aiID)
	Return Game.GetFormFromFile(aiID, kPatch) as GlobalVariable
EndFunction

Quest Function ClientQuest()
	Return Game.GetFormFromFile(0x000860, kPatch) as Quest
EndFunction

Quest Function GuardQuest()
	Return Game.GetFormFromFile(0x000861, kPatch) as Quest
EndFunction

_SLS_LicenceUtil Function LicUtil()
	Return Game.GetFormFromFile(0x0420BB, "SL Survival.esp") as _SLS_LicenceUtil
EndFunction

String Function Town()
	Return (Game.GetFormFromFile(0x0ECBC2, "SL Survival.esp") as _SLS_LocTrackCentral).PlayerCurrentLocString
EndFunction

Event OnInit()
	RegisterForSingleUpdateGameTime(1.0)
EndEvent

Event OnUpdateGameTime()
	Hourly()
	RegisterForSingleUpdateGameTime(1.0)
EndEvent

; short real-time watch while a report is pending or a client / guard is on the way
Event OnUpdate()
	Bool Busy = false
	Quest Q = ClientQuest()
	If Q.IsRunning()
		Busy = true
		If Utility.GetCurrentRealTime() - SentAt > kApproachTimeout && !UI.IsMenuOpen("Dialogue Menu")
			Q.Stop()
		EndIf
	EndIf
	Q = GuardQuest()
	If Q.IsRunning()
		Busy = true
		If Utility.GetCurrentRealTime() - SentAt > kApproachTimeout && !UI.IsMenuOpen("Dialogue Menu")
			Q.Stop()
		EndIf
	ElseIf ReportPending()
		Busy = true
		TrySendGuard()
	EndIf
	If Busy
		RegisterForSingleUpdate(10.0)
	EndIf
EndEvent

Bool Function ReportPending()
	Return ReportTime > 0.0 && Utility.GetCurrentGameTime() - ReportTime <= kReportLife
EndFunction

Bool Function Free(Actor akPlayer)
	If akPlayer.IsInCombat() || akPlayer.IsOnMount() || akPlayer.GetSleepState() != 0 || UI.IsMenuOpen("Dialogue Menu")
		Return false
	EndIf
	Faction Animating = Game.GetFormFromFile(0x00E50F, "SexLab.esm") as Faction
	Return !(Animating && akPlayer.IsInFaction(Animating))
EndFunction

Function Hourly()
	Float Now = Utility.GetCurrentGameTime()
	If BanUntil > 0.0 && Now >= BanUntil
		BanUntil = -1.0
		G(0x00085E).SetValue(0.0) ; _SLSRT_WL_Banned
	EndIf
	If ReportTime > 0.0 && !ReportPending()
		ReportTime = -1.0 ; the guards never caught up with her
		ReportTown = ""
	EndIf
	If ReportPending()
		RegisterForSingleUpdate(1.0)
		Return ; no new clients while a report is out
	EndIf
	TryClient(Now)
EndFunction

Function TryClient(Float afNow)
	Actor Player = Game.GetPlayer()
	If G(0x000858).GetValue() < 1.0 || !LicUtil().HasValidWhoreLicence || Player.GetLeveledActorBase().GetSex() != 1
		Return
	EndIf
	If Town() == "" || !Free(Player)
		Return
	EndIf
	If LastClient > 0.0 && (afNow - LastClient) * 24.0 < G(0x00085A).GetValue() ; _SLSRT_WL_Gap (hours)
		Return
	EndIf
	If Utility.RandomFloat(0.0, 100.0) >= G(0x000859).GetValue() ; _SLSRT_WL_Chance
		Return
	EndIf
	Quest Q = ClientQuest()
	If Q.IsRunning() || !Q.Start()
		Return
	EndIf
	If !(Q.GetAlias(0) as ReferenceAlias).GetReference()
		Q.Stop() ; nobody suitable around
		Return
	EndIf
	LastClient = afNow
	SentAt = Utility.GetCurrentRealTime()
	RegisterForSingleUpdate(10.0)
EndFunction

; client fragment: she turned him away
Function Refused()
	ReportTown = Town()
	ReportTime = Utility.GetCurrentGameTime()
	RegisterForSingleUpdate(10.0)
EndFunction

Function TrySendGuard()
	If Utility.GetCurrentGameTime() - ReportTime < kReportDelay || Town() != ReportTown || ReportTown == ""
		Return
	EndIf
	Actor Player = Game.GetPlayer()
	If !Free(Player)
		Return
	EndIf
	Quest Q = GuardQuest()
	If Q.IsRunning() || !Q.Start()
		Return
	EndIf
	If !(Q.GetAlias(0) as ReferenceAlias).GetReference()
		Q.Stop() ; no guard in range yet - try again in 10 s
		Return
	EndIf
	SentAt = Utility.GetCurrentRealTime()
EndFunction

; guard fragment: licence revoked, fine, punishment (always when she cannot pay; abHarsh when she argued)
Function Revoke(Actor akGuard, Bool abHarsh)
	_SLS_LicenceUtil L = LicUtil()
	L.NextWhoreExpiry = -1.0
	L.RevokeLicence("Whore", akGuard)
	L.UpdateConditionals()
	L.UpdateGlobalLicVariables()
	Actor Player = Game.GetPlayer()
	Int Fine = G(0x00085C).GetValueInt()
	Int Gold = Player.GetGoldAmount()
	If Gold > 0
		Player.RemoveItem(Game.GetFormFromFile(0x00000F, "Skyrim.esm"), PapyrusUtil.ClampInt(Fine, 0, Gold), false, akGuard)
	EndIf
	If abHarsh || Gold < Fine
		Punish(Player)
	EndIf
	Float Days = G(0x00085D).GetValue()
	ReportTime = -1.0
	ReportTown = ""
	BanUntil = Utility.GetCurrentGameTime() + Days
	G(0x00085E).SetValue(1.0)
	Debug.Notification("Whore licence revoked. No new one for " + (Days as Int) + " days.")
EndFunction

Function Punish(Actor akPlayer)
	_SLS_InterfaceDevious Devious = Game.GetFormFromFile(0x040068, "SL Survival.esp") as _SLS_InterfaceDevious
	If Devious && Devious.GetState() == "Installed"
		Devious.EquipRandomDds(akPlayer, 2)
	Else
		(Game.GetFormFromFile(0x000D64, "SL Survival.esp") as _SLS_ForcedDrugging).DoRapeDrugs(akPlayer, 2, false)
	EndIf
EndFunction
