ScriptName _SLS_TollDodgeTollDueDetection extends Quest

actor Property PlayerRef Auto

Quest Property _SLS_TollDodgeGuardSearch Auto

_sls_tolldodge Property TollDodge Auto

sls_mcm Property Menu Auto

Event OnInit()
    if IsRunning()
        RegisterForSingleUpdate(0.0)
    endif
EndEvent

Event OnUpdate()
    if !IsRunning()
        return
    endif
    ; SLSFW: the DLL picks the guards the search quest would fill (its alias conditions, closest first) and runs the
    ; same detection + line-of-sight test, so the quest is no longer restarted on every update
    if SLSFW.IsReady()
        actor Spotter = SLSFW.FindSpottingGuard(_SLS_TollDodgeGuardSearch)
        if Spotter
            debug.Notification("The guards have spotted me. They'll expect the toll be paid before I leave")
            debug.Trace("_SLS_: The guards have spotted me: " + Spotter + " - " + Spotter.GetBaseObject().GetName(), 0)
            TollDodge.SetTollDue(TollDodge.LastTollLocation, true)
            Stop()
            return
        endif
        RegisterForSingleUpdate(Menu.TollDodgeHuntFreq)
        return
    endif
    _SLS_TollDodgeGuardSearch.Stop()
    _SLS_TollDodgeGuardSearch.Start()
    int i = _SLS_TollDodgeGuardSearch.GetNumAliases()
    while i > 0
        i = i - 1
        actor Guard = ((_SLS_TollDodgeGuardSearch.GetNthAlias(i) as referencealias).GetReference() as actor)
        if Guard
            if PlayerRef.IsDetectedBy(Guard) && Guard.HasLos(PlayerRef)
                debug.Notification("The guards have spotted me. They'll expect the toll be paid before I leave")
                debug.Trace("_SLS_: The guards have spotted me: " + Guard + " - " + Guard.GetBaseObject().GetName(), 0)
                TollDodge.SetTollDue(TollDodge.LastTollLocation, true)
                Stop()
                return
            endif
        endif
    endwhile
    RegisterForSingleUpdate(Menu.TollDodgeHuntFreq)
EndEvent

