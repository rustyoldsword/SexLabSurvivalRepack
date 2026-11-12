Scriptname _SLS_LicenceForceGreetKicker extends Quest

; 3.0.2: the collector's "Hold on a second" / "One moment while I check your licences" lines loop for as long as
; LicInfractionType == -1 (check still running). This quest stops the player while the check runs and guarantees the
; loop ends: if the check never writes its result (script error, aborted thread), it is released after WatchdogTime.

Float Property WatchdogTime = 60.0 Auto Hidden

Event OnInit()
	If Self.IsRunning()
		GoToState("")
		RegisterForSingleUpdate(0.75)
	EndIf
EndEvent

Event OnUpdate()
	; only while the check is still running - a finished check starts the force greet itself when there is something
	; to stop for, and a clean one lets the player through without a greet
	If LicUtil.LicInfractionType == -1 && !_SLS_LicenceForceGreetQuest.IsRunning()
		_SLS_LicenceForceGreetQuest.Start()
	EndIf
	GoToState("Watch")
	RegisterForSingleUpdate(WatchdogTime)
EndEvent

State Watch
	Event OnUpdate()
		If LicUtil.LicInfractionType == -1
			Debug.Trace("_SLS_: licence check did not finish in " + WatchdogTime + "s - releasing the collector's wait loop")
			LicUtil.LicInfractionType = -2 ; "You may go" (0D91FC) ends the dialogue and stops the force greet quest
		EndIf
		GoToState("")
		Self.Stop()
	EndEvent
EndState

Quest Property _SLS_LicenceForceGreetQuest Auto

_SLS_LicenceUtil Property LicUtil Auto
